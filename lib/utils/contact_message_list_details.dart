import 'package:mesbro_chat_flutter_app/models/conversation.dart';

class ContactMessageListDetails {
  List<Conversation> conversationsList;

  ContactMessageListDetails(List<Conversation> sentConversationsList) {
    conversationsList = sentConversationsList;
    //print('~~~ len: ${conversationsList.length}');
  }
//  void initializeContacts(List<Conversation> sentConversationsList) {
//    conversationsList=sentConversationsList;
//    //print('~~~ initializeContacts: ${conversationsList.length}');
//  }
  Future<List<Conversation>> getSuggestions(String personMemberLetter) async {
    List<Conversation> matchedConversationsList = List<Conversation>();

    for (Conversation conversation in conversationsList) {
      //print(
          // '~~~ 1st getSuggestions: $personMemberLetter ${conversation.latestMessage} ${conversation.sentUser.name}');

      if ((conversation.sentUser.name
                  .toLowerCase()
                  .contains(personMemberLetter.toLowerCase()) &&
              conversation.groupName == '') ||
          (conversation.groupName != '' &&
              conversation.groupName
                  .toLowerCase()
                  .contains(personMemberLetter.toLowerCase()))) {
        //print('~~~ matched ${conversation.sentUser.name} ');
        matchedConversationsList.add(conversation);
      }
    }
    return matchedConversationsList;
  }
}
