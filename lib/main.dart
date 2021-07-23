import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mesbro_chat_flutter_app/screens/chat_contact_options_page.dart';
import 'package:mesbro_chat_flutter_app/screens/chat_screens/chat_page.dart';
import 'package:mesbro_chat_flutter_app/screens/contact_page.dart';
import 'package:mesbro_chat_flutter_app/screens/forgot_password_page.dart';
import 'package:mesbro_chat_flutter_app/screens/home_page.dart';
import 'package:mesbro_chat_flutter_app/screens/idm/login_page.dart';
import 'package:mesbro_chat_flutter_app/screens/idm/register_page.dart';
import 'package:mesbro_chat_flutter_app/screens/new_conversation_page.dart';
import 'package:mesbro_chat_flutter_app/screens/group_screens/new_group_page.dart';
import 'package:mesbro_chat_flutter_app/screens/profile_screens/edit_profile_screens/profile_page.dart';
import 'package:mesbro_chat_flutter_app/utils/network_connectivity.dart';
import 'package:mesbro_chat_flutter_app/utils/shared_pref_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_stetho/flutter_stetho.dart';

import 'models/user.dart';
import 'network/user_connect.dart';

void main() {
  Stetho.initialize();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SharedPrefManager.getSharedPref().then((SharedPreferences sharedPreferences) {
    SharedPrefManager.getCurrentUser().then((User user) {
      SharedPrefManager.getAllUsers();
      if (user != null) {
        Connect.currentUser = user;
      }
      runApp(MyApp());
    });
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NetworkConnectivity(
      widget: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Mesbro Chat', 
          theme: ThemeData(
            accentColor: Colors.blue,
            primarySwatch: Colors.blue,
            fontFamily: 'Poppins' 
          ),
          home: Connect.currentUser == null
              ? LoginPage(previousScreen: '')
              : ChatContactOptionsPage(),
          routes: <String, WidgetBuilder>{
            '/login_page': (BuildContext context) =>
                LoginPage(previousScreen: ''),
            '/register_page': (BuildContext context) => RegisterPage(),
            '/home_page': (BuildContext context) => HomePage(),
            '/forgot_password_page': (BuildContext context) =>
                ForgotPasswordPage(),
            '/profile_page': (BuildContext context) => ProfilePage(),
            '/chat_contact_options_page': (BuildContext context) =>
                ChatContactOptionsPage(),
            '/chat_page': (BuildContext context) => ChatPage(),
            '/new_conversation_page': (BuildContext context) =>
                NewConversationPage(),
            '/new_group_page': (BuildContext context) => NewGroupPage(),
            '/contact_page': (BuildContext context) => ContactPage(),
          }),
    );
  }
}
