import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mesbro_chat_flutter_app/bloc_patterns/new_group_bloc.dart';
import 'package:mesbro_chat_flutter_app/models/group_info.dart';
import 'package:mesbro_chat_flutter_app/models/user.dart';
import 'package:mesbro_chat_flutter_app/screens/chat_screens/group_chat_page.dart';
import 'package:mesbro_chat_flutter_app/utils/contact_list_details.dart';
import 'package:mesbro_chat_flutter_app/network/user_connect.dart';
import 'package:mesbro_chat_flutter_app/utils/navigation_actions.dart';
import 'package:mesbro_chat_flutter_app/utils/widgets_collection.dart';

import 'package:mesbro_chat_flutter_app/screens/chat_screens/chat_page.dart';

import '../chat_contact_options_page.dart';

class NewGroupPage extends StatefulWidget {
  _NewGroupPageState createState() => _NewGroupPageState();
}

class _NewGroupPageState extends State<NewGroupPage> {
  final NewGroupBloc _newGroupBloc = NewGroupBloc();
  NavigationActions _navigationActions;
  WidgetsCollection _widgetsCollection;

  Future<bool> _onWillPop() async {
    _navigationActions.closeDialog();
    return false;
  }

  void initState() {
    super.initState();
    _newGroupBloc.searchPersonName('a');
    _navigationActions = NavigationActions(context);
    _widgetsCollection = WidgetsCollection(context);
  }

  void dispose() {
    super.dispose();
    _newGroupBloc.dispose();
  }

