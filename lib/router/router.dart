import 'package:auto_route/auto_route.dart';
import 'package:chatbotapp/screens/chat_history_screen.dart';
import 'package:chatbotapp/screens/chat_screen.dart';
import 'package:chatbotapp/screens/home_screen.dart';
import 'package:chatbotapp/screens/login.dart';
import 'package:chatbotapp/screens/profile_screen.dart';
import 'package:chatbotapp/screens/reset.dart';
import 'package:chatbotapp/screens/signup.dart';
import 'package:chatbotapp/screens/splash_screen.dart';

part 'router.gr.dart';

@AutoRouterConfig()
class AppRouter extends _$AppRouter{

  @override
  List <AutoRoute> get routes => [

    AutoRoute(page: SplashRoute.page, initial: true),

    CustomRoute(page: HomeRoute.page,
    children: [
      AutoRoute(page: ProfileRoute.page, initial: true),
      AutoRoute(page: ChatRoute.page),
      AutoRoute(page: ChatHistoryRoute.page)
    ]),

    //AutoRoute(page: ChatHistoryRoute.page),
    //AutoRoute(page: ChatRoute.page),
    AutoRoute(page: LoginRoute.page),
    //AutoRoute(page: ProfileRoute.page),
    AutoRoute(page: ResetPasswordRoute.page),
    AutoRoute(page: SignupRoute.page),
  ];
}