import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:mesbro_chat_flutter_app/models/conversation.dart';
import 'package:mesbro_chat_flutter_app/network/chat_connect.dart';
import 'package:mesbro_chat_flutter_app/network/web_socket_connect.dart';
import 'package:mesbro_chat_flutter_app/notifications/notification_builder.dart';
import 'package:mesbro_chat_flutter_app/utils/shared_pref_manager.dart';

class ChatBloc {
  final StreamController<List<Conversation>> _conversationsStreamController =
      StreamController<List<Conversation>>.broadcast();
  BuildContext buildContext;
  NotificationBuilder _notificationBuilder;
  bool isInBackground = false;

  StreamSink<List<Conversation>> get conversationsStreamSink =>
      _conversationsStreamController.sink;

  Stream<List<Conversation>> get conversationsStream =>
      _conversationsStreamController.stream.asBroadcastStream();

  List<Conversation> conversationsList = null;

  WebSocketConnect webSocketConnect = WebSocketConnect();

  ChatBloc({this.conversationsList, this.buildContext}) {
    Future.delayed(Duration.zero, () {
      if (conversationsList.length > 0) {
        conversationsStreamSink.add(conversationsList);
      }
    });

    _notificationBuilder = NotificationBuilder();
    webSocketConnect.sendPingMessageAfterIntervals();
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
        ////print('mapResponse: ${mapResponse['content']['conversations']}');
        List<dynamic> dynamicList =
            mapResponse['content']['conversations'] as List<dynamic>;
        dynamicList
            .map((i) => conversationsList.add(Conversation.fromJSON(i)))
            .toList();
        conversationsStreamSink.add(conversationsList);
        SharedPrefManager.setSavedConversation(
            json.encode(mapResponse['content']['conversations']).toString());
      } else {}
    });
  }

  void listenLatestMessages() async {
    ////print('~~~ listenLatestMessages: do');
    webSocketConnect.webSocketChannel.stream
        .asBroadcastStream()
        .listen((dynamic jsonDecodedMessageDynamic) {
      Map<String, dynamic> mapEncodedJSON =
          json.decode(jsonDecodedMessageDynamic.toString());
      if (mapEncodedJSON['code'] != null) {
        ////print('~~~ ChatBloc mapEncodedJSON: ${mapEncodedJSON}');
        if (mapEncodedJSON['code'] == 200) {
          ////print('~~~ ChatBloc mapEncodedJSON: ${mapEncodedJSON['content']}');
          retrieveConversations();
          Conversation newConversation =
              Conversation.fromJSONRecent(mapEncodedJSON['content']);
          _notificationBuilder.displayNotification(
              '${newConversation.sentUser.name} sent message',
              newConversation.latestMessage);
//            conversationsList.where((conversation)  {
//              if(newConversation.conversationId==conversation.conversationId) {
//                conversation.latestMessage=newConversation.latestMessage;
//                conversation.unreadCount++;
//                conversationsList.removeWhere((Conversation oldConversation)=>oldConversation.conversationId==conversation.conversationId);
//                conversationsList.insert(0, conversation);
//                //print(
//                    '~~~ conversationsList: ${conversationsList.toList()}');
//                conversationsStreamSink.add(conversationsList);
//              } else  {
//                retrieveConversations();
//              }
//              return true;
//            }).toList();
        } else {
          ////print(
          // '~~~ _receiveLatestMessages 2nd jsonMessageDynamic: ${mapEncodedJSON.values.toList()}');
          retrieveConversations();
        }
      }
    });
  }

  void dispose() {
    _conversationsStreamController.close();
  }
}
