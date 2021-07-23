import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mesbro_chat_flutter_app/bloc_patterns/new_conversation_bloc.dart';
import 'package:mesbro_chat_flutter_app/models/user.dart';
import 'package:mesbro_chat_flutter_app/network/user_connect.dart';
import 'package:mesbro_chat_flutter_app/utils/navigation_actions.dart';
import 'package:mesbro_chat_flutter_app/utils/widgets_collection.dart';

import 'chat_contact_options_page.dart';
import 'chat_screens/chat_page.dart';
import 'chat_screens/individual_chat_page.dart';

class NewConversationPage extends StatefulWidget {
  _NewConversationPageState createState() => _NewConversationPageState();
}

class _NewConversationPageState extends State<NewConversationPage> {
  final NewConversationBloc _newConversationBloc = NewConversationBloc();
  NavigationActions _navigationActions;
  WidgetsCollection _widgetsCollection;
  String selectedName;

  Future<bool> _onWillPop() async {
    _navigationActions.closeDialog();
    return false;
  }

  void initState() {
    super.initState();
    _newConversationBloc.searchPersonName('a');
    _navigationActions = NavigationActions(context);
    _widgetsCollection = WidgetsCollection(context);
  }

  void dispose() {
    super.dispose();
    _newConversationBloc.dispose();
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
          appBar: AppBar(
            title: Text(
              'New Conversation'
            ),
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  _onWillPop();
                }),
          ),
          body: Container(
              margin: EdgeInsets.only(
                  left: 10.0, right: 10.0, top: 10.0, bottom: 10.0),
              child: Column(children: <Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: 0.0, left: 5.0),
                  color: Colors.white,
                  child: Column(
                    children: <Widget>[
                      TextField(
                        onChanged: (String value) {
                          _newConversationBloc.searchPersonName(value);
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.15),
                          )),
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.15),
                          hintText: 'Search Person',
                        ),
                      ),
                    ],
                  ),
                ),
                StreamBuilder(
                  stream: _newConversationBloc.usersFoundStream,
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
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Column(children: <Widget>[
                                        ListTile(
                                          onTap: () {
                                            _newConversationBloc
                                                .createNewConversation(
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
                                                  )))),
                                          title: Text(
                                              asyncSnapshot.data[index].name),
                                        ),
                                        Divider()
                                      ]);
                                    }));
                  },
                ),
                StreamBuilder(
                    stream: _newConversationBloc.conversationCreatedStream,
                    builder:
                        (BuildContext context, AsyncSnapshot asyncSnapshot) {
                      return asyncSnapshot.data == null
                          ? Container()
                          : _conversationCreatedFinished(asyncSnapshot.data);
                    }),
              ]))),
    );
  }

  Widget _conversationCreatedFinished(Map<String, dynamic> mapResponse) {
    Future.delayed(Duration.zero, () {
//      _navigationActions.closeDialog();
      _newConversationBloc.conversationCreatedStreamSink.add(null);

      if (mapResponse['code'] == 200) {
        //print('~~~ 200: $mapResponse');

        String conversationId = mapResponse['content']['conversationId'];
        Map<String, dynamic> userMap = mapResponse['content']['involvedUsers']
                    [0]['userId'] ==
                Connect.currentUser.userId
            ? mapResponse['content']['involvedUsers'][1]
            : mapResponse['content']['involvedUsers'][0];

        User user = User(
            userId: userMap['userId'],
            name: userMap['name'],
            profileImage: userMap['profileImage']);
        _navigationActions.navigateToScreenWidget(IndividualChatPage(
          sentConversationId: conversationId,
          sentUser: user,
          previousScreen: 'new_conversation_page',
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
