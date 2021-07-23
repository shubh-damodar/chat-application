import 'dart:async';
import 'package:mesbro_chat_flutter_app/models/conversation.dart';
import 'package:mesbro_chat_flutter_app/network/chat_connect.dart';

class ContactBloc {
  final StreamController<List<Conversation>> _conversationsStreamController =
      StreamController<List<Conversation>>.broadcast();

  StreamSink<List<Conversation>> get conversationsStreamSink =>
      _conversationsStreamController.sink;

  Stream<List<Conversation>> get conversationsStream =>
      _conversationsStreamController.stream.asBroadcastStream();

  List<Conversation> conversationsList;
  ContactBloc(List<Conversation> sentConversationsList) {
    //print('~~~ ContactBloc: ${sentConversationsList.length}');
    sentConversationsList.removeWhere(
        (Conversation conversation) => conversation.groupName != '');
    sentConversationsList.sort((Conversation a, Conversation b) {
      return a.sentUser.name.compareTo(b.sentUser.name);
    });
    Future.delayed(Duration.zero, () {
      conversationsStreamSink.add(sentConversationsList);
    });
  }
  void retrieveConversations() {
    conversationsList = List<Conversation>();
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
      } else {}
    });
  }

  void dispose() {
    _conversationsStreamController.close();
  }
}
