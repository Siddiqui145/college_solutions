import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../apis/api_service.dart';

void main() async {
  // Use the new API key from the ApiService class.
  final apiKey = ApiService.apiKey;

  if (apiKey.isEmpty) {
    stderr.writeln('API key is missing.');
    exit(1);
  }

  // Initialize the new fine-tuned model.
  final model = GenerativeModel(
    model: 'tunedModels/solutiontunedmodel-l81nft6cr7rm', // New model ID.
    apiKey: apiKey,
    generationConfig: GenerationConfig(
      temperature: 0.3, // Deterministic responses.
      topK: 50,         // Reduce token variability.
      topP: 0.9,        // Focus on most probable outputs.
      maxOutputTokens: 1056,
      responseMimeType: 'text/plain',
    ),
  );

  // Define chat history based on your use case.
  final chat = model.startChat(history: [
    Content.multi([TextPart('You are a helpful assistant for DIEMS College.')]),
    Content.model([TextPart('Sure, how can I assist you?')]),
    Content.multi([TextPart('What are the features of the college?')]),
    Content.model([TextPart('DIEMS offers excellent education, a friendly environment, and great placement opportunities.')]),
  ]);

  // Insert a test query for validation.
  const userQuery = 'Where is DIEMS located?';
  final content = Content.text(userQuery);

  try {
    // Send the test query and print the response.
    final response = await chat.sendMessage(content);
    // ignore: avoid_print
    print('[Response]: ${response.text}');
  } catch (e) {
    stderr.writeln('Error while fetching response: $e');
  }
}
