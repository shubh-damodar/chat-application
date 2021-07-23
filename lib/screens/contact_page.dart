import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mesbro_chat_flutter_app/bloc_patterns/contact_bloc.dart';
import 'package:mesbro_chat_flutter_app/models/conversation.dart';
import 'package:mesbro_chat_flutter_app/network/user_connect.dart';
import 'package:mesbro_chat_flutter_app/utils/navigation_actions.dart';
import 'package:mesbro_chat_flutter_app/utils/widgets_collection.dart';

import 'chat_screens/individual_chat_page.dart';

class ContactPage extends StatefulWidget {
  final List<Conversation> conversationsList;
  ContactPage({this.conversationsList});

  _ContactPageState createState() =>
      _ContactPageState(conversationsList: conversationsList);
}

class _ContactPageState extends State<ContactPage> {
  final List<Conversation> conversationsList;
  List<Conversation> conversationContactsList;
  _ContactPageState({this.conversationsList}) {
    conversationContactsList = []..addAll(conversationsList);
  }
  ContactBloc _contactBloc;
  NavigationActions _navigationActions;
  WidgetsCollection _widgetsCollection;

  void initState() {
    super.initState();
    _contactBloc = ContactBloc(conversationContactsList);
//    _contactBloc.retrieveConversations();
    _navigationActions = NavigationActions(context);
    _widgetsCollection = WidgetsCollection(context);
  }

  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
        child: ListView(children: <Widget>[
          StreamBuilder(
              stream: _contactBloc.conversationsStream,
              builder: (BuildContext context,
                  AsyncSnapshot<List<Conversation>> asyncSnapshot) {
                return asyncSnapshot.data == null
                    ? Center(
                        child: Container(),
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
                                    leading: Container(
                                        width: 40.0,
                                        height: 40.0,
                                        child: ClipOval(
                                            child: CachedNetworkImage(
                                          fit: BoxFit.cover,
                                          imageUrl:
                                              '${Connect.filesUrl}${asyncSnapshot.data[index].sentUser.profileImage}',
                                          placeholder: (BuildContext context,
                                              String url) {
                                            return Image.asset(
                                                'assets_image/male-avatar.png');
                                          },
                                        ))),
                                    title: Text(
                                      asyncSnapshot.data[index].sentUser.name
                                                  .length >
                                              20
                                          ? '${asyncSnapshot.data[index].sentUser.name.substring(0, 20)}...'
                                          : asyncSnapshot
                                              .data[index].sentUser.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )),
                                Divider()
                              ],
                            ),
                            onTap: () {
                              _navigationActions
                                  .navigateToScreenWidget(IndividualChatPage(
                                sentConversationId:
                                    asyncSnapshot.data[index].conversationId,
                                sentUser: asyncSnapshot.data[index].sentUser,
                                previousScreen: 'contact_page',
                              ));
                            },
                          );
                        });
              }),
        ]));
  }
}
