import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:mesbro_chat_flutter_app/bloc_patterns/chat_contact_options_bloc.dart';
import 'package:mesbro_chat_flutter_app/models/conversation.dart';
import 'package:mesbro_chat_flutter_app/models/user.dart';
import 'package:mesbro_chat_flutter_app/network/user_connect.dart';
import 'package:mesbro_chat_flutter_app/screens/profile_screens/edit_profile_screens/profile_page.dart';
import 'package:mesbro_chat_flutter_app/screens/search_chat_page.dart';
import 'package:mesbro_chat_flutter_app/utils/navigation_actions.dart';
import 'package:mesbro_chat_flutter_app/utils/network_connectivity.dart';
import 'package:mesbro_chat_flutter_app/utils/shared_pref_manager.dart';
import 'package:mesbro_chat_flutter_app/utils/widgets_collection.dart';
import 'package:animated_floatactionbuttons/animated_floatactionbuttons.dart';

import 'package:mesbro_chat_flutter_app/screens/chat_screens/chat_page.dart';
import 'contact_page.dart';
import 'group_screens/new_group_page.dart';
import 'idm/login_page.dart';
import 'new_conversation_page.dart';

class ChatContactOptionsPage extends StatefulWidget {
  _ChatContactOptionsPageState createState() => _ChatContactOptionsPageState();
}

