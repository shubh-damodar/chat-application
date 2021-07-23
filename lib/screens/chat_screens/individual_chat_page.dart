import 'dart:collection';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_selectable_text/flutter_selectable_text.dart';
import 'package:mesbro_chat_flutter_app/bloc_patterns/individual_chat_bloc.dart';
import 'package:mesbro_chat_flutter_app/models/chat_bubble.dart';
import 'package:mesbro_chat_flutter_app/models/user.dart';
import 'package:mesbro_chat_flutter_app/network/user_connect.dart';
import 'package:mesbro_chat_flutter_app/network/web_socket_connect.dart';
import 'package:mesbro_chat_flutter_app/screens/profile_screens/edit_profile_screens/profile_page.dart';
import 'package:mesbro_chat_flutter_app/utils/date_category.dart';
import 'package:mesbro_chat_flutter_app/utils/navigation_actions.dart';
import 'package:mesbro_chat_flutter_app/utils/widgets_collection.dart';

import '../chat_contact_options_page.dart';

class IndividualChatPage extends StatefulWidget {
  final User sentUser;
  final String sentConversationId, previousScreen;

  IndividualChatPage(
      {this.sentConversationId, this.sentUser, this.previousScreen});

  _IndividualChatPageState createState() => _IndividualChatPageState();
}

