// ignore_for_file: use_build_context_synchronously

import 'package:auto_route/auto_route.dart';
import 'package:chatbotapp/widgets/custom_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = 'WELCOME';
  String userEmail = '';
  bool isDarkTheme = false;

  final TextEditingController notificationTitleController =
      TextEditingController();
  final TextEditingController notificationDescController =
      TextEditingController();

  // List of admin UIDs
  final List<String> adminUIDs = [
    "YhJA5IdKLgXJAwavrsB0LWsqJSJ2",
    //"zbdf6GOQ1Kaf7wPkIOwScRI0Mmf1",
    //"VqHLdT9rbJMf4BzfLjERLzQhXe52"
  ];

  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  void fetchUserDetails() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email ?? '';
        userName = user.displayName ?? 'WELCOME TO DIEMS SOLUTION';
        isAdmin = adminUIDs.contains(user.uid); // Check if user is an admin
      });
    }
  }

  Future<void> addNotification() async {
    final title = notificationTitleController.text.trim();
    final description = notificationDescController.text.trim();

    if (title.isNotEmpty && description.isNotEmpty) {
      await FirebaseFirestore.instance.collection('notifications').add({
        'title': title,
        'description': description,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Notification Added")),
      );

      notificationTitleController.clear();
      notificationDescController.clear();
    }
  }

  Future<void> deleteNotification(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Notification Deleted")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting notification: $e")),
      );
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      
      
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

Future<void> launchExternalUrl(BuildContext context, String url) async {
  final Uri uri = Uri.parse(url);

  try {
    if (!await canLaunchUrl(uri)) {
      throw Exception("Cannot launch $url");
    }

    // Use external application mode for better handling
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e) {
    debugPrint("Error launching URL: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to open the URL: $url")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: Theme.of(context).textTheme.titleLarge
        ),
        centerTitle: true,
        backgroundColor: isDarkTheme ? Colors.black87 : Colors.blue,
      ),
      drawer: CustomDrawer(userName: userName, 
      userEmail: userEmail,
       isAdmin: isAdmin, 
       isDarkTheme: isDarkTheme, 
       notificationTitleController: notificationTitleController, 
       notificationDescController: notificationDescController, 
       deleteNotification: deleteNotification, 
       addNotification: addNotification, 
       launchExternalUrl: launchExternalUrl, 
       signOut: signOut),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SizedBox(
                width: 250,
                height: 120,
                child: Image.asset(
                  'assets/images/user_icon.png',
                  //width: 100,
                  //height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Center(
              child: Text(
                "Welcome, $userEmail",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 50.0),
             Center(
               child: Text(
                'Important Notifications',
                style: Theme.of(context).textTheme.titleMedium,
                           ),
             ),
            const SizedBox(height: 20.0),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text("No notifications available.");
                }
                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var notification = snapshot.data!.docs[index];
                      return Card(
                        //elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundImage:
                                AssetImage('assets/images/user_icon.png'),
                          ),
                          title: Text(notification['title']),
                          subtitle: Text(notification['description']),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}