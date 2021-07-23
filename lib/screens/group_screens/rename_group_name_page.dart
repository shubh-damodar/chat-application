import 'package:flutter/material.dart';
import 'package:mesbro_chat_flutter_app/bloc_patterns/rename_group_name_bloc.dart';
import 'package:mesbro_chat_flutter_app/models/group_info.dart';
import 'package:mesbro_chat_flutter_app/utils/navigation_actions.dart';
import 'package:mesbro_chat_flutter_app/utils/widgets_collection.dart';

import 'package:mesbro_chat_flutter_app/screens/group_screens/group_members_page.dart';

class RenameGroupNamePage extends StatefulWidget {
  final GroupInfo groupInfo;

  RenameGroupNamePage({this.groupInfo});

  _RenameGroupNamePageState createState() =>
      _RenameGroupNamePageState(groupInfo: groupInfo);
}

class _RenameGroupNamePageState extends State<RenameGroupNamePage> {
  final GroupInfo groupInfo;

  _RenameGroupNamePageState({this.groupInfo});
  Future<bool> _onWillPop(BuildContext context) async {
    NavigationActions _navigationActions = NavigationActions(context);
    _navigationActions.navigateToScreenWidgetRoot(
      GroupMembersPage(
        groupInfo: groupInfo,
      ),
    );
    return true;
  }

  final RenameGroupNameBloc _renameGroupNameBloc = RenameGroupNameBloc();
  NavigationActions _navigationActions;
  WidgetsCollection _widgetsCollection;
  TextEditingController _groupNameTextEditingController =
      TextEditingController();
  void initState() {
    super.initState();
    _navigationActions = NavigationActions(context);
    _widgetsCollection = WidgetsCollection(context);
    _groupNameTextEditingController.text = groupInfo.groupName;
    _renameGroupNameBloc.groupNameStreamSink.add(groupInfo.groupName);
    //print('~~~ groupInfo.groupName: ${groupInfo.groupName}');
  }

  void dispose() {
    super.dispose();
    _renameGroupNameBloc.dispose();
    _groupNameTextEditingController.dispose();
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        _onWillPop(context);
      },
      child: Scaffold(
        body: Container(
          margin:
              EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0, bottom: 10.0),
          child: ListView(children: <Widget>[
            StreamBuilder(
              stream: _renameGroupNameBloc.groupNameStream,
              builder:
                  (BuildContext context, AsyncSnapshot<String> asyncSnapshot) {
                return Container(
                  child: TextField(
                    controller: _groupNameTextEditingController,
                    onChanged: (String value) {
                      _renameGroupNameBloc.groupNameStreamSink.add(value);
                    },
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.15),
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.15),
                        hintText: 'Group Name',
                        errorText: asyncSnapshot.error),
                  ),
                );
              },
            ),
            StreamBuilder(
              stream: _renameGroupNameBloc.groupNameCheck,
              builder:
                  (BuildContext context, AsyncSnapshot<bool> asyncSnapshot) {
                return RaisedButton(
                    color: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                    child: Text(
                      'Rename',
                      style:
                          TextStyle(color: Colors.white),
                    ),
                    onPressed: asyncSnapshot.hasData
                        ? () {
                            _widgetsCollection.showMessageDialog();
                            //print(
                                // '~~~ groupInfo.conversationId ${groupInfo.conversationId}');
                            _renameGroupNameBloc
                                .renameGroup(groupInfo.conversationId);
                          }
                        : null);
              },
            ),
            StreamBuilder(
              stream: _renameGroupNameBloc.groupCreatedStream,
              builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
                return asyncSnapshot.data == null
                    ? Container(
                        width: 0.0,
                        height: 0.0,
                      )
                    : _renameGroupNameFinished(asyncSnapshot.data);
              },
            ),
          ]),
        ),
      ),
    );
  }

  Widget _renameGroupNameFinished(Map<String, dynamic> mapResponse) {
    Future.delayed(Duration.zero, () {
      _navigationActions.closeDialogRoot();
      _renameGroupNameBloc.groupCreatedStreamSink.add(null);

      if (mapResponse['code'] == 200) {
        //print('~~~ rename: $mapResponse');
        groupInfo.groupName = _renameGroupNameBloc.typedGroupName;
        _navigationActions
            .navigateToScreenWidgetRoot(GroupMembersPage(groupInfo: groupInfo));
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
