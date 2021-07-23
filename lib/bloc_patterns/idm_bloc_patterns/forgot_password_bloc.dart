import 'dart:async';
import 'package:mesbro_chat_flutter_app/network/user_connect.dart';

class ForgotPasswordBloc {
  StreamController<Map<String, dynamic>> _validateStreamController =
      StreamController<Map<String, dynamic>>();

  StreamSink<Map<String, dynamic>> get validateStreamSink =>
      _validateStreamController.sink;

  Stream<Map<String, dynamic>> get validateStream =>
      _validateStreamController.stream;

  void validateOTPNumber(String username) {
    Connect _connect = Connect();
    _connect
        .sendGet('${Connect.forgotPassword}$username')
        .then((Map<String, dynamic> mapResponse) {
      validateStreamSink.add(mapResponse);
    });
  }

  void dispose() {
    _validateStreamController.close();
  }
}
