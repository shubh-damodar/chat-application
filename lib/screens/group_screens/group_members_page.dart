import 'dart:collection';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mesbro_chat_flutter_app/bloc_patterns/group_members_bloc.dart';
import 'package:mesbro_chat_flutter_app/models/group_info.dart';
import 'package:mesbro_chat_flutter_app/models/user.dart';
// import 'package:mesbro_chat_flutter_app/models/user.dart';
import 'package:mesbro_chat_flutter_app/network/user_connect.dart';
import 'package:mesbro_chat_flutter_app/screens/chat_screens/chat_page.dart';
import 'package:mesbro_chat_flutter_app/screens/chat_screens/group_chat_page.dart';
import 'package:mesbro_chat_flutter_app/screens/chat_screens/individual_chat_page.dart';
import 'package:mesbro_chat_flutter_app/screens/group_screens/rename_group_name_page.dart';
import 'package:mesbro_chat_flutter_app/screens/profile_screens/edit_profile_screens/profile_page.dart';
import 'package:mesbro_chat_flutter_app/utils/date_category.dart';
import 'package:mesbro_chat_flutter_app/utils/navigation_actions.dart';
import 'package:mesbro_chat_flutter_app/utils/widgets_collection.dart';
import 'package:mesbro_chat_flutter_app/models/conversation.dart';

import '../add_new_member_page.dart';
import '../chat_contact_options_page.dart';

class GroupMembersPage extends StatefulWidget {
  final GroupInfo groupInfo;
  final List<Conversation> conversationsList;

  GroupMembersPage({this.groupInfo, this.conversationsList});

  _GroupMembersPageState createState() =>
      _GroupMembersPageState(groupInfo: groupInfo);
}

class _GroupMembersPageState extends State<GroupMembersPage> {
  final GroupInfo groupInfo;
  final List<Conversation> conversationsList;

  _GroupMembersPageState({this.groupInfo, this.conversationsList});

  final GroupMembersBloc _groupMembersBloc = GroupMembersBloc();
  NavigationActions _navigationActions;
  WidgetsCollection _widgetsCollection;

  void initState() {
    super.initState();
    _navigationActions = NavigationActions(context);
    _widgetsCollection = WidgetsCollection(context);
    _groupMembersBloc.getAllMembers(groupInfo.conversationId);
  }

  void navigateToChatScreen(Widget widget) {
    Navigator.of(context, rootNavigator: false)
        .push(MaterialPageRoute(builder: (context) => widget))
        .then((dynamic) {
      _groupMembersBloc.getAllMembers(groupInfo.conversationId);
    });
  }

  void dispose() {
    super.dispose();
    _groupMembersBloc.dispose();
  }

  Future<bool> _onWillPop() async {
    _navigationActions.closeDialog();
    return false;
  }