class _IndividualChatPageState extends State<IndividualChatPage> {
  bool _validate = false;
  List<String> _settingsList = ['Delete Conversation'];
  NavigationActions _navigationActions;
  WidgetsCollection _widgetsCollection;
  DateCategory _dateCategory;
  double _screenHeight, _screenWidth;
  final double avatarRadius = 20.0,
      defaultIconButtonPadding = 8.0,
      leftOffset = -25.0,
      titleLineHeight = 2.0;
  final IndividualChatBloc _individualChatBloc = IndividualChatBloc();
  TextEditingController _messageTextEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void initState() {
    super.initState();
    _navigationActions = NavigationActions(context);
    _widgetsCollection = WidgetsCollection(context);
    _individualChatBloc.listenLatestMessages();
    _dateCategory = DateCategory();
    //print('~~~~ initState');
    SchedulerBinding.instance.addPostFrameCallback((Duration duration) {
      _individualChatBloc.retrieveAllChatBubbles(widget.sentConversationId);
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _individualChatBloc.chatBubblesList.length % 20 == 0) {
        //print('~~~ _scrollController: ');
        _individualChatBloc.fetchFurtherChatBubbles();
      }
    });
  }

  void dispose() {
    super.dispose();
    _individualChatBloc.dispose();
  }

  Future<bool> _onWillPop() async {
    if (widget.previousScreen == 'new_conversation_page') {
      //print('~~~ 1st _onWillPop');
      _navigationActions.navigateToScreenWidgetRoot(ChatContactOptionsPage());
    } else {
      //print('~~~ 2nd _onWillPop}');
      _navigationActions.closeDialog();
    }
    return false;
  }

  Widget build(BuildContext context) {
    _screenHeight = MediaQuery.of(context).size.height;
    _screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                _onWillPop();
              }),
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: (String settingsOption) {
                _widgetsCollection.showMessageDialog();
                _individualChatBloc.deleteConversation();
              },
              itemBuilder: (BuildContext context) {
                return _settingsList.map((String settingsOption) {
                  return PopupMenuItem<String>(
                    value: settingsOption,
                    child: Text(settingsOption),
                  );
                }).toList();
              },
            )
          ],
          title: SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: () {
                _navigationActions.navigateToScreenWidget(ProfilePage(
                    userId: widget.sentUser.userId,
                    previousScreen: 'individual_chat_page'));
              },
              child: Stack(
                overflow: Overflow.visible,
                children: <Widget>[
                  Positioned(
                    left: leftOffset,
                    top: defaultIconButtonPadding,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blue)),
                      width: 40.0,
                      height: 40.0,
                      child: ClipOval(
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl:
                              '${Connect.filesUrl}${widget.sentUser.profileImage}',
                          placeholder: (BuildContext context, String url) {
                            return Image.asset('assets/images/male-avatar.png');
                          },
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: leftOffset + avatarRadius * 2 + 8.0,
                    top: defaultIconButtonPadding +
                        avatarRadius / 2 -
                        titleLineHeight,
                    child: Text('${widget.sentUser.name}',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0)),
                  )
                ],
              ),
            ),
          ),
        ),
        body: Container(
          margin: EdgeInsets.only(top: 2.0, bottom: 0.0, left: 0.0, right: 0.0),
          child: Stack(
            children: <Widget>[
              StreamBuilder(
                  initialData: null,
                  stream: _individualChatBloc.chatBubblesStream,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<ChatBubble>> asyncSnapshot) {
                    return asyncSnapshot.data == null
                        ? Container(
                            width: 0.0,
                            height: 0.0,
                          )
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
                                return Row(
                                  mainAxisAlignment:
                                      asyncSnapshot.data[index].addedBy ==
                                              Connect.currentUser.userId
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    asyncSnapshot.data[index].addedBy ==
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
                                        margin: EdgeInsets.only(bottom: 10.0),
                                        decoration: BoxDecoration(
                                          color: asyncSnapshot
                                                      .data[index].addedBy ==
                                                  Connect.currentUser.userId
                                              ? Theme.of(context).accentColor
                                              : Colors.grey.withOpacity(0.15),
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10.0),
                                            bottomLeft: Radius.circular(10.0),
                                            bottomRight: Radius.circular(10.0),
                                          ),
                                        ),
                                        padding: EdgeInsets.all(10.0),
                                        child: Column(
                                          crossAxisAlignment: asyncSnapshot
                                                      .data[index].addedBy ==
                                                  Connect.currentUser.userId
                                              ? CrossAxisAlignment.end
                                              : CrossAxisAlignment.start,
//                                              mainAxisAlignment:
//                                                  MainAxisAlignment.end,
                                          children: <Widget>[
                                            Text(
                                              asyncSnapshot.data[index].text,
                                              softWrap: true,
                                              style: TextStyle(
                                                fontSize: 16.0,
                                                color: asyncSnapshot.data[index]
                                                            .addedBy ==
                                                        Connect
                                                            .currentUser.userId
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                              // semanticsLabel: ,
                                            ),
                                            Container(
                                              margin:
                                                  EdgeInsets.only(top: 10.0),
                                              child: Text(
                                                '${(_dateCategory.dMMMyyhma.format(DateTime.fromMillisecondsSinceEpoch(asyncSnapshot.data[index].addedAt))).toString()}',
                                                style: TextStyle(
                                                 
                                                  fontSize: 9.0,
                                                  color: asyncSnapshot
                                                              .data[index]
                                                              .addedBy ==
                                                          Connect.currentUser
                                                              .userId
                                                      ? Colors.white
                                                      : Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )),
                                    asyncSnapshot.data[index].addedBy ==
                                            Connect.currentUser.userId
                                        ? SizedBox(
                                            width: 0.0,
                                            height: 0.0,
                                          )
                                        : SizedBox(width: 20.0),
                                  ],
                                );
                              },
                            ),
                          );
                  }),
              Positioned(
                child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: StreamBuilder(
                    stream: _individualChatBloc.newMessageStream,
                    builder: (BuildContext context,
                        AsyncSnapshot<String> asyncSnapshot) {
                      return Container(
                        margin: EdgeInsets.only(
                            left: 10.0, right: 10.0, top: 0.0, bottom: 10.0),
                        child: Material(
                          borderRadius: BorderRadius.circular(30.0),
                          elevation: 2,
                          child: TextField(
                            enableInteractiveSelection: false,
                            maxLines: null,
                            controller: _messageTextEditingController,
                            // cursorColor: Colors.black12,
                            keyboardType: TextInputType.multiline,
                            onChanged: (String value) {
                              _individualChatBloc.newMessageStreamSink
                                  .add(value);
                            },

                            decoration: InputDecoration(
                              filled: true,
                              hasFloatingPlaceholder: true,
                              contentPadding: EdgeInsets.all(15),
                              hintMaxLines: 2,
                              // prefixIcon: Icon(Icons.search,
                              //     color: Colors.black45, size: 30),
                              hintText: "Type Your Message Here",
                              hintStyle: TextStyle(
                                color: Colors.black26,
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide: BorderSide.none),
                              suffixIcon: IconButton(
                                  icon: Icon(Icons.send),
                                  onPressed: () {
                                    if (_messageTextEditingController.text.trim() !=
                                        '') {
                                      _individualChatBloc.transferMessage();
                                      _messageTextEditingController.text = '';
                                     
                                    }

                                  }
                                  // _messageTextEditingController.clear(),
                                  ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              StreamBuilder(
                stream: _individualChatBloc.messageDeletedStream,
                builder: (BuildContext context,
                    AsyncSnapshot<Map<String, dynamic>> asyncSnapshot) {
                  return asyncSnapshot.data == null
                      ? Container()
                      : _messageDeletedFinished(asyncSnapshot.data);
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _messageDeletedFinished(Map<String, dynamic> mapResponse) {
    Future.delayed(Duration.zero, () {
      _navigationActions.closeDialogRoot();
      _individualChatBloc.messageDeletedStreamSink.add(null);

      if (mapResponse['code'] == 200) {
        _navigationActions.navigateToScreenWidgetRoot(ChatContactOptionsPage());
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
