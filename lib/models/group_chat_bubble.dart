import 'dart:async';

import 'package:mesbro_chat_flutter_app/models/user.dart';

class GroupChatBubble {
  String text, id;
  int addedAt;
  User user;

  GroupChatBubble({this.text, this.user, this.addedAt});
  GroupChatBubble.pongAck({this.text, this.user, this.addedAt});

  GroupChatBubble.fromJSON(Map<String, dynamic> map) {
    id = map['id'];
    text = map['details']['text'];
    addedAt = map['addedAt'];
    user = User.fromJSONGroupConversation(map['addedBy']);
  }
  GroupChatBubble.fromJSONAck(Map<String, dynamic> map) {
    text = map['details']['text'];
    addedAt = map['addedAt'];
    user = User.fromJSONGroupConversation(map['addedBy']);
  }
  GroupChatBubble.fromPongNewJSON(Map<String, dynamic> map) {
    text = map['message']['details']['text'];
    addedAt = map['messageClientTs'];
    user = User.fromJSONGroupConversation(map['senderDetails']);
  }
}
