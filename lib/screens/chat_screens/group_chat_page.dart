import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_selectable_text/flutter_selectable_text.dart';
import 'package:mesbro_chat_flutter_app/bloc_patterns/group_chat_bloc.dart';
import 'package:mesbro_chat_flutter_app/models/group_chat_bubble.dart';
import 'package:mesbro_chat_flutter_app/models/group_info.dart';
import 'package:mesbro_chat_flutter_app/network/user_connect.dart';
import 'package:mesbro_chat_flutter_app/utils/date_category.dart';
import 'package:mesbro_chat_flutter_app/utils/navigation_actions.dart';
import 'package:mesbro_chat_flutter_app/utils/widgets_collection.dart';
import 'package:mesbro_chat_flutter_app/screens/group_screens/group_members_page.dart';
import '../chat_contact_options_page.dart';

class GroupChatPage extends StatefulWidget {
  final GroupInfo groupInfo;
  final String previousScreen;
  static bool isGroupMembersOpened = false;

  GroupChatPage({this.groupInfo, this.previousScreen});

  _GroupChatPageState createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final GroupChatBloc _groupChatBloc = GroupChatBloc();

  TextEditingController _messageTextEditingController = TextEditingController();
  NavigationActions _navigationActions;
  WidgetsCollection _widgetsCollection;
  DateCategory _dateCategory;
  double _screenHeight;
  final double avatarRadius = 20.0,
      defaultIconButtonPadding = 8.0,
      leftOffset = -25.0,
      titleLineHeight = 2.0;
  final ScrollController _scrollController = ScrollController();
  bool _isCurrentUser;

  Future<bool> _onWillPop() async {
    if (GroupChatPage.isGroupMembersOpened) {
      _navigationActions.navigateToScreenWidgetRoot(ChatContactOptionsPage());
    } else {
      _navigationActions.closeDialog();
    }
//    if(previousScreen=='new_group_page') {
//      //print('~~~ 1st _onWillPop');
//      _navigationActions.navigateToScreenWidgetRoot(ChatContactOptionsPage());
//    } else {
//      //print('~~~ 2nd _onWillPop');
//      _navigationActions.closeDialog();
//    }
    return false;
  }

