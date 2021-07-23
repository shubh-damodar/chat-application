import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:mesbro_chat_flutter_app/network/user_connect.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketConnect {
//  String webSocketWsUrl = 'ws://chat.simplifying.world/ws?au=';
  String webSocketWsUrl = 'ws://chat.mesbro.com/ws?au=';

  IOWebSocketChannel webSocketChannel;

  void receiveChatMessages() {
//    do  {
//      //print('~~~ receiveChatMessages: do');
//      webSocketChannel.stream.asBroadcastStream().listen((dynamic jsonDecodedMessageDynamic) {
//        Map<String, dynamic> mapEncodedJSON=json.decode(jsonDecodedMessageDynamic.toString());
//      if(mapEncodedJSON['code']==200) {
//        //print('~~~ 1st jsonMessageDynamic: ${mapEncodedJSON.values.toList()}');
//      }else {
//        //print('~~~ 2nd jsonMessageDynamic: ${mapEncodedJSON.values.toList()}');
//      }
//      });
//    }while(webSocketChannel==null);
  }

  Future<void> sendPingMessageAfterIntervals() async {
    disposeWebSocketChannel();
    webSocketChannel = IOWebSocketChannel.connect(
        '$webSocketWsUrl${Connect.currentUser.au}',
        headers: {
          'ut-${Connect.currentUser.au}': '${Connect.currentUser.token}'
        });
    if (webSocketChannel == null) {
      //print('~~~  doesn\'t exists');
    } else {
      //print('~~~ exists');
    }

    //print(
    // '~~~ sendPing ${webSocketChannel} $webSocketWsUrl${Connect.currentUser.au}');
    Timer.periodic(Duration(seconds: 25), (timer) {
      //print('~~~ sent ping');
      if (webSocketChannel != null) {
        webSocketChannel.sink.add(json.encode(json.encode('ping')));
      }
    });
  }

  Future<void> sendChatMessage(String jsonBody) async {
    //print('~~~ sendChatMessage $jsonBody');
//    if(webSocketChannel!=null) {
    webSocketChannel.sink.add(jsonBody);
//    }
  }

  Future<void> disposeWebSocketChannel() async {
    //print('~~~ disposeWebSocketChannel');
//    if(webSocketChannel!=null) {
    if (webSocketChannel != null) {
      //print('~~~ webSocketChannel is not null');
      webSocketChannel.sink.close();

      webSocketChannel = null;
    } else {
      //print('~~~ webSocketChannel is null');
    }
  }
}
