import 'package:flutter/material.dart';
import 'package:messenger_for_nou/ui/chats_screen.dart';
import 'package:messenger_for_nou/ui/authorize_screen.dart';
import 'package:messenger_for_nou/utils/is_user_authorized.dart';

main() async {

  final isAuthorized = await Authorization.isUserAuthorized();

  runApp(MaterialApp(
    theme: ThemeData(
      primaryColor: Colors.white,
      accentColor: Colors.white,
      buttonColor: Colors.black54,
    ),
    initialRoute: "/",
    routes: {
      "/main": (context) => ChatsScreen(),
      "/": (context) => isAuthorized ? ChatsScreen() : AuthorizeScreen(),
    },
  ));
}
