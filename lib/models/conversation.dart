import 'dart:async';

import 'package:mesbro_chat_flutter_app/models/user.dart';
import 'package:mesbro_chat_flutter_app/network/user_connect.dart';

class Conversation {
  User sentUser;
  int unreadCount, updatedAt;
  String conversationId, latestMessage, groupName, owners;

  Conversation.fromJSON(Map<String, dynamic> map) {
    conversationId = map['conversationId'];
    owners = map["owner"] == null ? map["owner"] : map["owner"][0];
    unreadCount = map['unreadCount'];
    updatedAt = map['updatedAt'];
    sentUser = map['involvedUsers'][0]['userId'] == Connect.currentUser.userId
        ? User.fromJSONConversation(map['involvedUsers'][1])
        : User.fromJSONConversation(map['involvedUsers'][0]);
    groupName = map['groupName'] == null ? '' : map['groupName'];
    latestMessage = map['latestMessage'] == null
        ? ''
        : map['latestMessage']['details'] == null
            ? ''
            : map['latestMessage']['details']['text'] == null
                ? ''
                : map['latestMessage']['details']['text'];
  }

  Conversation.fromJSONRecent(Map<String, dynamic> map) {
    latestMessage = map['message']['details']['text'];
    conversationId = map['conversationId'];
    updatedAt = map['addedAt'];
    sentUser = User.fromJSONConversation(map['senderDetails']);
  }
}
