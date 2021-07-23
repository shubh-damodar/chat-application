import 'dart:convert';

class User {
  String userId, name, username, profileImage, au, cc, token, bannerImage;

  User(
      {this.userId,
      this.name,
      this.username,
      this.profileImage,
      this.au,
      this.cc,
      this.token,
      this.bannerImage,
      });

  User.fromJSON(Map<String, dynamic> map) {
    userId = map['userId'];
    name = map['name'];
    username = map['username'];
    profileImage = map['profileImage'];
    au = map['au'];
    cc = map['cc'];
    token = map['token'];
    bannerImage = map['bannerImage'];
  }

  Map<String, String> toJSON() {
    return {
      "userId": this.userId,
      "name": this.name,
      "username": this.username,
      "profileImage": this.profileImage,
      "au": this.au,
      "cc": this.cc,
      "token": this.token,
      "bannerImage": this.bannerImage,
    };
  }

  User.fromJSONConversation(Map<String, dynamic> map) {
    userId = map['userId'];
    name = map['name'];
    profileImage = map['profileImage'];
  }
  User.fromJSONAddNewGroupMember(Map<String, dynamic> map) {
    userId = map['id'];
    name = map['name'];
    profileImage = map['logo'];
  }
  User.fromJSONGroupConversation(Map<String, dynamic> map) {
    userId = map['userId'];
    name = map['name'];
  }
  Map<String, dynamic> toJSONConversation() {
    return {'userId': userId, 'name': name, 'profileImage': profileImage};
  }
}
