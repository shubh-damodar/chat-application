import 'dart:async';
import 'dart:convert';

import 'package:mesbro_chat_flutter_app/models/user.dart';
import 'package:mesbro_chat_flutter_app/network/chat_connect.dart';
import 'package:mesbro_chat_flutter_app/network/user_connect.dart';

class GroupMembersBloc {
  ChatConnect _chatConnect = ChatConnect();
  String conversationId, terminatedUserId;
  List<User> usersList = List<User>();

  final StreamController<List<User>> _usersStreamController =
      StreamController<List<User>>.broadcast();
  final StreamController<Map<String, dynamic>> _removeUserStreamController =
          StreamController<Map<String, dynamic>>.broadcast(),
      _leaveGroupStreamController =
          StreamController<Map<String, dynamic>>.broadcast(),
      _messageDeletedStreamController =
          StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<bool> _isUserOwnerStreamController =
      StreamController<bool>.broadcast();
  StreamSink<List<User>> get usersStreamSink => _usersStreamController.sink;
  StreamSink<Map<String, dynamic>> get removeUserStreamSink =>
      _removeUserStreamController.sink;
  StreamSink<Map<String, dynamic>> get leaveGroupStreamSink =>
      _leaveGroupStreamController.sink;
  StreamSink<Map<String, dynamic>> get messageDeletedStreamSink =>
      _messageDeletedStreamController.sink;
  StreamSink<bool> get isUserOwnerStreamSink =>
      _isUserOwnerStreamController.sink;

  Stream<List<User>> get usersStream =>
      _usersStreamController.stream.asBroadcastStream();
  Stream<Map<String, dynamic>> get removeUserStream =>
      _removeUserStreamController.stream.asBroadcastStream();
  Stream<Map<String, dynamic>> get leaveGroupStream =>
      _leaveGroupStreamController.stream.asBroadcastStream();
  Stream<Map<String, dynamic>> get messageDeletedStream =>
      _messageDeletedStreamController.stream.asBroadcastStream();
  Stream<bool> get isUserOwnerStream => _isUserOwnerStreamController.stream;

  void getAllMembers(String sentConversationId) async {
    conversationId = sentConversationId;
    usersList = List<User>();
    Map<String, dynamic> mapBody = Map<String, dynamic>();
    mapBody['conversationId'] = conversationId;
    _chatConnect
        .sendChatPostWithHeaders(mapBody, ChatConnect.conversationGetMessages)
        .then((Map<String, dynamic> mapResponse) {
      //print('~~~ getAllMembers ${mapResponse}');
      if (mapResponse['code'] == 200) {
        //print(
            // '~~~ getAllMembers mapResponse: ${mapResponse['content']['conversationDetails']['involvedUsers']}');
        List<dynamic> dynamicList = mapResponse['content']
            ['conversationDetails']['involvedUsers'] as List<dynamic>;
        dynamicList
            .map((i) => usersList.add(User.fromJSONConversation(i)))
            .toList();
        usersList.removeWhere(
            (User user) => Connect.currentUser.userId == user.userId);
        usersList.insert(
            0,
            User(
                userId: Connect.currentUser.userId,
                name: 'You',
                profileImage: Connect.currentUser.profileImage));
        usersStreamSink.add(usersList);
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

  void removeMemberFromGroup(String userId) {
    terminatedUserId = userId;
    Map<String, dynamic> mapBody = Map<String, dynamic>();
    mapBody['conversationId'] = conversationId;
    mapBody['members'] = [userId];
    mapBody['action'] = 'remove';
    _chatConnect
        .sendChatPostWithHeaders(mapBody, ChatConnect.conversationManageMembers)
        .then((Map<String, dynamic> mapResponse) {
      //print('~~~ removeMemberFromGroup ${mapResponse}');
      removeUserStreamSink.add(mapResponse);
    });
  }

  void leaveGroup(String userId) {
    terminatedUserId = userId;
    Map<String, dynamic> mapBody = Map<String, dynamic>();
    mapBody['conversationId'] = conversationId;
    mapBody['members'] = [userId];
    mapBody['action'] = 'remove';
    _chatConnect
        .sendChatPostWithHeaders(mapBody, ChatConnect.conversationManageMembers)
        .then((Map<String, dynamic> mapResponse) {
      //print('~~~ leaveGroupStreamSink ${mapResponse}');
      leaveGroupStreamSink.add(mapResponse);
    });
  }

  void removeMember() {
    usersList.removeWhere((User user) => terminatedUserId == user.userId);
    usersStreamSink.add(usersList);
  }

  void dispose() {
    _usersStreamController.close();
    _isUserOwnerStreamController.close();
    _removeUserStreamController.close();
    _leaveGroupStreamController.close();
    _messageDeletedStreamController.close();
  }
}
