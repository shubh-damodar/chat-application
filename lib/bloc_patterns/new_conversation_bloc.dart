import 'dart:async';
import 'dart:convert';
import 'package:mesbro_chat_flutter_app/models/user.dart';
import 'package:mesbro_chat_flutter_app/network/chat_connect.dart';
import 'package:mesbro_chat_flutter_app/utils/contact_list_details.dart';

class NewConversationBloc {
  String nameLetter;
  User selectedUser = null;
  List<User> usersList = List<User>();
  ContactListDetails _contactListDetails = ContactListDetails();

  final StreamController<List<User>> _usersFoundStreamController =
      StreamController<List<User>>();
  final StreamController<Map<String, dynamic>>
      _conversationCreatedStreamController =
      StreamController<Map<String, dynamic>>();

  StreamSink<List<User>> get usersFoundStreamSink =>
      _usersFoundStreamController.sink;
  StreamSink<Map<String, dynamic>> get conversationCreatedStreamSink =>
      _conversationCreatedStreamController.sink;

  Stream<List<User>> get usersFoundStream => _usersFoundStreamController.stream;
  Stream<Map<String, dynamic>> get conversationCreatedStream =>
      _conversationCreatedStreamController.stream;

  void searchPersonName(String sentNameLetter) async {
    nameLetter = sentNameLetter;
    usersList = List<User>();
    usersList = await _contactListDetails.getSuggestions(nameLetter);
    for (int i = 0; i < usersList.length; i++) {
      if (selectedUser != null && usersList[i].userId == selectedUser.userId) {
        usersList.removeAt(i);
      }
    }
    usersFoundStreamSink.add(usersList);
  }

  void removeUser() async {
    selectedUser = null;
    searchPersonName(nameLetter);
  }

  void createNewConversation(User newUser) {
    Map<String, dynamic> mapBody = Map<String, dynamic>();
    mapBody['involvedUsers'] = [newUser.userId];
    ChatConnect _chatConnect = ChatConnect();
    //print('~~~ mapBody: ${json.encode(mapBody)}');
    _chatConnect
        .sendChatPostWithHeaders(mapBody, ChatConnect.conversationAddNew)
        .then((Map<String, dynamic> mapResponse) {
      conversationCreatedStreamSink.add(mapResponse);
    });
  }

  void dispose() {
    _usersFoundStreamController.close();
    _conversationCreatedStreamController.close();
  }
}
