import 'package:mesbro_chat_flutter_app/models/user.dart';
import 'package:mesbro_chat_flutter_app/network/services_connect.dart';
import 'package:mesbro_chat_flutter_app/network/user_connect.dart';

class ContactListDetails {
  ServicesConnect _servicesConnect = ServicesConnect();
  List<User> usersList = List<User>();
  Future<List<User>> getSuggestions(String nameLetter) async {
    usersList = List<User>();
    Map<String, dynamic> mapResponse =
        await _servicesConnect.sendServicesGetWithHeaders(
            '${ServicesConnect.contactsList}?query=$nameLetter&domainSpecific=true');
    if (mapResponse['code'] == 200) {
      List<dynamic> dynamicList = mapResponse['content'] as List<dynamic>;
      dynamicList
          .map((i) => usersList.add(User.fromJSONAddNewGroupMember(i)))
          .toList();
    }
    usersList
        .removeWhere((User user) => user.userId == Connect.currentUser.userId);
    //print('~~~ uersList: ${usersList.toList()}');
    return usersList;
  }
}
