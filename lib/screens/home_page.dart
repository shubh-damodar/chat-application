import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mesbro_chat_flutter_app/models/user.dart';
import 'package:mesbro_chat_flutter_app/network/user_connect.dart';
import 'package:mesbro_chat_flutter_app/utils/navigation_actions.dart';
import 'package:mesbro_chat_flutter_app/utils/shared_pref_manager.dart';
import 'package:mesbro_chat_flutter_app/utils/widgets_collection.dart';

import 'idm/login_page.dart';

class HomePage extends StatefulWidget {
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  NavigationActions _navigationActions;
  WidgetsCollection _widgetsCollection;
  List<User> _usersList = List<User>();

  void initState() {
    super.initState();
    _getAllUsers();
    _navigationActions = NavigationActions(context);
    _widgetsCollection = WidgetsCollection(context);
  }

  void dispose() {
    super.dispose();
  }

  Future<void> _getAllUsers() async {
    await SharedPrefManager.getAllUsers().then((List<User> user) {
      setState(() {
        _usersList = user;
      });
    });
  }

  double _screenWidth;

  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home'
        ),
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
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  child:
                                      _widgetsCollection.getDrawerProfileImage(
                                          45.0, _usersList[index]),
                                  onTap: () {
                                    setState(() {
                                      SharedPrefManager.switchCurrentUser(
                                              _usersList[index])
                                          .then((value) {
                                        _navigationActions.navigateToScreenName(
                                            'profile_page');
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
                                    border: Border.all(color: Colors.white)),
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
                                                              'home_page'));
                                            })))),
                          ],
                        )))),
            Flexible(
                flex: 7,
                child: Drawer(
                    elevation: 1.0,
                    child: ListView(
                      shrinkWrap: true,
                      children: <Widget>[
                        DrawerHeader(
                          child: Image.asset(
                            'assets_image/mesbro.png',
//                      width: _screenWidth*0.5,
                            width: 50.0,
                          ),
                        ),
                        ListTile(
                          leading: Icon(Icons.inbox),
                          title: Text(
                            'Inbox'
                          ),
                          onTap: () {
                            _navigationActions
                                .navigateToScreenName('profile_page');
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.person),
                          title: Text(
                            'Profile'
                          ),
                          onTap: () {
                            _navigationActions
                                .navigateToScreenName('profile_page');
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.person),
                          title: Text(
                            'Mesbro'
                          ),
                          onTap: () {
                            _navigationActions
                                .navigateToScreenName('chat_page');
                          },
                        )
                      ],
                    )))
          ])),
      body: Container(
          height: 300.0,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: <BoxShadow>[
              BoxShadow(spreadRadius: 0.3, color: Colors.black38),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              // Padding(
              //   // padding: EdgeInsets.all(100.0),
              // ),
              Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 5.0),
                  ),
                  Container(
                    width: 140.0,
                    height: 140.0,
                    child: ClipOval(
                        child: CachedNetworkImage(
                      imageUrl:
                          '${Connect.filesUrl}${Connect.currentUser.profileImage}',
                      placeholder: (BuildContext context, String url) {
                        return Image.asset('assets/images/male-avatar.png');
                      },
                    )),
                  ),
                  // Padding(padding: const EdgeInsets.only(right: 30.0)),
                  Padding(
                    padding: EdgeInsets.all(5.0),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '${Connect.currentUser.name}',
                        style: TextStyle(
                            // fontWeight: FontWeight.w700,
                            fontSize: 15.0,
                            color: Colors.black,
                            ),
                      ),
                      RaisedButton(
                        color: Theme.of(context).accentColor,
                        child: Text('Chat',
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 13.0,
                                color: Colors.white)),
                        onPressed: () {
                          _navigationActions.navigateToScreenNameRoot(
                            'chat_contact_options_page',
                          );
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                      ),
                      RaisedButton(
                        color: Theme.of(context).accentColor,
                        child: Text('Log out',
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 13.0,
                                color: Colors.white)),
                        onPressed: () {
                          SharedPrefManager.removeAll().then((bool value) {
                            _navigationActions
                                .navigateToScreenNameRoot('login_page');
                          });
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                      )
                    ],
                  ),
                ],
              ),
              // Center(
              //   child: Container(
              //     width: 200.0,
              //     height: 200.0,
              //     child: ClipOval(
              //         child: CachedNetworkImage(
              //       imageUrl:
              //           '${Connect.filesUrl}${Connect.currentUser.profileImage}',
              //       placeholder: (BuildContext context, String url) {
              //         return Image.asset('assets_image/male-avatar.png');
              //       },
              //     )),
              //   ),
              // ),
              // Text('${Connect.currentUser.name}'),
              // RaisedButton(
              //   child: Text('Chat'),
              //   onPressed: () {
              //     _navigationActions.navigateToScreenNameRoot('chat_page');
              //   },
              // ),
              // RaisedButton(
              //   child: Text('Log out'),
              //   onPressed: () {
              //     SharedPrefManager.removeAll().then((bool value) {
              //       _navigationActions.navigateToScreenNameRoot('login_page');
              //     });
              //   },
              // )
            ],
          )),
    );
  }
}