  void initState() {
    super.initState();

    _navigationActions = NavigationActions(context);
    _widgetsCollection = WidgetsCollection(context);
//    _groupChatBloc.listenLatestMessages();
    _dateCategory = DateCategory();
    _groupChatBloc.retrieveAllChatBubbles(widget.groupInfo.conversationId);
    _groupChatBloc.listenLatestMessages();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _groupChatBloc.groupChatBubblesList.length % 20 == 0) {
        //print('~~~ _scrollController: ');
        _groupChatBloc.fetchFurtherChatBubbles();
      }
    });
  }

  Widget build(BuildContext context) {
    _screenHeight = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
//            leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () {
//              _onWillPop();
//            }),
          title: GestureDetector(
            child: SizedBox(
              width: double.infinity,
              child: Stack(
                overflow: Overflow.visible,
                children: <Widget>[
                  Positioned(
                    left: leftOffset,
                    top: defaultIconButtonPadding,
                    child: Container(
                      width: 40.0,
                      height: 40.0,
                      child: ClipOval(
                        child: Container(
                          width: 40.0,
                          height: 40.0,
                          color: Colors.blue,
                          child: Center(
                            child: Text(
                              '${widget.groupInfo.groupName.substring(0, 1)}',
                              style: TextStyle(
                                  color: Colors.white, ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: leftOffset + avatarRadius * 2 + 8.0,
                    top: defaultIconButtonPadding +
                        avatarRadius / 2 -
                        titleLineHeight,
                    child: Text(
                        widget.groupInfo.groupName == ''
                            ? widget.groupInfo.groupName
                            : widget.groupInfo.groupName.length > 20
                                ? '${widget.groupInfo.groupName.substring(0, 20)}....'
                                : widget.groupInfo.groupName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 17.0,
                            )),
                  )
                ],
              ),
            ),
            onTap: () {
              GroupChatPage.isGroupMembersOpened = true;
              _navigationActions.navigateToScreenWidget(
                (GroupMembersPage(
                  groupInfo: widget.groupInfo,
                )),
              );
            },
          ),
          actions: <Widget>[
            // IconButton(
            //   icon: Icon(
            //     Icons.more_vert,
            //     color: Colors.white,
            //   ),
            // )
          ],
        ),
        body: Container(
          margin: EdgeInsets.only(top: 2.0, bottom: 0.0, left: 0.0, right: 0.0),
          child: Stack(
            children: <Widget>[
              StreamBuilder(
                  initialData: null,
                  stream: _groupChatBloc.groupChatBubblesStream,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<GroupChatBubble>> asyncSnapshot) {
                    return asyncSnapshot.data == null
                        ? Container()
                        : Container(
                            color: Colors.white,
                            margin: EdgeInsets.only(
                                bottom: _screenHeight * 0.1,
                                left: 10.0,
                                right: 10.0),
                            child: ListView.builder(
                              controller: _scrollController,
                              reverse: true,
                              shrinkWrap: false,
                              itemCount: asyncSnapshot.data.length,
                              itemBuilder: (BuildContext context, int index) {
                                _isCurrentUser =
                                    asyncSnapshot.data[index].user.userId ==
                                        Connect.currentUser.userId;
                                return Row(
                                    mainAxisAlignment: _isCurrentUser
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      asyncSnapshot.data[index].user.userId ==
                                              Connect.currentUser.userId
                                          ? SizedBox(width: 20.0)
                                          : SizedBox(
                                              width: 0.0,
                                              height: 0.0,
                                            ),
                                      Flexible(
                                        child: GestureDetector(
                                            onTap: () {
                                              ClipboardData clipboardData =
                                                  ClipboardData(
                                                      text: asyncSnapshot
                                                          .data[index].text);
                                              Clipboard.setData(clipboardData);
                                              _widgetsCollection
                                                  .showToastMessage('Copied');
                                            },
                                            child: Container(
                                              margin:
                                                  EdgeInsets.only(bottom: 10.0),
                                              decoration: BoxDecoration(
                                                color: _isCurrentUser
                                                    ? Theme.of(context)
                                                        .accentColor
                                                    : Colors.grey
                                                        .withOpacity(0.15),
                                                borderRadius: BorderRadius.only(
                                                  topLeft:
                                                      Radius.circular(10.0),
                                                  bottomLeft:
                                                      Radius.circular(10.0),
                                                  bottomRight:
                                                      Radius.circular(10.0),
                                                ),
                                              ),
                                              padding: EdgeInsets.all(10.0),
                                              child: Column(
                                                  crossAxisAlignment:
                                                      _isCurrentUser
                                                          ? CrossAxisAlignment
                                                              .end
                                                          : CrossAxisAlignment
                                                              .start,
//                                              mainAxisAlignment:
//                                                  MainAxisAlignment.end,
                                                  children: <Widget>[
                                                    _isCurrentUser
                                                        ? Container(
                                                            width: 0.0,
                                                            height: 0.0,
                                                          )
                                                        : Text(
                                                            asyncSnapshot
                                                                .data[index]
                                                                .user
                                                                .name,
                                                            softWrap: true,
                                                            style: TextStyle(
                                                                fontSize: 15.0,
                                                                
                                                                color: Theme.of(
                                                                        context)
                                                                    .accentColor),
                                                          ),
                                                    Text(
                                                      asyncSnapshot
                                                          .data[index].text,
                                                      softWrap: true,
                                                      style: TextStyle(
                                                          fontSize: 15.0,
                                                          color: _isCurrentUser
                                                              ? Colors.white
                                                              : Colors.black,
                                                          ),
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: 10.0),
                                                      child: Text(
                                                        '${(_dateCategory.dMMMyyhma.format(DateTime.fromMillisecondsSinceEpoch(asyncSnapshot.data[index].addedAt))).toString()}',
                                                        style: TextStyle(
                                                          
                                                          fontSize: 12.0,
                                                          color: _isCurrentUser
                                                              ? Colors.white
                                                              : Colors.grey,
                                                        ),
                                                      ),
                                                    ),
                                                  ]),
                                            )),
                                      ),
                                      asyncSnapshot.data[index].user.userId ==
                                              Connect.currentUser.userId
                                          ? SizedBox(
                                              width: 0.0,
                                              height: 0.0,
                                            )
                                          : SizedBox(width: 20.0),
                                    ]);
                              },
                            ),
                          );
                  }),
              Positioned(
                  child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: StreamBuilder(
                  stream: _groupChatBloc.newMessageStream,
                  builder: (BuildContext context,
                      AsyncSnapshot<String> asyncSnapshot) {
                    return Container(
                      margin: EdgeInsets.only(
                          left: 10.0, right: 10.0, top: 0.0, bottom: 10.0),
                      child: Material(
                        borderRadius: BorderRadius.circular(30.0),
                        elevation: 2,
                        child: Container(
                          child: TextField(
                            maxLines: null,
                            controller: _messageTextEditingController,
                            // cursorColor: Colors.black12,
                            keyboardType: TextInputType.multiline,

                            onChanged: (String value) {
                              _groupChatBloc.newMessageStreamSink.add(value);
                            },
                            decoration: InputDecoration(
                              filled: true,
                              hasFloatingPlaceholder: true,
                              contentPadding: EdgeInsets.all(15),
                              hintMaxLines: 2,
                              // prefixIcon: Icon(Icons.search,
                              //     color: Colors.black45, size: 30),
                              hintText: "Type Your Message Here",
                              hintStyle: TextStyle(color: Colors.black26),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide: BorderSide.none),
                              suffixIcon: IconButton(
                                  icon: Icon(Icons.send),
                                  onPressed: () {
                                    if (_messageTextEditingController.text.trim() !=
                                        '') {
                                      _groupChatBloc.transferMessage();
                                      _messageTextEditingController.text = '';
                                    }
                                  }
                                  // _messageTextEditingController.clear(),
                                  ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }
}
