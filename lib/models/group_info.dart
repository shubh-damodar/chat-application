import 'dart:async';

class GroupInfo {
  String conversationId, groupName, owner;
  int updatedAt;
  GroupInfo({this.conversationId, this.groupName, this.owner, this.updatedAt});

  GroupInfo.fromJSON(Map<String, dynamic> map) {
    conversationId = map['conversationId'];
    owner = map['owner'];
    groupName = map['groupName'];
    updatedAt = map['updatedAt'];
  }
}
