import 'dart:async';
import 'dart:convert';
import 'package:mesbro_chat_flutter_app/models/conversation.dart';
import 'package:mesbro_chat_flutter_app/network/chat_connect.dart';
import 'package:mesbro_chat_flutter_app/utils/contact_message_list_details.dart';
import 'package:mesbro_chat_flutter_app/utils/shared_pref_manager.dart';
import 'package:mesbro_chat_flutter_app/validators/chat_validators.dart';
import 'package:rxdart/rxdart.dart';

class SearchChatBloc extends ChatValidators {
  List<Conversation> conversationsList = List<Conversation>();
  String nameMemberLetter;
  ContactMessageListDetails _contactMessageListDetails;
  SearchChatBloc() {
    getSavedConversations();
  }
  final StreamController<List<Conversation>>
      _conversationsFoundStreamController =
      StreamController<List<Conversation>>();
  final BehaviorSubject<String> _messagePersonBehaviorSubject =
      BehaviorSubject<String>();

  StreamSink<List<Conversation>> get conversationsFoundStreamSink =>
      _conversationsFoundStreamController.sink;
  StreamSink<String> get messagePersonStreamSink =>
      _messagePersonBehaviorSubject.sink;

  Stream<List<Conversation>> get conversationsFoundStream =>
      _conversationsFoundStreamController.stream;
  Stream<String> get messagePersonStream => _messagePersonBehaviorSubject.stream
      .transform(chatMessageStreamTransformer);
  void getSavedConversations() async {
    String conversationEncoded = await SharedPrefManager.getConversation();
    //print('~~~ getSavedConversations: $conversationEncoded');
    if (conversationEncoded != null) {
      conversationsList = List<Conversation>();
      List<dynamic> dynamicList =
          json.decode(conversationEncoded) as List<dynamic>;
      dynamicList
          .map((i) => conversationsList.add(Conversation.fromJSON(i)))
          .toList();
      //print('~~~ getSavedConversations: ${conversationsList.length}');
      conversationsFoundStreamSink.add(conversationsList);
      _contactMessageListDetails = ContactMessageListDetails(conversationsList);
      searchPersonMemberName('');
    } else {
      retrieveConversations();
    }
  }

  void retrieveConversations() {
    conversationsList = List<Conversation>();
    ChatConnect _chatConnect = ChatConnect();
    Map<String, dynamic> mapBody = Map<String, dynamic>();
    mapBody['filters'] = {'query': ''};
    _chatConnect
        .sendChatPostWithHeaders(mapBody, ChatConnect.conversationList)
        .then((Map<String, dynamic> mapResponse) {
      if (mapResponse['code'] == 200) {
        //print('mapResponse: ${mapResponse['content']['conversations']}');
        List<dynamic> dynamicList =
            mapResponse['content']['conversations'] as List<dynamic>;
        dynamicList
            .map((i) => conversationsList.add(Conversation.fromJSON(i)))
            .toList();
//        conversationsStreamSink.add(null);
        conversationsFoundStreamSink.add(conversationsList);
        //print('~~~ retrieveConversations: ${conversationsList.length}');
        _contactMessageListDetails =
            ContactMessageListDetails(conversationsList);
        searchPersonMemberName('');
        //print(
            // '~~~ saving: ${json.encode(mapResponse['content']['conversations']).toString()}');
        SharedPrefManager.setSavedConversation(
            json.encode(mapResponse['content']['conversations']).toString());
      } else {}
    });
  }

  void searchPersonMemberName(String sentNameMemberLetter) async {
    nameMemberLetter = sentNameMemberLetter;
    conversationsList = List<Conversation>();
    conversationsList =
        await _contactMessageListDetails.getSuggestions(nameMemberLetter);
        print("-----------------------------------$conversationsList");
    conversationsFoundStreamSink.add(conversationsList);
  }

  void dispose() {
    _messagePersonBehaviorSubject.close();
    _conversationsFoundStreamController.close();
  }
}
