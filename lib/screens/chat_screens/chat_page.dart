import 'dart:collection';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mesbro_chat_flutter_app/bloc_patterns/chat_bloc.dart';
import 'package:mesbro_chat_flutter_app/models/conversation.dart';
import 'package:mesbro_chat_flutter_app/models/group_info.dart';
import 'package:mesbro_chat_flutter_app/network/user_connect.dart';
import 'package:mesbro_chat_flutter_app/notifications/notification_builder.dart';
import 'package:mesbro_chat_flutter_app/screens/group_screens/new_group_page.dart';
import 'package:mesbro_chat_flutter_app/utils/date_category.dart';
import 'package:mesbro_chat_flutter_app/utils/navigation_actions.dart';
import 'package:mesbro_chat_flutter_app/utils/widgets_collection.dart';

import 'package:mesbro_chat_flutter_app/screens/chat_screens/individual_chat_page.dart';

import '../new_conversation_page.dart';
import 'group_chat_page.dart';

class ChatPage extends StatefulWidget {
  final List<Conversation> conversationsList;

  ChatPage({this.conversationsList});

  _ChatPageState createState() =>
      _ChatPageState(conversationsList: conversationsList);
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  final List<Conversation> conversationsList;

  _ChatPageState({this.conversationsList});

  ChatBloc _chatBloc;
  DateCategory _dateCategory = DateCategory();

  NavigationActions _navigationActions;
  WidgetsCollection _widgetsCollection;

  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    //print('~~~ ChatBloc initState: ${conversationsList.length}');
    _chatBloc =
        ChatBloc(conversationsList: conversationsList, buildContext: context);
    _chatBloc.retrieveConversations();
    _chatBloc.listenLatestMessages();
    _navigationActions = NavigationActions(context);
    _widgetsCollection = WidgetsCollection(context);
  }

  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _chatBloc.dispose();
    _chatBloc.webSocketConnect.disposeWebSocketChannel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState appLifecycleState) {
    if (appLifecycleState == AppLifecycleState.paused ||
        appLifecycleState == AppLifecycleState.inactive) {
      _chatBloc.isInBackground = true;
    } else {
      _chatBloc.isInBackground = false;
    }
  }

  void navigateToChatScreen(Widget widget) {
    Navigator.of(context, rootNavigator: false)
        .push(MaterialPageRoute(builder: (context) => widget))
        .then((dynamic) {
      _chatBloc.retrieveConversations();
      GroupChatPage.isGroupMembersOpened = false;
    });
  }

  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
      child: ListView(
        children: <Widget>[
          StreamBuilder(
            stream: _chatBloc.conversationsStream,
            builder: (BuildContext context,
                AsyncSnapshot<List<Conversation>> asyncSnapshot) {
              return asyncSnapshot.data == null
                  ? Center(
                      child: Container(
                        width: 0.0,
                        height: 0.0,
                      ),
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
                                              child: asyncSnapshot
                                                          .data[index]
                                                          .sentUser
                                                          .profileImage ==
                                                      null
                                                  ? Image.asset(
                                                      'assets_image/male-avatar.png',
                                                      fit: BoxFit.cover,
                                                    )
                                                  : CachedNetworkImage(
                                                      fit: BoxFit.cover,
                                                      imageUrl:
                                                          '${Connect.filesUrl}${asyncSnapshot.data[index].sentUser.profileImage}',
                                                      placeholder:
                                                          (BuildContext context,
                                                              String url) {
                                                        return Image.asset(
                                                            'assets_image/male-avatar.png');
                                                      },
                                                    ),
                                            ),
                                          )
                                        : ClipOval(
                                            child: Container(
                                              width: 40.0,
                                              height: 40.0,
                                              color: Colors.blue,
                                              child: Center(
                                                child: Text(
                                                  '${asyncSnapshot.data[index].groupName.substring(0, 1)}',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                    title: Text(
                                      asyncSnapshot.data[index].groupName == ''
                                          ? asyncSnapshot.data[index].sentUser
                                                      .name.length >
                                                  20
                                              ? '${asyncSnapshot.data[index].sentUser.name.substring(0, 20)}...'
                                              : "${asyncSnapshot.data[index].sentUser.name}"
                                          : "${asyncSnapshot.data[index].groupName}",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(
                                      "${asyncSnapshot.data[index].latestMessage}",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: <Widget>[
                                        Text(
                                          '${_dateCategory.sentDate(DateTime.fromMillisecondsSinceEpoch(asyncSnapshot.data[index].updatedAt))}',
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 11),
                                        ),
                                        SizedBox(
                                          height: 15.0,
                                        ),
                                        asyncSnapshot.data[index].unreadCount ==
                                                0
                                            ? Container(
                                                width: 0,
                                                height: 0,
                                              )
                                            : CircleAvatar(
                                                radius: 11,
                                                backgroundColor: Colors.blue,
                                                child: Text(
                                                  "${asyncSnapshot.data[index].unreadCount}",
                                                  style:
                                                      TextStyle(fontSize: 10),
                                                ),
                                              )
                                      ],
                                    ),
                                  ),
                                  Divider(),
                                ],
                              ),
                              onTap: () {
                                //print('~~~ chat_page: onTap');
                                if (asyncSnapshot.data[index].groupName == '') {
                                  navigateToChatScreen(
                                    IndividualChatPage(
                                      sentConversationId: asyncSnapshot
                                          .data[index].conversationId,
                                      sentUser:
                                          asyncSnapshot.data[index].sentUser,
                                      previousScreen: 'chat_page',
                                    ),
                                  );
                                } else {
                                  GroupInfo _groupInfo = GroupInfo(
                                      conversationId: asyncSnapshot
                                          .data[index].conversationId,
                                      groupName:
                                          asyncSnapshot.data[index].groupName,
                                      updatedAt:
                                          asyncSnapshot.data[index].updatedAt,
                                      owner: "${asyncSnapshot.data[index].owners}");
                                  navigateToChatScreen(GroupChatPage(
                                      groupInfo: _groupInfo,
                                      previousScreen: 'chat_page'));
                                }
                              },
                            );
                          },
                        );
            },
          ),
        ],
      ),
    );
  }
}