class _ChatContactOptionsPageState extends State<ChatContactOptionsPage>
    with SingleTickerProviderStateMixin {
  final ChatContactOptionsBloc _chatContactOptionsBloc =
      ChatContactOptionsBloc();
  NavigationActions _navigationActions;
  WidgetsCollection _widgetsCollection;
  TabController _tabController;
  DateTime currentBackPressDateTime;
  List<User> _usersList = List<User>();
  LinkedHashMap<String, Widget> _settingsRouteLinkedHashMap =
      LinkedHashMap<String, Widget>();

  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((Duration duration) {
      NetworkConnectivity.of(context).checkNetworkConnection();
      //print('~~~ scedulebind');
    });
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _getAllUsers();
    _navigationActions = NavigationActions(context);
    _widgetsCollection = WidgetsCollection(context);
    _settingsRouteLinkedHashMap['New Conversation'] = NewConversationPage();
    _settingsRouteLinkedHashMap['New Group'] = NewGroupPage();
    _chatContactOptionsBloc.getSavedConversations();
  }

  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  void _navigateAndRefresh(Widget widget) {
    Navigator.of(context, rootNavigator: false)
        .push(MaterialPageRoute(builder: (context) => widget))
        .then((dynamic) {
      //print('~~~ _navigateAndRefresh');
      _chatContactOptionsBloc.retrieveConversations();
    });
  }

  Future<void> _getAllUsers() async {
    await SharedPrefManager.getAllUsers().then((List<User> user) {
      setState(() {
        _usersList = user;
      });
    });
  }

  double _screenWidth, _screenHeight;

  Future<bool> _onWillPop() async {
    DateTime now = DateTime.now();
    if (currentBackPressDateTime == null ||
        now.difference(currentBackPressDateTime) > Duration(seconds: 2)) {
      currentBackPressDateTime = now;
      _widgetsCollection.showToastMessage('Press once again to exit');
      return Future.value(false);
    }
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    return Future.value(true);
  }

  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
            floatingActionButton: AnimatedFloatingActionButton(
              fabButtons: <Widget>[
                Container(
                  child: FloatingActionButton(
                    onPressed: () {
                      _navigateAndRefresh(
                          _settingsRouteLinkedHashMap['New Conversation']);
                    },
                    heroTag: "New Conversation",
                    tooltip: 'New Conversation',
                    child: Icon(Icons.person),
                  ),
                ),
                Container(
                  child: FloatingActionButton(
                    onPressed: () {
                      _navigateAndRefresh(
                          _settingsRouteLinkedHashMap['New Group']);
                    },
                    heroTag: "Group Conversation",
                    tooltip: 'Group Conversation',
                    child: Icon(Icons.group),
                  ),
                ),
              ],
              colorStartAnimation: Theme.of(context).accentColor,
              colorEndAnimation: Colors.deepOrange,
              animatedIconData: AnimatedIcons.menu_close,
            ),
            appBar: AppBar(
              title: Text('Mesbro',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0)),
              bottom: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(
                    text: 'CHAT',
                  ),
                  Tab(
                    text: 'CONTACT',
                  ),
                ],
              ),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _navigationActions.navigateToScreenWidget(SearchChatPage());
                  },
                ),
                PopupMenuButton<String>(
                  onSelected: (String settingsOption) {
                    //print(
                        // '~~~ settingsOption: $settingsOption ${_settingsRouteLinkedHashMap[settingsOption]}');
                    _navigateAndRefresh(
                        _settingsRouteLinkedHashMap[settingsOption]);
                  },
                  itemBuilder: (BuildContext context) {
                    return _settingsRouteLinkedHashMap.keys
                        .toList()
                        .map((String settingsOption) {
                      return PopupMenuItem<String>(
                        value: settingsOption,
                        child: Text(settingsOption),
                      );
                    }).toList();
                  },
                )
              ],
            ),
            drawer: Container(
                width: _screenWidth * 0.90,
                child: Row(children: <Widget>[
                  Flexible(
                      flex: 2,
                      child: Container(
                          color: Colors.white,
                          child: Container(
                              margin: EdgeInsets.only(top: 20.0),
                              color: Colors.grey.withOpacity(0.25),
                              child: ListView(
                                children: <Widget>[
                                  ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: _usersList.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return GestureDetector(
                                        child: _widgetsCollection
                                            .getDrawerProfileImage(
                                                45.0, _usersList[index]),
                                        onTap: () {
                                          setState(() {
                                            SharedPrefManager.switchCurrentUser(
                                                    _usersList[index])
                                                .then((value) {
                                              _navigationActions
                                                  .navigateToScreenWidget(
                                                      ProfilePage(
                                                          userId: Connect
                                                              .currentUser
                                                              .userId));
                                            });
                                          });
                                        },
                                      );
                                    },
                                  ),
                                  Container(
                                      margin: EdgeInsets.only(bottom: 10.0),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          border:
                                              Border.all(color: Colors.white)),
                                      padding: EdgeInsets.all(0.5),
                                      width: 45.0,
                                      height: 45.0,
                                      child: Center(
                                          child: ClipOval(
                                              child: IconButton(
                                                  icon: Icon(Icons.person_add),
                                                  onPressed: () {
//                _navigationActions.navigateToScreenName('login_page');
                                                    _navigationActions
                                                        .navigateToScreenWidget(
                                                            LoginPage(
                                                                previousScreen:
                                                                    'chat_contact_options_page'));
                                                  })))),
                                ],
                              )))),
                  Flexible(
                      flex: 7,
                      child: Drawer(
                          elevation: 1.0,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
//                        shrinkWrap: true,
                            children: <Widget>[
                              DrawerHeader(
                                child: Image.asset(
                                  'assets_image/mesbro.png',
                                  width: _screenWidth * 0.4,
                                ),
                              ),
                              ListTile(
                                leading: Icon(Icons.person),
                                title: Text(
                                  'Profile',
                                ),
                                onTap: () {
                                  _navigationActions.navigateToScreenWidget(
                                      ProfilePage(
                                          userId: Connect.currentUser.userId));
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.exit_to_app),
                                title: Text(
                                  'Log Out',
                                ),
                                onTap: () {
                                  SharedPrefManager.removeAll()
                                      .then((bool value) {
                                    //print('~~~ Log Out: $value');
                                    _navigationActions
                                        .navigateToScreenWidgetRoot(
                                            LoginPage());
                                  });
                                },
                              ),
                              Expanded(
                                  child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                          margin: EdgeInsets.only(bottom: 10.0),
                                          child: Text(
                                            'Version: 0.1.0',
                                            style: TextStyle(
                                                fontSize: 13.0,
                                                ),
                                          ))))
                            ],
                          )))
                ])),
            body: StreamBuilder(
                stream: _chatContactOptionsBloc.conversationsStream,
                initialData: null,
                builder: (BuildContext context,
                    AsyncSnapshot<List<Conversation>> asyncSnapshot) {
                  //print('~~~ tabController Changed ${asyncSnapshot.data}');
                  return asyncSnapshot.data == null
                      ? TabBarView(
                          controller: _tabController,
                          children: <Widget>[
                            Container(),
                            Container(),
                          ],
                        )
                      : asyncSnapshot.data.length == 0
                          ? TabBarView(
                              controller: _tabController,
                              children: <Widget>[
                                Container(),
                                Container(),
                              ],
                            )
                          : TabBarView(
                              controller: _tabController,
                              children: <Widget>[
                                ChatPage(
                                    conversationsList: _chatContactOptionsBloc
                                        .conversationsList),
                                ContactPage(
                                    conversationsList: _chatContactOptionsBloc
                                        .conversationsList),
                              ],
                            );
                })));
  }
}