  double _screenHeight;
  DateCategory _dateCategory = DateCategory();
  Widget build(BuildContext context) {
    _screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Material(
        child: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
                delegate:
                    MySliverAppBar(expandedHeight: 300, groupInfo: groupInfo),
                pinned: true),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Container(
                    margin: EdgeInsets.only(left: 12.0, right: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        StreamBuilder(
                            stream: _groupMembersBloc.usersStream,
                            builder: (BuildContext context,
                                AsyncSnapshot asyncSnapshot) {
                              return Container(
                                // margin: EdgeInsets.only(
                                //   left: 15.0,
                                //   top: 10.0
                                // ),
                                // padding: EdgeInsets.all(15),
                                child: ListTile(
                                    title: Text(
                                      '${asyncSnapshot.data == null ? '0' : asyncSnapshot.data.length == 0 ? '0' : asyncSnapshot.data.length} members',
                                      style: TextStyle(
                                          color: Theme.of(context).accentColor,
                                          fontSize: 18.0,
                                          ),
                                    ),
                                    trailing: Text(
                                      _dateCategory.dMMMyyhma.format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            groupInfo.updatedAt),
                                      ),
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15.0,
                                          ),
                                    )),
                              );
                            }),
                        SizedBox(
                          height: 10.0,
                        ),
                        GestureDetector(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).accentColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white),
                                ),
                                padding: EdgeInsets.all(0.5),
                                width: 45.0,
                                height: 45.0,
                                child: Center(
                                  child: ClipOval(
                                    child: Icon(
                                      Icons.person_add,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 15.0,
                              ),
                              Text(
                                'Add members',
                                style: TextStyle(
                                    fontSize: 18.0, ),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                            ],
                          ),
                          onTap: () {
                            navigateToChatScreen(AddNewMemberPage(
                                groupInfo: groupInfo,
                                membersList: _groupMembersBloc.usersList));
                          },
                        ),
                        Divider(),
                      ],
                    ),
                  ),
                  StreamBuilder(
                    stream: _groupMembersBloc.usersStream,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<User>> asyncSnapshot) {
                      return asyncSnapshot.data == null
                          ? Container()
                          : asyncSnapshot.data.length == 0
                              ? Container()
                              : ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: asyncSnapshot.data.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return PopupMenuButton<String>(
                                      child: ListTile(
                                        leading: ClipOval(
                                          child: Container(
                                            width: 40.0,
                                            height: 40.0,
                                            child: ClipOval(
                                              child: CachedNetworkImage(
                                                fit: BoxFit.cover,
                                                imageUrl:
                                                    '${Connect.filesUrl}${asyncSnapshot.data[index].profileImage}',
                                                placeholder:
                                                    (BuildContext context,
                                                        String url) {
                                                  return Image.asset(
                                                      'assets_image/male-avatar.png');
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                            asyncSnapshot.data[index].name),
                                      ),
                                      onSelected:
                                          (String memberSettingsOption) {
                                        switch (memberSettingsOption) {
                                          // case 'Chat':
                                          //   _navigationActions
                                          //       .navigateToScreenWidget(IndividualChatPage(
                                          //           sentConversationId:
                                          //               asyncSnapshot.data[index].sentConversationId,
                                          //           previousScreen:
                                          //               'group_members_page'));
                                          //   break;
                                          case 'View profile':
                                            navigateToChatScreen(ProfilePage(
                                              userId: asyncSnapshot
                                                  .data[index].userId,
                                              previousScreen:
                                                  'group_members_page',
                                            ));
                                            break;
                                          default:
                                            if (Connect.currentUser.userId ==
                                                asyncSnapshot
                                                    .data[index].userId) {
                                              showActionDialog(
                                                  'Leave group?',
                                                  asyncSnapshot
                                                      .data[index].userId);
                                              // showActionDialog(null, 'chat');
                                            } else {
                                              showActionDialog(
                                                  'Remove member?',
                                                  asyncSnapshot
                                                      .data[index].userId);
                                              // showActionDialog(null, 'chat');
                                            }
                                            break;
                                        }
                                      },
//                                          itemBuilder: (BuildContext context) {
//                                            return _settingsRouteLinkedHashMap
//                                                .keys
//                                                .toList()
//                                                .map((String
//                                                    memberSettingsOption) {
//                                              return PopupMenuItem<String>(
//                                                value: memberSettingsOption,
//                                                child:
//                                                    Text(memberSettingsOption),
//                                              );
//                                            }).toList();
//                                          },
                                      itemBuilder: (BuildContext context) {
                                        return <PopupMenuItem<String>>[
                                          // PopupMenuItem<String>(
                                          //   value: 'Chat',
                                          //   child: Text(
                                          //     'Chat',
                                          //     style: TextStyle(
                                          //         ),
                                          //   ),
                                          // ),
                                          PopupMenuItem<String>(
                                            value: 'View profile',
                                            child: Text(
                                              'View profile',
                                              style: TextStyle(
                                                  ),
                                            ),
                                          ),
                                          PopupMenuItem<String>(
                                              value:
                                                  '${Connect.currentUser.userId == asyncSnapshot.data[index].userId ? 'Leave group' : 'Remove member'}',
                                              child: Text(
                                                '${Connect.currentUser.userId == asyncSnapshot.data[index].userId ? 'Leave group' : 'Remove member'}',
                                                style: TextStyle(
                                                    ),
                                              )),
                                        ];
                                      },
                                    );
                                  },
                                );
                    },
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 15.0, right: 15.0),
                    child: OutlineButton(
                      child: Text(
                        'Delete',
                      ),
                      onPressed: () {
                        _widgetsCollection.showActionDialog(
                            'Confirm deletion?',
                            _groupMembersBloc.deleteConversation,
                            _navigationActions.closeDialog);
                      },
                    ),
                  ),
                  StreamBuilder(
                    stream: _groupMembersBloc.removeUserStream,
                    builder: (BuildContext context,
                        AsyncSnapshot<Map<String, dynamic>> asyncSnapshot) {
                      return asyncSnapshot.data == null
                          ? Container(
                              width: 20.0,
                              height: 20.0,
                            )
                          : _removingFinished(asyncSnapshot.data);
                    },
                  ),
                  StreamBuilder(
                    stream: _groupMembersBloc.leaveGroupStream,
                    builder: (BuildContext context,
                        AsyncSnapshot<Map<String, dynamic>> asyncSnapshot) {
                      return asyncSnapshot.data == null
                          ? Container(
                              width: 0.0,
                              height: 0.0,
                            )
                          : _leavingFinished(asyncSnapshot.data);
                    },
                  ),
                  StreamBuilder(
                    stream: _groupMembersBloc.messageDeletedStream,
                    builder: (BuildContext context,
                        AsyncSnapshot<Map<String, dynamic>> asyncSnapshot) {
                      return asyncSnapshot.data == null
                          ? Container(
                              width: 0.0,
                              height: 0.0,
                            )
                          : _deletingFinished(asyncSnapshot.data);
                    },
                  ),
                  SizedBox(
                    height: 20.0,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

//  void showActionDialog(String message, String userId) {
//    showDialog(
//        context: context,
//        builder: (BuildContext context) {
//          return SimpleDialog(
//            children: <Widget>[
//              SizedBox(
//                height: 15.0,
//              ),
//              Center(
//                  child: Text(
//                message,
//                style: TextStyle(fontSize: 18.0),
//              )),
//              SizedBox(
//                height: 20.0,
//              ),
//              Row(
//                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                  children: <Widget>[
//                    FlatButton(
//                        child: Text('Yes'),
//                        onPressed: () {
//                          _navigationActions.closeDialog();
//                          if (userId == Connect.currentUser.userId) {
//                            _groupMembersBloc.removeMemberFromGroup(userId);
//                            _navigationActions.closeDialog();
//                          }
//                        }),
//                    FlatButton(
//                        child: Text('No'),
//                        onPressed: _navigationActions.closeDialog),
//                  ])
//            ],
//          );
//        });
//  }

  void showActionDialog(String message, String userId) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            children: <Widget>[
              SizedBox(
                height: 15.0,
              ),
              Center(
                  child: Text(
                message,
                style: TextStyle(fontSize: 18.0, ),
              )),
              SizedBox(
                height: 20.0,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FlatButton(
                        child: Text(
                          'Yes',
                        ),
                        onPressed: () {
                          _navigationActions.closeDialog();
                          if (Connect.currentUser.userId == userId) {
                            _groupMembersBloc.leaveGroup(userId);
                          } else {
                            _groupMembersBloc.removeMemberFromGroup(userId);
                          }
                        }),
                    FlatButton(
                        child: Text(
                          'No',
                        ),
                        onPressed: _navigationActions.closeDialog),
                  ])
            ],
          );
        });
  }

  Widget _removingFinished(Map<String, dynamic> mapResponse) {
    Future.delayed(Duration.zero, () {
      _groupMembersBloc.removeUserStreamSink.add(null);

      if (mapResponse['code'] == 200) {
        _groupMembersBloc.removeMember();
      } else if (mapResponse['code'] == 400) {
        _widgetsCollection.showToastMessage(mapResponse['content']['message']);
      } else {
        _widgetsCollection.showToastMessage(mapResponse['content']['message']);
      }
    });
    return Container(
      width: 20.0,
      height: 20.0,
    );
  }

  Widget _leavingFinished(Map<String, dynamic> mapResponse) {
    Future.delayed(Duration.zero, () {
      _groupMembersBloc.leaveGroupStreamSink.add(null);

      if (mapResponse['code'] == 200) {
        _navigationActions.closeDialog();
        _navigationActions.closeDialog();
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

  Widget _deletingFinished(Map<String, dynamic> mapResponse) {
    Future.delayed(Duration.zero, () {
      _groupMembersBloc.messageDeletedStreamSink.add(null);

      if (mapResponse['code'] == 200) {
        _navigationActions.closeDialog();
        _navigationActions.closeDialog();
        _navigationActions.closeDialog();
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

class MySliverAppBar extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final GroupInfo groupInfo;

  MySliverAppBar({@required this.expandedHeight, this.groupInfo});

  DateCategory _dateCategory = DateCategory();

  Future<bool> _onWillPop(BuildContext context) async {
    NavigationActions _navigationActions = NavigationActions(context);
    _navigationActions.navigateToScreenWidgetRoot(GroupChatPage(
      groupInfo: groupInfo,
    ));
    return true;
  }

  NavigationActions _navigationActions;
  WidgetsCollection _widgetsCollection;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    _navigationActions = NavigationActions(context);
    _widgetsCollection = WidgetsCollection(context);
    return WillPopScope(
        onWillPop: () {
          _onWillPop(context);
        },
        child: Stack(
          fit: StackFit.expand,
          overflow: Overflow.visible,
          children: [
            // Padding(
            //   padding: EdgeInsets.only(top: 40.0),
            //   child: Container(
            //     height: 10,
            //   ),
            // ),
            CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl: '',
              placeholder: (BuildContext context, String url) {
                return Image.asset(
                  'assets_image/cover.png',
                  fit: BoxFit.cover,
                );
              },
            ),
            Positioned(
                child: Align(
                    alignment: FractionalOffset.topLeft,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        _onWillPop(context);
                      },
                    ))),
            Positioned(
              child: Align(
                alignment: FractionalOffset.topRight,
                child: IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    _navigationActions.navigateToScreenWidgetRoot(
                        RenameGroupNamePage(groupInfo: groupInfo));
                  },
                ),
              ),
            ),
            Center(
              child: Opacity(
                opacity: shrinkOffset / expandedHeight,
                child: Text(
                  groupInfo.groupName,
                  style: TextStyle(
                      color: Colors.white, fontSize: 20, ),
                ),
              ),
            ),
            Positioned(
              top: expandedHeight / 1.2 - shrinkOffset,
              left: MediaQuery.of(context).size.width / 10,
              child: Opacity(
                opacity: (1 - shrinkOffset / expandedHeight),
                child: Container(
                  child: Text(
                    groupInfo.groupName,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
