import 'package:auto_route/auto_route.dart';
import 'package:chatbotapp/router/router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final String userName;
  final String userEmail;
  final bool isAdmin;
  final bool isDarkTheme;
  final TextEditingController notificationTitleController;
  final TextEditingController notificationDescController;
  final Future<void> Function(String) deleteNotification;
  final Future<void> Function() addNotification;
  final Future<void> Function(BuildContext, String) launchExternalUrl;
  final Future<void> Function(BuildContext) signOut;

  const CustomDrawer({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.isAdmin,
    required this.isDarkTheme,
    required this.notificationTitleController,
    required this.notificationDescController,
    required this.deleteNotification,
    required this.addNotification,
    required this.launchExternalUrl,
    required this.signOut,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Center(
            child: UserAccountsDrawerHeader(
              accountName: Text(userName),
              accountEmail: Text(userEmail),
              currentAccountPicture: const CircleAvatar(
                backgroundImage: AssetImage('assets/images/user_icon.png'),
              ),
              decoration: BoxDecoration(
                color: isDarkTheme ? Colors.black87 : Colors.blue,
              ),
            ),
          ),
          if (isAdmin) ...[
            ListTile(
              leading: const Icon(Icons.add_alert),
              title: const Text('Add Notification'),
              onTap: () => _showAddNotificationDialog(context),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete Notification'),
              onTap: () => _showDeleteNotificationDialog(context),
            ),
            const Divider(),
          ],
          ListTile(
            leading: const Icon(Icons.update),
            title: const Text('New Updates'),
            onTap: () => launchExternalUrl(
                context, "https://dbatu.ac.in/tag/examination-timetable/"),
          ),
          ListTile(
            leading: const Icon(Icons.wechat_sharp),
            title: const Text('Whatsapp Channel'),
            onTap: () => launchExternalUrl(context,
                "https://whatsapp.com/channel/0029Va9h9VZ35fLo6rykj30u"),
          ),
          ListTile(
            leading: const Icon(Icons.money_sharp),
            title: const Text('Fees Portal'),
            onTap: () =>
                launchExternalUrl(context, "https://server.mspmandal.in/dengpmt"),
          ),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('Feedback Page'),
            onTap: () => launchExternalUrl(
                context, "http://smartfeedbacktandp.auradigital.in/"),
          ),
          ListTile(
            leading: const Icon(Icons.panorama_photosphere),
            title: const Text('Previous Year Papers'),
            onTap: () => launchExternalUrl(context,
                "https://drive.google.com/drive/folders/1v0UqvKvsE458TDzNe02ib11YLyLfD5un"),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  void _showAddNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text('Add Notification', 
          style: Theme.of(context).textTheme.titleMedium ,)),
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
              child: const Text('Submit',style: TextStyle(color: Colors.green)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel',style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text('Delete Notification',
            style: Theme.of(context).textTheme.titleMedium,),
          ),
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
                height: 300,
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
                                title: Center(
                                  child: Text("Delete Notification?",
                                  style: Theme.of(context).textTheme.titleMedium,),
                                ),
                                content: Text(
                                    "Are you sure you want to delete this notification?",
                                    style: Theme.of(context).textTheme.bodyMedium,),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      deleteNotification(notification.id);
                                      Navigator.of(context).pop(); // Close alert
                                      Navigator.of(context).pop(); // Close dialog
                                    },
                                    child: const Text("Yes", style: TextStyle(color: Colors.red),),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text("No", style: TextStyle(color: Colors.green),),
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
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:  Center(child: Text('Logout ?',
          style: Theme.of(context).textTheme.titleMedium,)),
          content: Text("Do you want to Log out from Diems Solution",
          style: Theme.of(context).textTheme.bodyMedium,),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), 
            child: const Text('No',
            style: TextStyle(color: Colors.green),)),

            TextButton(
              onPressed: () {
                context.router.push(const LoginRoute());
              },
              child: const Text("Yes",
              style: TextStyle(color: Colors.red),),
            ),
          ],
        );
      },
    );
    signOut(context);
  }
}
