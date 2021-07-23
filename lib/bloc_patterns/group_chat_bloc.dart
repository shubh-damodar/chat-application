import 'dart:async';
import 'dart:convert';
import 'package:mesbro_chat_flutter_app/models/group_chat_bubble.dart';
import 'package:mesbro_chat_flutter_app/network/chat_connect.dart';
import 'package:mesbro_chat_flutter_app/network/web_socket_connect.dart';
import 'package:mesbro_chat_flutter_app/validators/chat_validators.dart';
import 'package:rxdart/rxdart.dart';

class GroupChatBloc with ChatValidators {
  GroupChatBloc() {
    _webSocketConnect.sendPingMessageAfterIntervals();
  }

  WebSocketConnect _webSocketConnect = WebSocketConnect();

  String conversationId;
  List<GroupChatBubble> groupChatBubblesList = List<GroupChatBubble>();

  final StreamController<List<GroupChatBubble>>
      _groupChatBubblesStreamController =
      StreamController<List<GroupChatBubble>>.broadcast();
  final BehaviorSubject<String> _newMessageBehaviorSubject =
      BehaviorSubject<String>();

  StreamSink<List<GroupChatBubble>> get groupChatBubblesStreamSink =>
      _groupChatBubblesStreamController.sink;

  StreamSink<String> get newMessageStreamSink =>
      _newMessageBehaviorSubject.sink;

  Stream<List<GroupChatBubble>> get groupChatBubblesStream =>
      _groupChatBubblesStreamController.stream.asBroadcastStream();

  Stream<String> get newMessageStream => _newMessageBehaviorSubject.stream
      .asBroadcastStream()
      .transform(chatMessageStreamTransformer);

  void retrieveAllChatBubbles(String sentConversationId) {
    conversationId = sentConversationId;
    groupChatBubblesList = List<GroupChatBubble>();
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
            .map((i) => groupChatBubblesList.add(GroupChatBubble.fromJSON(i)))
            .toList();
        groupChatBubblesStreamSink.add(groupChatBubblesList);
      } else {}
    });
  }

  void fetchFurtherChatBubbles() {
    Map<String, dynamic> mapBody = Map<String, dynamic>();
    mapBody['conversationId'] = conversationId;
    mapBody['lastItemId'] =
        groupChatBubblesList[groupChatBubblesList.length - 1].id;
    List<GroupChatBubble> newGroupChatBubblesList = List<GroupChatBubble>();
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
            .map(
                (i) => newGroupChatBubblesList.add(GroupChatBubble.fromJSON(i)))
            .toList();
        groupChatBubblesList.addAll(newGroupChatBubblesList);
        groupChatBubblesStreamSink.add(groupChatBubblesList);
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

    //print('~~~ GroupChatBloc: $jsonBody');
    _webSocketConnect.sendChatMessage(jsonBody);
    newMessageStreamSink.add('');
  }

  void listenLatestMessages() async {
    //print('~~~ GroupChatBloc: do');
    _webSocketConnect.webSocketChannel.stream
        .asBroadcastStream()
        .listen((dynamic jsonDecodedMessageDynamic) {
      Map<String, dynamic> mapEncodedJSON =
          json.decode(jsonDecodedMessageDynamic.toString());
      //print(
          // '~~~ GroupChatBloc jsonDecodedMessageDynamic: ${jsonDecodedMessageDynamic}');
      if (mapEncodedJSON['code'] != null) {
        if (mapEncodedJSON['code'] == 200) {
          if (mapEncodedJSON['content']['type'] == 'ack') {
            retrieveAllChatBubbles(conversationId);
//            groupChatBubblesList.insert(
//                0,
//                GroupChatBubble.pongAck(
//                    text: sendMessage,
//                    user: User(userId: Connect.currentUser.userId, name: Connect.currentUser.name),
//                    addedAt: messageClientTs));
//            groupChatBubblesStreamSink.add(groupChatBubblesList);
          } else if (mapEncodedJSON['content']['type'] == 'new') {
            retrieveAllChatBubbles(conversationId);
//            groupChatBubblesList.insert(
//                0, GroupChatBubble.fromPongNewJSON(mapEncodedJSON['content']));
//            groupChatBubblesStreamSink.add(groupChatBubblesList);
          }
        } else {
//            //print(
//                '~~~ _receiveLatestMessages 2nd jsonMessageDynamic: ${mapEncodedJSON.values.toList()}');
        }
      }
    });
  }

  void dispose() {
    _groupChatBubblesStreamController.close();
    _newMessageBehaviorSubject.close();
  }
}
