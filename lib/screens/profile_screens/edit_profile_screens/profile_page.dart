import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mesbro_chat_flutter_app/bloc_patterns/edit_profile_bloc_patterns/profile_bloc.dart';
import 'package:mesbro_chat_flutter_app/screens/idm/login_page.dart';
import 'package:mesbro_chat_flutter_app/screens/profile_screens/contact_page.dart';
import 'package:mesbro_chat_flutter_app/screens/profile_screens/location_page.dart';
import 'package:mesbro_chat_flutter_app/screens/profile_screens/personal_page.dart';
import 'package:mesbro_chat_flutter_app/network/user_connect.dart';
import 'package:mesbro_chat_flutter_app/screens/idm/settings_page.dart';
import 'package:mesbro_chat_flutter_app/utils/navigation_actions.dart';
import 'package:mesbro_chat_flutter_app/utils/shared_pref_manager.dart';
import 'package:mesbro_chat_flutter_app/utils/widgets_collection.dart';

import 'package:mesbro_chat_flutter_app/screens/idm/edit_page.dart';

import '../../chat_contact_options_page.dart';

class ProfilePage extends StatefulWidget {
  final String userId, previousScreen;

  ProfilePage({this.userId, this.previousScreen});

  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final ProfileBloc _profileBloc = ProfileBloc();
  Map<String, dynamic> _userMap = null;
  NavigationActions _navigationActions;
  WidgetsCollection _widgetsCollection;
  TabController _tabController;
  String _filePath = '', userId;

  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _navigationActions = NavigationActions(context);
    _widgetsCollection = WidgetsCollection(context);
    _profileBloc.getAllUserDetails(widget.userId);

