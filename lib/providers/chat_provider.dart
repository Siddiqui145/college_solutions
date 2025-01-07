import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:chatbotapp/apis/api_service.dart';
import 'package:chatbotapp/constants/constants.dart';
import 'package:chatbotapp/hive/boxes.dart';
import 'package:chatbotapp/hive/chat_history.dart';
import 'package:chatbotapp/hive/settings.dart';
import 'package:chatbotapp/hive/user_model.dart';
import 'package:chatbotapp/models/message.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:uuid/uuid.dart';

class ChatProvider extends ChangeNotifier {
  // List of chat messages
  final List<Message> _inChatMessages = [];
  List<XFile>? _imagesFileList = [];

  // Page controller
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // Chat ID and model info
  String _currentChatId = '';
  String _modelType = 'gemini-pro';

  // Loading and model states
  bool _isLoading = false;
  GenerativeModel? _model;
  GenerativeModel? _textModel;
  GenerativeModel? _visionModel;

  // Getters
  List<Message> get inChatMessages => _inChatMessages;
  PageController get pageController => _pageController;
  List<XFile>? get imagesFileList => _imagesFileList;
  int get currentIndex => _currentIndex;
  String get currentChatId => _currentChatId;
  String get modelType => _modelType;
  bool get isLoading => _isLoading;
  GenerativeModel? get model => _model;
  GenerativeModel? get textModel => _textModel;
  GenerativeModel? get visionModel => _visionModel;

  // Setters
  void setImagesFileList({required List<XFile> listValue}) {
    _imagesFileList = listValue;
    notifyListeners();
  }

  void setCurrentIndex({required int newIndex}) {
    _currentIndex = newIndex;
    notifyListeners();
  }

  void setCurrentChatId({required String newChatId}) {
    _currentChatId = newChatId;
    notifyListeners();
  }

  void setLoading({required bool value}) {
    _isLoading = value;
    notifyListeners();
  }

  String setCurrentModel({required String newModel}) {
    _modelType = newModel;
    notifyListeners();
    return newModel;
  }

  Future<void> setModel({required bool isTextOnly}) async {
  _model = GenerativeModel(
    model: "tunedModels/solutiontunedmodel-l81nft6cr7rm", // Only use the fine-tuned model.
    apiKey: ApiService.apiKey,
  );
  notifyListeners();
}


  // Future<void> setModel({required bool isTextOnly}) async {
  //   _model = isTextOnly
  //       ? _textModel ??
  //           GenerativeModel(
  //             model: "tunedModels/diemssolutiontunedmodel-b50w6evdgmoq",
  //             apiKey: ApiService.apiKey,
  //           )
  //       : _visionModel ??
  //           GenerativeModel(
  //             model: setCurrentModel(newModel: 'gemini-pro-vision'),
  //             apiKey: ApiService.apiKey,
  //           );
  //   notifyListeners();
  // }

  // Method to set chat messages from database
  Future<void> setInChatMessages({required String chatId}) async {
    final messagesFromDB = await loadMessagesFromDB(chatId: chatId);
    for (var message in messagesFromDB) {
      if (!_inChatMessages.contains(message)) {
        _inChatMessages.add(message);
      }
    }
    notifyListeners();
  }

  // Load messages from Hive database based on chat ID
  Future<List<Message>> loadMessagesFromDB({required String chatId}) async {
    await Hive.openBox('${Constants.chatMessagesBox}$chatId');
    final messageBox = Hive.box('${Constants.chatMessagesBox}$chatId');
    final messages = messageBox.keys.map((key) {
      final message = messageBox.get(key);
      return Message.fromMap(Map<String, dynamic>.from(message));
    }).toList();
    return messages;
  }

  // Delete chat messages from the database
  Future<void> deleteChatMessages({required String chatId}) async {
    final boxName = '${Constants.chatMessagesBox}$chatId';
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox(boxName);
    }
    await Hive.box(boxName).clear();
    await Hive.box(boxName).close();

