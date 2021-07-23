import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mesbro_chat_flutter_app/bloc_patterns/search_chat_bloc.dart';
import 'package:mesbro_chat_flutter_app/models/conversation.dart';
import 'package:mesbro_chat_flutter_app/models/group_info.dart';
import 'package:mesbro_chat_flutter_app/network/user_connect.dart';
import 'package:mesbro_chat_flutter_app/utils/date_category.dart';
import 'package:mesbro_chat_flutter_app/utils/navigation_actions.dart';
import 'package:mesbro_chat_flutter_app/utils/widgets_collection.dart';

import 'chat_contact_options_page.dart';
import 'chat_screens/chat_page.dart';
import 'chat_screens/group_chat_page.dart';
import 'chat_screens/individual_chat_page.dart';

class SearchChatPage extends StatefulWidget {
  _SearchChatPageState createState() => _SearchChatPageState();
}

class _SearchChatPageState extends State<SearchChatPage> {
  SearchChatBloc _searchChatBloc = SearchChatBloc();
  DateCategory _dateCategory = DateCategory();
  NavigationActions _navigationActions;
  WidgetsCollection _widgetsCollection;

  Future<bool> _onWillPop() async {
    _navigationActions.closeDialog();
    return false;
  }

  void initState() {
    super.initState();
    //print('~~~ _SearchChatPageState');

    _navigationActions = NavigationActions(context);
    _widgetsCollection = WidgetsCollection(context);
//    _searchChatBloc.searchPersonMemberName('');
  }

  void dispose() {
    super.dispose();
    _searchChatBloc.dispose();
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: 0.0,
          title: StreamBuilder(
              stream: _searchChatBloc.messagePersonStream,
              builder:
                  (BuildContext context, AsyncSnapshot<String> asyncSnapshot) {
                return Container(
                    color: Colors.white,
                    width: double.infinity,
                    child: TextField(
                      autofocus: true,
                      onChanged: (String value) {
                        _searchChatBloc.searchPersonMemberName(value);
                      },
                      decoration: InputDecoration(
                        prefix: Container(
                            transform:
                                Matrix4.translationValues(0.0, 10.0, 0.0),
                            child: IconButton(
                              icon: Icon(
                                Icons.arrow_back,
                                color: Theme.of(context).accentColor,
                              ),
                              onPressed: _onWillPop,
                            )),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.15),
                        )),
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.15),
                        hintText: 'Search....',
                      ),
                    ));
              }),
        ),
        body: Container(
            margin: EdgeInsets.only(
                left: 10.0, right: 10.0, top: 10.0, bottom: 10.0),
            child: ListView(children: <Widget>[
              StreamBuilder(
                  stream: _searchChatBloc.conversationsFoundStream,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Conversation>> asyncSnapshot) {
                    return asyncSnapshot.data == null
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : asyncSnapshot.data.length == 0
                            ? Center(
                                child: Text(
                                  'No Conversations yet',
                                ),
                              )
                            : ListView.builder(
                                physics: ScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: asyncSnapshot.data.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    child: Column(
                                      children: <Widget>[
                                        ListTile(
                                          leading: asyncSnapshot
                                                      .data[index].groupName ==
                                                  ''
                                              ? Container(
                                                  width: 40.0,
                                                  height: 40.0,
                                                  child: ClipOval(
                                                      child: CachedNetworkImage(
                                                    fit: BoxFit.cover,
                                                    imageUrl:
                                                        '${Connect.filesUrl}${asyncSnapshot.data[index].sentUser.profileImage}',
                                                    placeholder:
                                                        (BuildContext context,
                                                            String url) {
                                                      return Image.asset(
                                                          'assets_image/male-avatar.png');
                                                    },
                                                  )))
                                              : ClipOval(
                                                  child: Container(
                                                      width: 40.0,
                                                      height: 40.0,
                                                      color: Theme.of(context)
                                                          .accentColor,
                                                      child: Center(
                                                          child: Text(
                                                        '${asyncSnapshot.data[index].groupName.substring(0, 1)}',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      )))),
                                          title: Text(
                                            asyncSnapshot.data[index]
                                                        .groupName ==
                                                    ''
                                                ? asyncSnapshot
                                                            .data[index]
                                                            .sentUser
                                                            .name
                                                            .length >
                                                        20
                                                    ? '${asyncSnapshot.data[index].sentUser.name.substring(0, 20)}...'
                                                    : asyncSnapshot.data[index]
                                                        .sentUser.name
                                                : asyncSnapshot
                                                    .data[index].groupName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(),
                                          ),
                                          subtitle: Text(
                                              asyncSnapshot
                                                  .data[index].latestMessage,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis),
                                          trailing: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Text(
                                                '${_dateCategory.sentDate(DateTime.fromMillisecondsSinceEpoch(asyncSnapshot.data[index].updatedAt))}',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10.0,
                                              ),
                                              asyncSnapshot.data[index]
                                                          .unreadCount ==
                                                      0
                                                  ? Container(
                                                      width: 25.0,
                                                      height: 25.0,
                                                    )
                                                  : ClipOval(
                                                      child: Container(
                                                          width: 25.0,
                                                          height: 25.0,
                                                          color:
                                                              Theme.of(context)
                                                                  .accentColor,
                                                          child: Center(
                                                              child: Text(
                                                            '${asyncSnapshot.data[index].unreadCount}',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ))))
                                            ],
                                          ),
                                        ),
                                        Divider()
                                      ],
                                    ),
                                    onTap: () {
                                      if (asyncSnapshot.data[index].groupName ==
                                          '') {
                                        _navigationActions
                                            .navigateToScreenWidgetRoot(
                                                IndividualChatPage(
                                          sentConversationId: asyncSnapshot
                                              .data[index].conversationId,
                                          sentUser: asyncSnapshot
                                              .data[index].sentUser,
                                        ));
                                      } else {
                                        GroupInfo _groupInfo = GroupInfo(
                                            conversationId: asyncSnapshot
                                                .data[index].conversationId,
                                            groupName: asyncSnapshot
                                                .data[index].groupName,
                                            updatedAt: asyncSnapshot
                                                .data[index].updatedAt,
                                            owner:
                                                "${asyncSnapshot.data[index].owners}");
                                        _navigationActions
                                            .navigateToScreenWidgetRoot(
                                                GroupChatPage(
                                                    groupInfo: _groupInfo));
                                      }
                                    },
                                  );
                                });
                  }),
            ])),
      ),
    );
  }
}
