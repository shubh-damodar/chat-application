import 'dart:async';
import 'dart:convert';
import 'package:mesbro_chat_flutter_app/network/web_socket_connect.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mesbro_chat_flutter_app/models/chat_bubble.dart';
import 'package:mesbro_chat_flutter_app/network/chat_connect.dart';
import 'package:mesbro_chat_flutter_app/validators/chat_validators.dart';

class IndividualChatBloc with ChatValidators {
  IndividualChatBloc() {
    _webSocketConnect.sendPingMessageAfterIntervals();
  }
  WebSocketConnect _webSocketConnect = WebSocketConnect();

  String conversationId;
  List<ChatBubble> chatBubblesList = List<ChatBubble>();

  final StreamController<List<ChatBubble>> _chatBubblesStreamController =
      StreamController<List<ChatBubble>>.broadcast();

  final BehaviorSubject<String> _newMessageBehaviorSubject =
      BehaviorSubject<String>();
  final StreamController<Map<String, dynamic>>
      _messageDeletedBubblesStreamController =
      StreamController<Map<String, dynamic>>.broadcast();

  StreamSink<List<ChatBubble>> get chatBubblesStreamSink =>
      _chatBubblesStreamController.sink;
  StreamSink<String> get newMessageStreamSink =>
      _newMessageBehaviorSubject.sink;
  StreamSink<Map<String, dynamic>> get messageDeletedStreamSink =>
      _messageDeletedBubblesStreamController.sink;

  Stream<List<ChatBubble>> get chatBubblesStream =>
      _chatBubblesStreamController.stream.asBroadcastStream();
  Stream<String> get newMessageStream => _newMessageBehaviorSubject.stream
      .asBroadcastStream()
      .asBroadcastStream()
      .transform(chatMessageStreamTransformer);
  Stream<Map<String, dynamic>> get messageDeletedStream =>
      _messageDeletedBubblesStreamController.stream.asBroadcastStream();

  void retrieveAllChatBubbles(String sentConversationId) {
    conversationId = sentConversationId;
    chatBubblesList = List<ChatBubble>();
    Map<String, dynamic> mapBody = Map<String, dynamic>();
    mapBody['conversationId'] = sentConversationId;
    ChatConnect _chatConnect = ChatConnect();
    _chatConnect
        .sendChatPost(mapBody, ChatConnect.conversationGetMessages)
        .then((Map<String, dynamic> mapResponse) {
      //print('~~~  mapResponse: ${mapResponse.values.toList()}');
      if (mapResponse['code'] == 200) {
        //print('mapResponse: ${mapResponse['content']['conversationList']}');
        List<dynamic> dynamicList =
            mapResponse['content']['conversationList'] as List<dynamic>;
        dynamicList
            .map((i) => chatBubblesList.add(ChatBubble.fromJSON(i)))
            .toList();
        chatBubblesStreamSink.add(chatBubblesList);
      } else {}
    });
  }

  void fetchFurtherChatBubbles() {
    //print('~~~ fetchFurtherChatBubbles: ${chatBubblesList[0].id}');

    Map<String, dynamic> mapBody = Map<String, dynamic>();
    mapBody['conversationId'] = conversationId;
    mapBody['lastItemId'] = chatBubblesList[chatBubblesList.length - 1].id;
    List<ChatBubble> newChatBubblesList = List<ChatBubble>();
    ChatConnect _chatConnect = ChatConnect();
    _chatConnect
        .sendChatPost(mapBody, ChatConnect.conversationGetMessages)
        .then((Map<String, dynamic> mapResponse) {
      //print('~~~  mapResponse: ${mapResponse.values.toList()}');
      if (mapResponse['code'] == 200) {
        //print('mapResponse: ${mapResponse['content']['conversationList']}');
        List<dynamic> dynamicList =
            mapResponse['content']['conversationList'] as List<dynamic>;
        dynamicList
            .map((i) => newChatBubblesList.add(ChatBubble.fromJSON(i)))
            .toList();
        chatBubblesList.addAll(newChatBubblesList);
        chatBubblesStreamSink.add(chatBubblesList);
      } else {}
    });
  }

  int messageClientTs;
  String sendMessage;
  void transferMessage() {
    messageClientTs = DateTime.now().millisecondsSinceEpoch;
    sendMessage = _newMessageBehaviorSubject.value;
    Map<String, dynamic> mapBody = Map<String, dynamic>();
    mapBody['type'] = 'new';

    Map<String, dynamic> messageMap = Map<String, dynamic>();
    messageMap['messageClientTs'] = messageClientTs;
    messageMap['conversationId'] = conversationId;
    messageMap['type'] = 'text';
    Map<String, dynamic> detailsMap = Map<String, dynamic>();
    detailsMap['text'] = sendMessage;
    detailsMap['accessUrl'] = '';

    messageMap['details'] = detailsMap;
    mapBody['message'] = messageMap;

    String jsonBody = json.encode(json.encode(mapBody));

    //print('~~~ IndividualChatBloc: $jsonBody');
    _webSocketConnect.sendChatMessage(jsonBody);
    newMessageStreamSink.add('');
  }

  void listenLatestMessages() async {
    //print('~~~ IndividualChatBloc: do');
    _webSocketConnect.webSocketChannel.stream
        .asBroadcastStream()
        .listen((dynamic jsonDecodedMessageDynamic) {
      Map<String, dynamic> mapEncodedJSON =
          json.decode(jsonDecodedMessageDynamic.toString());
      //print(
          // '~~~ IndividualChatBloc jsonDecodedMessageDynamic: $conversationId ${jsonDecodedMessageDynamic}');
      if (mapEncodedJSON['code'] != null) {
        if (mapEncodedJSON['code'] == 200) {
          if (mapEncodedJSON['content']['type'] == 'ack') {
            retrieveAllChatBubbles(conversationId);
//              chatBubblesList.insert(0, ChatBubble.pongAck(text: sendMessage, addedBy: Connect.currentUser.userId, addedAt: messageClientTs));
//              chatBubblesStreamSink.add(chatBubblesList);
          } else if (mapEncodedJSON['content']['type'] == 'new') {
            retrieveAllChatBubbles(conversationId);
//              chatBubblesList.insert(0, ChatBubble.fromPongNewJSON(mapEncodedJSON['content']));
//              chatBubblesStreamSink.add(chatBubblesList);
          }
        } else {
//            //print(
//                '~~~ _receiveLatestMessages 2nd jsonMessageDynamic: ${mapEncodedJSON.values.toList()}');
        }
      }
    });
  }

  void deleteConversation() async {
    Map<String, dynamic> mapBody = Map<String, dynamic>();

    mapBody['conversationIds'] = [conversationId];
    mapBody['action'] = 'delete';
    ChatConnect _chatConnect = ChatConnect();
    //print('~~~ mapBody: ${json.encode(mapBody)}');
    _chatConnect
        .sendChatPostWithHeaders(mapBody, ChatConnect.conversationManage)
        .then((Map<String, dynamic> mapResponse) {
      messageDeletedStreamSink.add(mapResponse);
    });
  }

  void dispose() {
    _chatBubblesStreamController.close();
    _newMessageBehaviorSubject.close();
    _messageDeletedBubblesStreamController.close();
  }
}
