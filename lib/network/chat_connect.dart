import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'user_connect.dart';

class ChatConnect {
//  String _chatBaseUrl = 'http://chat.simplifying.world/apis/v1.0.1/';
  String _chatBaseUrl = 'https://chat.mesbro.com/apis/v1.0.1/';

  static String conversationList = 'conversations/list',
      conversationGetMessages = 'conversations/get-messages',
      conversationAddNew = 'conversations/add-new',
      conversationManage = 'conversations/manage',
      conversationManageMembers = 'conversations/manage-members',
      a = '';

  Future<Map<String, dynamic>> sendChatPost(
      Map<String, dynamic> mapBody, String url) async {
//    //print('~~~ sendChatPost: $_baseUrl$url ${currentUser.au}');
    http.Response response = await http
        .post('$_chatBaseUrl$url', body: json.encode(mapBody), headers: {
      'au': Connect.currentUser == null ? '' : Connect.currentUser.au,
      'ut-${Connect.currentUser.au}': '${Connect.currentUser.token}',
      "Content-Type": "application/json"
    });
    //print('~~~ sendChatPost: ${response.body}');
    Map<String, dynamic> map = jsonDecode(response.body);
    return map;
  }

  Future<Map<String, dynamic>> sendChatPostWithHeaders(
      dynamic mapBody, String url) async {
    //print(
        // '~~~ sendChatPostWithHeaders: ${HttpHeaders.contentTypeHeader} $_chatBaseUrl$url ${Connect.currentUser.au} ${Connect.currentUser.token}');
    HttpClient httpClient = new HttpClient();
    HttpClientRequest request =
        await httpClient.postUrl(Uri.parse('$_chatBaseUrl$url'));
    request.headers.add(HttpHeaders.contentTypeHeader, 'application/json');
    request.headers.add('au', Connect.currentUser.au);
    request.headers
        .add('ut-${Connect.currentUser.au}', '${Connect.currentUser.token}');
    request.add(utf8.encode(json.encode(mapBody)));
    HttpClientResponse httpClientResponse = await request.close();
    String response = await httpClientResponse.transform(utf8.decoder).join();
    httpClient.close();
    Map<String, dynamic> map = jsonDecode(response);
    //print('~~~ sendChatPostWithHeaders: $response');
    return map;
  }

  Future<Map<String, dynamic>> sendChatGet(String url) async {
    //print('~~~ sendChatGet: $_chatBaseUrl$url');
    http.Response response = await http.get('$_chatBaseUrl$url');
    //print('~~~ sendChatGet: ${response.body}');
    Map<String, dynamic> map = json.decode(response.body);
    return map;
  }
}
