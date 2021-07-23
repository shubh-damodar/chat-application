import 'dart:async';

class ChatBubble {
  String id, text, addedBy, readBy;
  int addedAt;
//  ChatBubble.pongNew({this.text, this.addedBy, this.addedAt});
  ChatBubble.pongAck({this.text, this.addedBy, this.addedAt});
  ChatBubble.fromJSON(Map<String, dynamic> map) {
    id = map['id'];
    text = map['details']['text'];
    addedBy = map['addedBy']['userId'];
    addedAt = map['addedAt'];
  }
  ChatBubble.fromPongNewJSON(Map<String, dynamic> map) {
    text = map['message']['details']['text'];
    addedBy = map['senderDetails']['userId'];
    addedAt = map['messageClientTs'];
  }
}
