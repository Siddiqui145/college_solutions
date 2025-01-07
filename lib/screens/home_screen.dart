import 'package:auto_route/auto_route.dart';
import 'package:chatbotapp/router/router.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chatbotapp/providers/chat_provider.dart';
import 'package:provider/provider.dart';

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // List of screens
  // final List<Widget> _screens = [
  //   const ProfileScreen(),
  //   const ChatScreen(),
  //   const ChatHistoryScreen(),
  // ];

  @override
  Widget build(BuildContext context) {

    return  AutoTabsRouter(
      routes: const [
        ProfileRoute(),
        ChatRoute(),
        ChatHistoryRoute()
      ],

      transitionBuilder: (context, child, animation) {
        return FadeTransition(opacity: animation, child: child,);
      },
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);

        return Scaffold(
          body: child,
          bottomNavigationBar: Consumer<ChatProvider>(
            builder: (context, chatProvider, _) {
              return BottomNavigationBar(
                currentIndex: tabsRouter.activeIndex,
                type: BottomNavigationBarType.fixed,
                elevation: 4,
                selectedItemColor: Theme.of(context).colorScheme.primary,
                onTap: (index) {
                  tabsRouter.setActiveIndex(index);
                  chatProvider.setCurrentIndex(newIndex: index);
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.person),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.chat_bubble),
                    label: 'Chat',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.pause_rectangle),
                    label: 'Chat History',
                  ),
                ],

              );
            },),
        );
      }
    );
  }
}

//     return Consumer<ChatProvider>(
//       builder: (context, chatProvider, child) {
//           bottomNavigationBar: BottomNavigationBar(
//             currentIndex: chatProvider.currentIndex,
//             elevation: 0,
//             selectedItemColor: Theme.of(context).colorScheme.primary,
//             onTap: (index) {
//               chatProvider.setCurrentIndex(newIndex: index);
//               chatProvider.pageController.jumpToPage(index);
//             },
//             items: const [
//               BottomNavigationBarItem(
//                 icon: Icon(CupertinoIcons.person),
//                 label: 'Home',
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(CupertinoIcons.chat_bubble),
//                 label: 'Chat',
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(CupertinoIcons.pause_rectangle),
//                 label: 'Chat History',
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
