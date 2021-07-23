import 'dart:async';
import 'package:mesbro_chat_flutter_app/network/user_connect.dart';
import 'package:mesbro_chat_flutter_app/validators/edit_contact_validators.dart';

class EditContactBloc with EditContactValidators {
  Map<String, dynamic> _userMap;

  EditContactBloc(Map<String, dynamic> sentUserMap) {
    _userMap = sentUserMap;
  }

  final StreamController<Map<String, dynamic>> _editContactStreamController =
      StreamController<Map<String, dynamic>>.broadcast();

  StreamSink<Map<String, dynamic>> get editContactStreamSink =>
      _editContactStreamController.sink;

  Stream<Map<String, dynamic>> get editContactStream =>
      _editContactStreamController.stream;

  void updateUserContact(String alternateMobile, String alternateEmail,
      String website, String alternateWebsite) async {
    Map<String, dynamic> mapBody = Map<String, dynamic>();

    if (alternateMobile != '') {
      Map<String, String> mapAlternateMobile = Map<String, String>();
      mapAlternateMobile['countryCode'] = _userMap['countryCode'];
      mapAlternateMobile['mobile'] = alternateMobile;
      mapBody['alternateMobile'] = mapAlternateMobile;
    }
    mapBody['website'] = website;
    mapBody['alternateWebsite'] = alternateWebsite;
    //print('~~~ mapBody: $mapBody');
    Connect _connect = Connect();
    _connect
        .sendHeadersPost(mapBody, Connect.userUpdate)
        .then((Map<String, dynamic> mapResponse) {
      editContactStreamSink.add(mapResponse);
    });
  }

  void dispose() {
    _editContactStreamController.close();
  }
}