  String selectedName;

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'New Group',
            style: TextStyle(
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              _onWillPop();
            },
          ),
          actions: <Widget>[
            GestureDetector(
              child: Center(
                child: Text(
                  'Done',
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 17.0,
                  ),
                ),
              ),
              onTap: () {
                if (_newGroupBloc.selectedUsersList.length < 2) {
                  _widgetsCollection
                      .showToastMessage('Atleast 3 user is required');
                } else if (_newGroupBloc.groupNameBehaviorSubject.value ==
                        null ||
                    _newGroupBloc.groupNameBehaviorSubject.value.length < 2) {
                  _widgetsCollection
                      .showToastMessage('Group name should be more than 1');
                } else {
                  _newGroupBloc.createNewGroup();
                }
              },
            ),
            SizedBox(
              width: 20.0,
            )
          ],
        ),
        body: Container(
          margin:
              EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0, bottom: 0.0),
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(bottom: 0.0, left: 5.0),
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    StreamBuilder(
                      stream: _newGroupBloc.groupNameStream,
                      builder: (BuildContext context,
                          AsyncSnapshot<String> asyncSnapshot) {
                        return Container(
                          child: TextField(
                            onChanged: (String value) {
                              _newGroupBloc.groupNameStreamSink.add(value);
                            },
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                  color: Colors.grey.withOpacity(0.15),
                                )),
                                filled: true,
                                fillColor: Colors.grey.withOpacity(0.15),
                                hintText: 'Group Name',
                                errorText: asyncSnapshot.error),
                          ),
                        );
                      },
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    TextField(
                      onChanged: (String value) {
                        _newGroupBloc.searchPersonName(value);
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.15),
                        )),
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.15),
                        hintText: 'Search Person',
                        labelStyle: TextStyle(
                        ),
                      ),
                    ),
                    StreamBuilder(
                        stream: _newGroupBloc.selectedUsersStream,
                        builder: (BuildContext context,
                            AsyncSnapshot<List<User>> asyncSnapshot) {
                          return asyncSnapshot.data == null
                              ? Container(
                                  margin: EdgeInsets.only(top: 20.0),
                                  height: 50.0,
                                  child: Text(
                                    'No People Selected',
                                    style: TextStyle(
                                    ),
                                  ),
                                )
                              : asyncSnapshot.data.length == 0
                                  ? Container(
                                      margin: EdgeInsets.only(top: 10.0),
                                      height: 50.0,
                                      child: Text(
                                        'No People Selected',
                                        style: TextStyle(
                                        ),
                                      ),
                                    )
                                  : Container(
                                      margin: EdgeInsets.only(
                                          top: 10.0, bottom: 10.0),
                                      height: 80.0,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemCount: asyncSnapshot.data.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          selectedName =
                                              asyncSnapshot.data[index].name;
                                          selectedName = selectedName.substring(
                                              0, selectedName.lastIndexOf(' '));
                                          return Container(
                                            margin:
                                                EdgeInsets.only(right: 10.0),
                                            child: Column(
                                              children: <Widget>[
                                                Stack(
                                                  children: <Widget>[
                                                    ClipOval(
                                                      child: Container(
                                                        width: 40.0,
                                                        height: 40.0,
                                                        child: ClipOval(
                                                          child:
                                                              CachedNetworkImage(
                                                            fit: BoxFit.cover,
                                                            imageUrl:
                                                                '${Connect.filesUrl}${asyncSnapshot.data[index].profileImage}',
                                                            placeholder:
                                                                (BuildContext
                                                                        context,
                                                                    String
                                                                        url) {
                                                              return Image.asset(
                                                                  'assets_image/male-avatar.png');
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      transform: Matrix4
                                                          .translationValues(
                                                              5.0, 7.0, 0.0),
                                                      child: IconButton(
                                                        icon: Icon(
                                                          Icons.close,
                                                          color: Colors.red,
                                                          size: 20.0,
                                                        ),
                                                        onPressed: () {
                                                          _newGroupBloc
                                                              .removeUser(
                                                            asyncSnapshot
                                                                .data[index],
                                                          );
                                                        },
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                Text(selectedName.length > 10
                                                    ? selectedName.substring(
                                                        0, 10)
                                                    : selectedName)
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    );
                        })
                  ],
                ),
              ),
              StreamBuilder(
                stream: _newGroupBloc.usersFoundStream,
                builder: (BuildContext context,
                    AsyncSnapshot<List<User>> asyncSnapshot) {
                  return asyncSnapshot.data == null
                      ? Center(
                          child: Text(
                            'No People Found',
                            style: TextStyle(
                            ),
                          ),
                        )
                      : asyncSnapshot.data.length == 0
                          ? Center(
                              child: Text('No People Found'),
                            )
                          : Expanded(
                              child: ListView.builder(
                                physics: ScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: asyncSnapshot.data.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Column(
                                    children: <Widget>[
                                      ListTile(
                                        onTap: () {
                                          _newGroupBloc.includeNewUser(
                                              asyncSnapshot.data[index]);
                                        },
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
                                          asyncSnapshot
                                                      .data[index].name.length >
                                                  20
                                              ? asyncSnapshot.data[index].name
                                                  .substring(0, 20)
                                              : asyncSnapshot.data[index].name,
                                        ),
                                      ),
                                      Divider()
                                    ],
                                  );
                                },
                              ),
                            );
                },
              ),
              StreamBuilder(
                stream: _newGroupBloc.groupCreatedStream,
                builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
                  return asyncSnapshot.data == null
                      ? Container()
                      : _groupCreatedFinished(asyncSnapshot.data);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _groupCreatedFinished(Map<String, dynamic> mapResponse) {
    Future.delayed(Duration.zero, () {
      _navigationActions.closeDialog();
      _newGroupBloc.groupCreatedStreamSink.add(null);

      if (mapResponse['code'] == 200) {
        GroupInfo _groupInfo = GroupInfo.fromJSON(mapResponse['content']);
//        _navigationActions.closeDialog();
        _navigationActions.navigateToScreenWidget(GroupChatPage(
          groupInfo: _groupInfo,
          previousScreen: 'new_group_page',
        ));
      } else if (mapResponse['code'] == 400) {
        _widgetsCollection.showToastMessage(mapResponse['content']['message']);
      } else {
        _widgetsCollection.showToastMessage(mapResponse['content']['message']);
      }
    });
    return Container();
  }
}
