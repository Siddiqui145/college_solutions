// ignore_for_file: use_build_context_synchronously

import 'package:chatbotapp/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontSize: 22, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: isDarkTheme ? Colors.black87 : Colors.blue,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(userName),
              accountEmail: Text(userEmail),
              currentAccountPicture: const CircleAvatar(
                backgroundImage: AssetImage('assets/images/user_icon.png'),
              ),
              decoration: BoxDecoration(
                color: isDarkTheme ? Colors.black87 : Colors.blue,
              ),
            ),

            if (isAdmin) ...[
              ListTile(
                leading: const Icon(Icons.add_alert),
                title: const Text('Add Notification'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Add Notification'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: notificationTitleController,
                              decoration: const InputDecoration(
                                labelText: 'Notification Title',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: notificationDescController,
                              decoration: const InputDecoration(
                                labelText: 'Notification Description',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              addNotification();
                              Navigator.of(context).pop();
                            },
                            child: const Text('Submit'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancel'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              const Divider(),
            ],

            if (isAdmin)...[
    ListTile(
      leading: const Icon(Icons.delete),
      title: const Text('Delete Notification'),
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Delete Notification'),
              content: StreamBuilder<QuerySnapshot>(
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
                  return SizedBox(
                    height: 200,
                    child: ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var notification = snapshot.data!.docs[index];
                        return ListTile(
                          title: Text(notification['title']),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Delete Notification?"),
                                    content: const Text(
                                        "Are you sure you want to delete this notification?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          deleteNotification(notification.id);
                                          Navigator.of(context)
                                              .pop(); 
                                          Navigator.of(context)
                                              .pop(); 
                                        },
                                        child: const Text("Yes"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(); 
                                        },
                                        child: const Text("No"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    ),
    const Divider(),
  ],

            ListTile(
              leading: const Icon(Icons.update),
              title: const Text('New Updates'),
              onTap: () async {
                final Uri url = Uri.parse("https://dbatu.ac.in/tag/examination-timetable/");
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.wechat_sharp),
              title: const Text('Whatsapp Channel'),
              onTap: () async {
                final Uri url =
                    Uri.parse("https://whatsapp.com/channel/0029Va9h9VZ35fLo6rykj30u");
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
            ),

            ListTile(
              leading: const Icon(Icons.money_sharp),
              title: const Text('Fees Portal'),
              onTap: () async {
                final Uri url = Uri.parse("https://server.mspmandal.in/dengpmt");
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
            ),

            ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text('Feedback Page'),
              onTap: () async {
                final Uri url = Uri.parse("http://smartfeedbacktandp.auradigital.in/");
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
            ),

            ListTile(
              leading: const Icon(Icons.panorama_photosphere),
              title: const Text('Previous Year Papers'),
              onTap: () async {
                final Uri url = Uri.parse(
                    "https://drive.google.com/drive/folders/1v0UqvKvsE458TDzNe02ib11YLyLfD5un");
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
            ),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                showDialog(context: context, builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Looged out'),
                    content: const Text("Logged out Successfully from Diems Solution"),
                    actions: [
                      TextButton(onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                      }, child: const Text("Ok"))
                    ],
                  );
                });
                signOut(context);
                
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'assets/images/user_icon.png',
                width: 100,
                height: 100,
              ),
            ),
            const SizedBox(height: 20.0),
            Center(
              child: Text(
                userName,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 30.0),
            const Text(
              'Important Notifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10.0),
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
                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundImage:
                              AssetImage('assets/images/user_icon.png'),
                        ),
                        title: Text(notification['title']),
                        subtitle: Text(notification['description']),
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