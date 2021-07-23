import 'dart:async';
import 'dart:convert';
import 'package:mesbro_chat_flutter_app/models/user.dart';
import 'package:mesbro_chat_flutter_app/network/chat_connect.dart';
import 'package:mesbro_chat_flutter_app/utils/contact_list_details.dart';

class AddNewMemberBloc {
  final List<User> membersList;
  final String conversationId;
  AddNewMemberBloc({this.membersList, this.conversationId});

  ContactListDetails _contactListDetails = ContactListDetails();
  List<User> selectedUsersList = List<User>(), usersFoundList = List<User>();
  String nameLetter;
  final StreamController<List<User>> _usersFoundStreamController =
          StreamController<List<User>>(),
      _selectedMembersStreamController = StreamController<List<User>>();
  final StreamController<Map<String, dynamic>> _membersAddedStreamController =
      StreamController<Map<String, dynamic>>();

  StreamSink<List<User>> get usersFoundStreamSink =>
      _usersFoundStreamController.sink;

  StreamSink<List<User>> get selectedMembersStreamSink =>
      _selectedMembersStreamController.sink;

  StreamSink<Map<String, dynamic>> get membersAddedStreamSink =>
      _membersAddedStreamController.sink;

  Stream<List<User>> get usersFoundStream => _usersFoundStreamController.stream;

  Stream<List<User>> get selectedMembersStream =>
      _selectedMembersStreamController.stream;

  Stream<Map<String, dynamic>> get membersAddedStream =>
      _membersAddedStreamController.stream;

  void searchPersonName(String sentNameLetter) async {
    nameLetter = sentNameLetter;
    usersFoundList = List<User>();
    usersFoundList = await _contactListDetails.getSuggestions(nameLetter);
    // //print('~~~ searchPersonName');
    for (int i0 = 0; i0 < usersFoundList.length; i0++) {
      for (int i1 = 0; i1 < membersList.length; i1++) {
//        for (int i2 = 0; i2 < selectedUsersList.length; i2++) {
//          //print('~~~ search: ${usersFoundList[i0].userId} ${usersFoundList[i2].userId}');
        // //print(
        //     '~~~ search: ${usersFoundList[i0].userId} ${membersList[i1].userId}');
//          if (usersFoundList[i0].userId == selectedUsersList[i2].userId || usersFoundList[i0].userId == membersList[i1].userId) {
        if (usersFoundList[i0].userId == membersList[i1].userId) {
          usersFoundList.removeAt(i0);
        }
//        }
      }
    }
    usersFoundStreamSink.add(usersFoundList);
  }

  void includeNewUser(User newUser) async {
    selectedUsersList.add(newUser);
    usersFoundList.removeWhere((User user) => newUser.userId == user.userId);
    usersFoundStreamSink.add(usersFoundList);
    selectedMembersStreamSink.add(selectedUsersList);
  }

  void removeUser(User removableUser) async {
    selectedUsersList
        .removeWhere((User user) => user.userId == removableUser.userId);
    selectedMembersStreamSink.add(selectedUsersList);
    searchPersonName(nameLetter);
  }

  void addNewMembers() async {
    Map<String, dynamic> mapBody = Map<String, dynamic>();
    List<String> userIdList = List<String>();
    for (User user in selectedUsersList) {
      userIdList.add(user.userId);
    }
    mapBody['conversationId'] = conversationId;
    mapBody['members'] = userIdList;
    mapBody['action'] = 'add';
    ChatConnect _chatConnect = ChatConnect();
    // //print('~~~ mapBody: ${json.encode(mapBody)}');
    _chatConnect
        .sendChatPostWithHeaders(mapBody, ChatConnect.conversationManageMembers)
        .then((Map<String, dynamic> mapResponse) {
      _membersAddedStreamController.add(mapResponse);
    });
  }

  void dispose() {
    _usersFoundStreamController.close();
    _selectedMembersStreamController.close();
    _membersAddedStreamController.close();
  }
}
