import 'dart:async';
import 'dart:convert';
import 'package:mesbro_chat_flutter_app/models/user.dart';
import 'package:mesbro_chat_flutter_app/network/chat_connect.dart';
import 'package:mesbro_chat_flutter_app/utils/contact_list_details.dart';
import 'package:mesbro_chat_flutter_app/validators/chat_validators.dart';
import 'package:rxdart/rxdart.dart';

class NewGroupBloc extends ChatValidators {
  List<User> usersList = List<User>();
  List<User> selectedUsersList = List<User>();
  String nameLetter;
  final BehaviorSubject<String> groupNameBehaviorSubject =
      BehaviorSubject<String>();
  final StreamController<List<User>> _usersFoundStreamController =
          StreamController<List<User>>(),
      _selectedUsersStreamController = StreamController<List<User>>();

  final StreamController<Map<String, dynamic>> _groupCreatedStreamController =
      StreamController<Map<String, dynamic>>();

  ContactListDetails _contactListDetails = ContactListDetails();

  StreamSink<String> get groupNameStreamSink => groupNameBehaviorSubject.sink;

  StreamSink<List<User>> get usersFoundStreamSink =>
      _usersFoundStreamController.sink;

  StreamSink<List<User>> get selectedUsersStreamSink =>
      _selectedUsersStreamController.sink;

  StreamSink<Map<String, dynamic>> get groupCreatedStreamSink =>
      _groupCreatedStreamController.sink;

  Stream<String> get groupNameStream => groupNameBehaviorSubject.stream
      .asBroadcastStream()
      .transform(groupNameStreamTransformer);

  Stream<List<User>> get usersFoundStream => _usersFoundStreamController.stream;

  Stream<List<User>> get selectedUsersStream =>
      _selectedUsersStreamController.stream;

  Stream<Map<String, dynamic>> get groupCreatedStream =>
      _groupCreatedStreamController.stream;

  void searchPersonName(String sentNameLetter) async {
    nameLetter = sentNameLetter;
    usersList = List<User>();
    usersList = await _contactListDetails.getSuggestions(nameLetter);
    for (int i = 0; i < usersList.length; i++) {
      for (int i1 = 0; i1 < selectedUsersList.length; i1++) {
        if (usersList[i].userId == selectedUsersList[i1].userId) {
          usersList.removeAt(i);
        }
      }
    }
    usersFoundStreamSink.add(usersList);
  }

  void includeNewUser(User newUser) async {
    selectedUsersList.add(newUser);
    usersList.removeWhere((User user) => newUser.userId == user.userId);
    usersFoundStreamSink.add(usersList);
    selectedUsersStreamSink.add(selectedUsersList);
  }

  void removeUser(User removableUser) async {
    selectedUsersList
        .removeWhere((User user) => user.userId == removableUser.userId);
    selectedUsersStreamSink.add(selectedUsersList);
    searchPersonName(nameLetter);
  }

  void createNewGroup() {
    Map<String, dynamic> mapBody = Map<String, dynamic>();
    List<String> userIdList = List<String>();
    for (User user in selectedUsersList) {
      userIdList.add(user.userId);
    }
    mapBody['involvedUsers'] = userIdList;
    mapBody['groupName'] = groupNameBehaviorSubject.value;
    ChatConnect _chatConnect = ChatConnect();
    //print('~~~ mapBody: ${json.encode(mapBody)}');
    _chatConnect
        .sendChatPostWithHeaders(mapBody, ChatConnect.conversationAddNew)
        .then((Map<String, dynamic> mapResponse) {
      groupCreatedStreamSink.add(mapResponse);
    });
  }

  void dispose() {
    groupNameBehaviorSubject.close();
    _usersFoundStreamController.close();
    _selectedUsersStreamController.close();
    _groupCreatedStreamController.close();
  }
}
