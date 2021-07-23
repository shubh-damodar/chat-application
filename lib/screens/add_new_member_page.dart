import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mesbro_chat_flutter_app/bloc_patterns/add_new_member_bloc.dart';
import 'package:mesbro_chat_flutter_app/models/group_info.dart';
import 'package:mesbro_chat_flutter_app/models/user.dart';
import 'package:mesbro_chat_flutter_app/network/user_connect.dart';
import 'package:mesbro_chat_flutter_app/utils/navigation_actions.dart';
import 'package:mesbro_chat_flutter_app/utils/widgets_collection.dart';

import 'chat_screens/group_chat_page.dart';

class AddNewMemberPage extends StatefulWidget {
  final GroupInfo groupInfo;
  final List<User> membersList;
  AddNewMemberPage({this.groupInfo, this.membersList});
  _AddNewMemberPageState createState() =>
      _AddNewMemberPageState(groupInfo: groupInfo, membersList: membersList);
}

class _AddNewMemberPageState extends State<AddNewMemberPage> {
  final GroupInfo groupInfo;
  final List<User> membersList;
  _AddNewMemberPageState({this.groupInfo, this.membersList});
  AddNewMemberBloc _addNewMemberBloc;
  NavigationActions _navigationActions;
  WidgetsCollection _widgetsCollection;
  String selectedName;
  Future<bool> _onWillPop() async {
    _navigationActions.closeDialog();
    return true;
  }

  void initState() {
    super.initState();
    _addNewMemberBloc = AddNewMemberBloc(
        membersList: membersList, conversationId: groupInfo.conversationId);
    _addNewMemberBloc.searchPersonName('');
    _navigationActions = NavigationActions(context);
    _widgetsCollection = WidgetsCollection(context);
  }

  void dispose() {
    super.dispose();
    _addNewMemberBloc.dispose();
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'New Member',
          
          ),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                _onWillPop();
              }),
          actions: <Widget>[
            GestureDetector(
                child: Center(
                    child: Text(
                  'Add',
                  maxLines: 1,
                  style: TextStyle(fontSize: 17.0, ),
                )),
                onTap: () {
                  if (_addNewMemberBloc.selectedUsersList.length > 0) {
                    _widgetsCollection.showMessageDialog();
                    _addNewMemberBloc.addNewMembers();
                  } else {
                    _widgetsCollection
                        .showToastMessage('Atleast 1 user is required');
                  }
                }),
            SizedBox(
              width: 20.0,
            )
          ],
        ),
        body: Container(
          margin:
              EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0, bottom: 10.0),
          child: Column(children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 0.0, left: 5.0),
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  TextField(
                  
                    onChanged: (String value) {
                      _addNewMemberBloc.searchPersonName(value);
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.15),
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.grey.withOpacity(0.15),
                      hintText: 'Search Person',
                    ),
                  ),
                  StreamBuilder(
                      stream: _addNewMemberBloc.selectedMembersStream,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<User>> asyncSnapshot) {
                        return asyncSnapshot.data == null
                            ? Container(
                                margin: EdgeInsets.only(top: 20.0),
                                height: 50.0,
                                child: Text('No People Selected'),
                              )
                            : asyncSnapshot.data.length == 0
                                ? Container(
                                    margin: EdgeInsets.only(top: 10.0),
                                    height: 50.0,
                                    child: Text('No People Selected'),
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
                                          margin: EdgeInsets.only(right: 10.0),
                                          child: Column(children: <Widget>[
                                            Stack(children: <Widget>[
                                              ClipOval(
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
                                              Container(
                                                transform:
                                                    Matrix4.translationValues(
                                                        5.0, 7.0, 0.0),
                                                child: IconButton(
                                                    icon: Icon(
                                                      Icons.close,
                                                      color: Colors.red,
                                                      size: 20.0,
                                                    ),
                                                    onPressed: () {
                                                      _addNewMemberBloc
                                                          .removeUser(
                                                              asyncSnapshot
                                                                  .data[index]);
                                                    }),
                                              ),
                                            ]),
                                            Text(selectedName.length > 20
                                                ? selectedName.substring(0, 20)
                                                : selectedName)
                                          ]),
                                        );
                                      },
                                    ),
                                  );
                      })
                ],
              ),
            ),
            StreamBuilder(
              stream: _addNewMemberBloc.usersFoundStream,
              builder: (BuildContext context,
                  AsyncSnapshot<List<User>> asyncSnapshot) {
                return asyncSnapshot.data == null
                    ? Center(
                        child: Text(
                          'No People Found',
                    
                        ),
                      )
                    : asyncSnapshot.data.length == 0
                        ? Center(
                            child: Text(
                              'No People Found',
                              
                            ),
                          )
                        : Expanded(
                            child: ListView.builder(
                                physics: ScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: asyncSnapshot.data.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Column(children: <Widget>[
                                    ListTile(
                                      onTap: () {
                                        _addNewMemberBloc.includeNewUser(
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
                                      title:
                                          Text(asyncSnapshot.data[index].name),
                                    ),
                                    Divider()
                                  ]);
                                }),
                          );
              },
            ),
            StreamBuilder(
                stream: _addNewMemberBloc.membersAddedStream,
                builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
                  return asyncSnapshot.data == null
                      ? Container()
                      : _membersAddedFinished(asyncSnapshot.data);
                }),
          ]),
        ),
      ),
    );
  }

  Widget _membersAddedFinished(Map<String, dynamic> mapResponse) {
    Future.delayed(Duration.zero, () {
      _navigationActions.closeDialog();
      _addNewMemberBloc.membersAddedStreamSink.add(null);

      if (mapResponse['code'] == 200) {
        _navigationActions.closeDialog();
//        _navigationActions.navigateToScreenWidgetRoot(GroupChatPage(groupInfo: groupInfo));
      } else if (mapResponse['code'] == 400) {
        _widgetsCollection.showToastMessage(mapResponse['content']['message']);
      } else {
        _widgetsCollection.showToastMessage(mapResponse['content']['message']);
      }
    });
    return Container();
  }
}