    if (widget.userId == Connect.currentUser.userId) {
      //print(
      // '~~~ userId: ${Connect.currentUser.au} ${Connect.currentUser.userId} ${Connect.currentUser.token}');
//      _profileBloc.getAllUserDetails(widget.userId);
//      _profileBloc.loadUserDetails();
    } else {}
    userId = widget.userId;
  }

  void dispose() {
    super.dispose();
    _tabController.dispose();
    _profileBloc.dispose();
  }

  Future<bool> _onWillPop() async {
    if (widget.previousScreen == 'individual_chat_page') {
      _navigationActions.closeDialog();
    } else {
      _navigationActions.closeDialog();
      _navigationActions.navigateToScreenWidgetRoot(ChatContactOptionsPage());
    }
    return false;
  }

  void _navigateAndRefresh(Widget widget) {
    Navigator.of(context, rootNavigator: false)
        .push(MaterialPageRoute(builder: (context) => widget))
        .then((dynamic) {
      //print('~~~ _navigateAndRefresh');
      _profileBloc.tabProfileStreamSink.add(null);
      _profileBloc.getAllUserDetails(userId);
    });
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
          actions: <Widget>[
            widget.userId == Connect.currentUser.userId
                ? IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () {
                      if (_userMap == null) {
                        _widgetsCollection
                            .showToastMessage('No service available');
                      } else {
                        _navigateAndRefresh(SettingsPage(userMap: _userMap));
                      }
                    },
                  )
                : Container(
                    width: 0.0,
                    height: 0.0,
                  ),
            widget.userId == Connect.currentUser.userId
                ? IconButton(
                    icon: Icon(Icons.exit_to_app),
                    onPressed: () {
                      SharedPrefManager.removeAll().then((bool value) {
                        //print('~~~ Log Out: $value');
                        _navigationActions
                            .navigateToScreenWidgetRoot(LoginPage());
                      });
                    },
                  )
                : Container(
                    width: 0.0,
                    height: 0.0,
                  )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              new Container(
                width: double.infinity,
                height: 290.0,
                child: Stack(
                  children: <Widget>[
                    StreamBuilder(
                        stream: _profileBloc.bannerImageStream,
                        builder: (BuildContext context,
                            AsyncSnapshot<String> asyncSnapshot) {
                          return asyncSnapshot.data == null
                              ? Image.asset(
                                  'assets_image/cover.png',
                                  width: double.infinity,
                                  height: 250,
                                  fit: BoxFit.cover,
                                )
                              : CachedNetworkImage(
                                  height: 250.0,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  imageUrl:
                                      '${Connect.filesUrl}${asyncSnapshot.data}',
                                  placeholder:
                                      (BuildContext context, String url) {
                                    return Image.asset(
                                      'assets_image/cover.png',
                                      width: double.infinity,
                                      height: 250.0,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                );
                        }),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: widget.userId == Connect.currentUser.userId
                            ? Container(
                                color: Colors.black.withOpacity(0.6),
                                padding: EdgeInsets.all(3),
                                child: GestureDetector(
                                    onTap: () {
                                      _profileBloc.changeProfileCoverImage(
                                          'bannerImage');
                                    },
                                    child: new Icon(
                                      Icons.edit,
                                      color: Colors.white.withOpacity(0.8),
                                      size: 20,
                                      // size: .0,
                                    )),
                              )
                            : Container(
                                width: 0,
                                height: 0,
                              ),
                      ),
                    ),
                    Positioned(
                      top: 160.0,
                      left: MediaQuery.of(context).size.width / 2 - 130 / 2,
                      child: PhysicalModel(
                        color: Colors.white,
                        borderRadius: new BorderRadius.circular(10.0),
                        elevation: 5,
                        child: Stack(
                          children: <Widget>[
                            StreamBuilder(
                                stream: _profileBloc.profileImageStream,
                                builder: (BuildContext context,
                                    AsyncSnapshot<String> asyncSnapshot) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: asyncSnapshot.data == null
                                        ? Image.asset(
                                            'assets_image/cover.png',
                                            fit: BoxFit.cover,
                                            width: 130.0,
                                            height: 130.0,
                                          )
                                        : CachedNetworkImage(
                                            fit: BoxFit.cover,
                                            width: 130.0,
                                            height: 130.0,
                                            imageUrl:
                                                '${Connect.filesUrl}${asyncSnapshot.data}',
                                            placeholder: (BuildContext context,
                                                String url) {
                                              return Container(
                                                color: Colors.white,
                                                child: Center(
                                                    child:
                                                        CircularProgressIndicator()),
                                                width: 130.0,
                                                height: 130.0,
                                              );
//                                        return Image.asset(
//                                          'assets_image/male-avatar.png',
//                                          width: 130.0,
//                                          height: 130.0,
//                                        );
                                            },
                                          ),
                                  );
                                }),
                            Positioned(
                              top: 5,
                              right: 5,
                              child: widget.userId == Connect.currentUser.userId
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: Container(
                                        color: Colors.black.withOpacity(0.6),
                                        padding: EdgeInsets.all(3),
                                        child: GestureDetector(
                                            onTap: () {
                                              _profileBloc
                                                  .changeProfileCoverImage(
                                                      'profileImage');
                                            },
                                            child: new Icon(
                                              Icons.edit,
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                              size: 15,
                                              // size: .0,
                                            )),
                                      ),
                                    )
                                  : Container(
                                      width: 0,
                                      height: 0,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Center(
                child: StreamBuilder(
                    stream: _profileBloc.nameImageStream,
                    builder: (BuildContext context,
                        AsyncSnapshot<String> asyncSnapshot) {
                      return Text(
                        asyncSnapshot.data == null
                            ? ''
                            : asyncSnapshot.data.length > 20
                                ? '${asyncSnapshot.data.substring(0, 20)}...'
                                : "${asyncSnapshot.data}",
                        style: TextStyle(
                            fontSize: 17.0,
                            color: Colors.black,
                            fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      );
                    }),
              ),
              Container(
                // margin: EdgeInsets.only(top: 0.0),
                padding: EdgeInsets.all(10.0),
                height: MediaQuery.of(context).size.height / 2,
                child: Column(children: <Widget>[
                  TabBar(
                      labelStyle: TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 14.0),
                      indicatorColor: Colors.blue,
                      labelColor: Colors.blue,
                      unselectedLabelColor: Colors.grey,
                      controller: _tabController,
                      tabs: <Widget>[
                        Tab(
                          text: 'Personal',
                        ),
                        Tab(text: 'Location'),
                        Tab(text: 'Contact'),
                      ]),
                  Expanded(
                    child: StreamBuilder(
                        stream: _profileBloc.tabProfileStream,
                        builder: (BuildContext context,
                            AsyncSnapshot<Map<String, dynamic>> asyncSnapshot) {
                          return asyncSnapshot.data == null
                              ? TabBarView(
                                  controller: _tabController,
                                  children: <Widget>[
                                    Center(child: Text('No service')),
                                    Center(child: Text('No service')),
                                    Center(child: Text('No service')),
                                  ],
                                )
                              : _loadTabControllers(asyncSnapshot.data);
                        }),
                  ),
                ]),
              ),
              StreamBuilder(
                  stream: _profileBloc.profileStream,
                  builder: (BuildContext context,
                      AsyncSnapshot<Map<String, dynamic>> asyncSnapshot) {
                    return asyncSnapshot.data == null
                        ? Container(
                            width: 0.0,
                            height: 0.0,
                          )
                        : _profileUpdateFinished(asyncSnapshot.data);
                  }),
            ],
          ),
          padding: EdgeInsets.only(bottom: 30),
        ),
      ),
    );
  }

  Widget _loadTabControllers(Map<String, dynamic> sentUserMap) {
    //print('~~~ sentUserMap: $sentUserMap');
    //print('~~~ _loadTabControllers');
    Future.delayed(Duration.zero, () {
      _userMap = sentUserMap;
    });
    return TabBarView(controller: _tabController, children: <Widget>[
      PersonalPage(userMap: sentUserMap),
      LocationPage(userMap: sentUserMap),
      ContactPage(userMap: sentUserMap)
    ]);
  }

  Widget _profileUpdateFinished(Map<String, dynamic> mapResponse) {
    Future.delayed(Duration.zero, () {
      _profileBloc.profileStreamSink.add(null);

      if (mapResponse['code'] == 200) {
      } else if (mapResponse['code'] == 400) {
        _widgetsCollection.showToastMessage(mapResponse['content']['message']);
      } else {
        _widgetsCollection.showToastMessage(mapResponse['content']['message']);
      }
    });
    return Container(
      width: 0.0,
      height: 0.0,
    );
  }
}
