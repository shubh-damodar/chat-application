import 'dart:async';
import 'dart:convert';
import 'package:mesbro_chat_flutter_app/models/conversation.dart';
import 'package:mesbro_chat_flutter_app/network/chat_connect.dart';
import 'package:mesbro_chat_flutter_app/utils/shared_pref_manager.dart';

class ChatContactOptionsBloc {
  List<Conversation> conversationsList = null, contactsList = null;
  final StreamController<List<Conversation>> _conversationsStreamController =
      StreamController<List<Conversation>>.broadcast();

  StreamSink<List<Conversation>> get conversationsStreamSink =>
      _conversationsStreamController.sink;

  Stream<List<Conversation>> get conversationsStream =>
      _conversationsStreamController.stream.asBroadcastStream();

  void getSavedConversations() async {
    String conversationEncoded = await SharedPrefManager.getConversation();
    //print('~~~ getSavedConversations: $conversationEncoded');
    if (conversationEncoded != null) {
      conversationsList = List<Conversation>();
      List<dynamic> dynamicList =
          json.decode(conversationEncoded) as List<dynamic>;
      // print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~$dynamicList");
      dynamicList
          .map((i) => conversationsList.add(Conversation.fromJSON(i)))
          .toList();
      //print('~~~ getSavedConversations: ${conversationsList.length}');
      conversationsStreamSink.add(conversationsList);
    } else {
      retrieveConversations();
    }
  }

  void retrieveConversations() {
    conversationsList = List<Conversation>();
    contactsList = List<Conversation>();
    ChatConnect _chatConnect = ChatConnect();
    Map<String, dynamic> mapBody = Map<String, dynamic>();
    mapBody['filters'] = {'query': ''};
    _chatConnect
        .sendChatPostWithHeaders(mapBody, ChatConnect.conversationList)
        .then((Map<String, dynamic> mapResponse) {
      if (mapResponse['code'] == 200) {
        //print('mapResponse: ${mapResponse['content']['conversations']}');
        List<dynamic> dynamicList =
            mapResponse['content']['conversations'] as List<dynamic>;
        dynamicList
            .map((i) => conversationsList.add(Conversation.fromJSON(i)))
            .toList();
//        conversationsStreamSink.add(null);
        conversationsStreamSink.add(conversationsList);

        //print(
        // '~~~ saving: ${json.encode(mapResponse['content']['conversations']).toString()}');
        SharedPrefManager.setSavedConversation(
            json.encode(mapResponse['content']['conversations']).toString());
      } else {}
    });
  }

  void dispose() {
    _conversationsStreamController.close();
  }
}