    if (_currentChatId == chatId) {
      setCurrentChatId(newChatId: '');
      _inChatMessages.clear();
      notifyListeners();
    }
  }

  // Prepare chat room, load previous messages if not a new chat
  Future<void> prepareChatRoom({
    required bool isNewChat,
    required String chatID,
  }) async {
    _inChatMessages.clear();
    if (!isNewChat) {
      final chatHistory = await loadMessagesFromDB(chatId: chatID);
      _inChatMessages.addAll(chatHistory);
    }
    setCurrentChatId(newChatId: chatID);
  }

  // Send message to generative model and handle response
  Future<void> sentMessage({
    required String message,
    required bool isTextOnly,
  }) async {
    await setModel(isTextOnly: isTextOnly);
    setLoading(value: true);

    String chatId = getChatId();
    List<Content> history = await getHistory(chatId: chatId);
    List<String> imagesUrls = getImagesUrls(isTextOnly: isTextOnly);

    final messagesBox =
        await Hive.openBox('${Constants.chatMessagesBox}$chatId');
    final userMessageId = messagesBox.keys.length;
    final assistantMessageId = userMessageId + 1;

    final userMessage = Message(
      messageId: userMessageId.toString(),
      chatId: chatId,
      role: Role.user,
      message: StringBuffer(message),
      imagesUrls: imagesUrls,
      timeSent: DateTime.now(),
    );

    _inChatMessages.add(userMessage);
    notifyListeners();

    if (_currentChatId.isEmpty) {
      setCurrentChatId(newChatId: chatId);
    }

    await sendMessageAndWaitForResponse(
      message: message,
      chatId: chatId,
      isTextOnly: isTextOnly,
      history: history,
      userMessage: userMessage,
      modelMessageId: assistantMessageId.toString(),
      messagesBox: messagesBox,
    );
  }

  // Process response from generative model
  Future<void> sendMessageAndWaitForResponse({
    required String message,
    required String chatId,
    required bool isTextOnly,
    required List<Content> history,
    required Message userMessage,
    required String modelMessageId,
    required Box messagesBox,
  }) async {
    final chatSession = _model!.startChat(
      history: history.isEmpty || !isTextOnly ? null : history,
    );

    final content = await getContent(
      message: message,
      isTextOnly: isTextOnly,
    );

    final assistantMessage = userMessage.copyWith(
      messageId: modelMessageId,
      role: Role.assistant,
      message: StringBuffer(),
      timeSent: DateTime.now(),
    );

    _inChatMessages.add(assistantMessage);
    notifyListeners();

    chatSession.sendMessageStream(content).listen((event) {
      _inChatMessages
          .firstWhere((m) =>
              m.messageId == assistantMessage.messageId &&
              m.role == Role.assistant)
          .message
          .write(event.text);
      log('event: ${event.text}');
      notifyListeners();
    }, onDone: () async {
      log('stream done');
      await saveMessagesToDB(
        chatID: chatId,
        userMessage: userMessage,
        assistantMessage: assistantMessage,
        messagesBox: messagesBox,
      );
      setLoading(value: false);
    }).onError((error, stackTrace) {
      log('error: $error');
      setLoading(value: false);
    });
  }

  // Save messages to Hive database
  Future<void> saveMessagesToDB({
    required String chatID,
    required Message userMessage,
    required Message assistantMessage,
    required Box messagesBox,
  }) async {
    await messagesBox.add(userMessage.toMap());
    await messagesBox.add(assistantMessage.toMap());

    final chatHistoryBox = Boxes.getChatHistory();
    final chatHistory = ChatHistory(
      chatId: chatID,
      prompt: userMessage.message.toString(),
      response: assistantMessage.message.toString(),
      imagesUrls: userMessage.imagesUrls,
      timestamp: DateTime.now(),
    );
    await chatHistoryBox.put(chatID, chatHistory);
    await messagesBox.close();
  }

  // Generate content based on user input
  Future<Content> getContent({
    required String message,
    required bool isTextOnly,
  }) async {
    if (isTextOnly) {
      return Content.text(message);
    } else {
      final imageFutures = _imagesFileList
          ?.map((imageFile) => imageFile.readAsBytes())
          .toList(growable: false);

      final imageBytes = await Future.wait(imageFutures!);
      final prompt = TextPart(message);
      final imageParts = imageBytes
          .map((bytes) => DataPart('image/jpeg', Uint8List.fromList(bytes)))
          .toList();

      return Content.multi([prompt, ...imageParts]);
    }
  }

  // Retrieve image URLs
  List<String> getImagesUrls({required bool isTextOnly}) {
    if (isTextOnly || _imagesFileList == null) return [];
    return _imagesFileList!.map((image) => image.path).toList();
  }

  // Retrieve chat history
  Future<List<Content>> getHistory({required String chatId}) async {
    
    List<Content> history = [];
    if (_currentChatId.isNotEmpty) {
      await setInChatMessages(chatId: chatId);

      for (var message in inChatMessages) {
        history.add(message.role == Role.user
            ? Content.text(message.message.toString())
            : Content.model([TextPart(message.message.toString())]));
      }
    }
    return [
    Content.multi([TextPart('You are a helpful assistant for DIEMS College.')]),
    Content.model([TextPart('Sure, how can I assist you?')]),
  ];
  }

  // Generate or retrieve existing chat ID
  String getChatId() =>
      _currentChatId.isEmpty ? const Uuid().v4() : _currentChatId;

  // Initialize Hive database
  static Future<void> initHive() async {
    final dir = await path.getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    await Hive.initFlutter(Constants.geminiDB);

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ChatHistoryAdapter());
      await Hive.openBox<ChatHistory>(Constants.chatHistoryBox);
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserModelAdapter());
      await Hive.openBox<UserModel>(Constants.userBox);
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SettingsAdapter());
      await Hive.openBox<Settings>(Constants.settingsBox);
    }
  }
}
