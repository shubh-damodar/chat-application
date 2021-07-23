import 'dart:async';
import 'package:mesbro_chat_flutter_app/network/chat_connect.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mesbro_chat_flutter_app/validators/chat_validators.dart';

class RenameGroupNameBloc extends ChatValidators {
  final BehaviorSubject<String> _groupNameBehaviorSubject =
      BehaviorSubject<String>();
  final StreamController<Map<String, dynamic>> _groupCreatedStreamController =
      StreamController<Map<String, dynamic>>();

  StreamSink<String> get groupNameStreamSink => _groupNameBehaviorSubject.sink;
  StreamSink<Map<String, dynamic>> get groupCreatedStreamSink =>
      _groupCreatedStreamController.sink;

  Stream<String> get groupNameStream => _groupNameBehaviorSubject.stream
      .asBroadcastStream()
      .transform(groupNameStreamTransformer);
  Stream<Map<String, dynamic>> get groupCreatedStream =>
      _groupCreatedStreamController.stream;

  Stream<bool> get groupNameCheck =>
      Observable.combineLatest({groupNameStream}, (groupName) => true);
  String typedGroupName;
  void renameGroup(String conversationId) {
    ChatConnect _chatConnect = ChatConnect();
    Map<String, dynamic> mapBody = Map<String, dynamic>();
    mapBody['conversationIds'] = [conversationId];
    typedGroupName = _groupNameBehaviorSubject.value;
    mapBody['groupName'] = typedGroupName;
    mapBody['action'] = 'update';
    //print('~~~ conversationManage: mapBody ${mapBody}');
    _chatConnect
        .sendChatPost(mapBody, ChatConnect.conversationManage)
        .then((Map<String, dynamic> mapResponse) {
      //print('~~~ conversationManage ${mapResponse}');
      groupCreatedStreamSink.add(mapResponse);
    });
  }

  void dispose() {
    _groupNameBehaviorSubject.close();
    _groupCreatedStreamController.close();
  }
}
