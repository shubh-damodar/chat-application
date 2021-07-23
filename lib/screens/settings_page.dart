import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:mesbro_chat_flutter_app/screens/profile_screens/edit_profile_screens/edit_contact_page.dart';
import 'package:mesbro_chat_flutter_app/screens/profile_screens/edit_profile_screens/edit_location_page.dart';
import 'package:mesbro_chat_flutter_app/screens/profile_screens/edit_profile_screens/edit_personal_page.dart';
import 'package:mesbro_chat_flutter_app/utils/navigation_actions.dart';
import 'package:mesbro_chat_flutter_app/utils/widgets_collection.dart';

class SettingsPage extends StatefulWidget {
  final Map<String, dynamic> userMap;

  SettingsPage({this.userMap});
  _SettingsPageState createState() => _SettingsPageState(userMap: userMap);
}

class _SettingsPageState extends State<SettingsPage> {
  final Map<String, dynamic> userMap;

  _SettingsPageState({this.userMap});

  LinkedHashMap<String, Widget> _optionsLinkedHashMap =
      LinkedHashMap<String, Widget>();

  NavigationActions _navigationActions;
  WidgetsCollection _widgetsCollection;

  void initState() {
    super.initState();
    _optionsLinkedHashMap['Edit Personal'] = EditPersonalPage(userMap: userMap);
    _optionsLinkedHashMap['Edit Location'] = EditLocationPage(userMap: userMap);
    _optionsLinkedHashMap['Edit Contact'] = EditContactPage(userMap: userMap);
    _navigationActions = NavigationActions(context);
    _widgetsCollection = WidgetsCollection(context);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile Settings'
        ),
      ),
      body: Container(
          margin:
              EdgeInsets.only(top: 10.0, bottom: 10.0, left: 10.0, right: 10.0),
          child: ListView.builder(
            itemCount: _optionsLinkedHashMap.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(_optionsLinkedHashMap.keys.toList()[index]),
                onTap: () {
                  _navigationActions.navigateToScreenWidget(
                      _optionsLinkedHashMap.values.toList()[index]);
                },
              );
            },
          )),
    );
  }
}
