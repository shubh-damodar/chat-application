import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mesbro_chat_flutter_app/network/user_connect.dart';

class ServicesConnect {
//  String _servicesBaseUrl = 'http://services.simplifying.world/apis/v1.0.1/';
  String _servicesBaseUrl = 'http://services.mesbro.com/apis/v1.0.1/';

  static String contactsList = 'contacts/list', a = '';

  Future<Map<String, dynamic>> sendServicesPost(
      Map<String, dynamic> mapBody, String url) async {
//    //print('~~~ sendServicesPost: $_baseUrl$url ${currentUser.au}');
    http.Response response =
        await http.post('$_servicesBaseUrl$url', body: mapBody, headers: {
      'au': Connect.currentUser == null ? '' : Connect.currentUser.au,
      'ut-${Connect.currentUser.au}': '${Connect.currentUser.token}'
    });
    //print('~~~ sendServicesPost: ${response.body}');
    Map<String, dynamic> map = jsonDecode(response.body);
    return map;
  }

  Future<Map<String, dynamic>> sendServicesPostWithHeaders(
      dynamic mapBody, String url) async {
    //print(
        // '~~~ sendServicesPostWithHeaders: $_servicesBaseUrl$url ${Connect.currentUser.au} ${Connect.currentUser.token}');
    HttpClient httpClient = new HttpClient();
    HttpClientRequest request =
        await httpClient.postUrl(Uri.parse('$_servicesBaseUrl$url'));
    request.headers.add('au', Connect.currentUser.au);
    request.headers
        .add('ut-${Connect.currentUser.au}', '${Connect.currentUser.token}');
    request.add(utf8.encode(json.encode(mapBody)));
    HttpClientResponse httpClientResponse = await request.close();
    String response = await httpClientResponse.transform(utf8.decoder).join();
    httpClient.close();
    Map<String, dynamic> map = jsonDecode(response);
    //print('~~~ sendServicesPostWithHeaders: $response');
    return map;
  }

  Future<Map<String, dynamic>> sendServicesGet(String url) async {
    //print('~~~ sendServicesGet: $_servicesBaseUrl$url');
    http.Response response = await http.get('$_servicesBaseUrl$url');
    //print('~~~ sendServicesGet: ${response.body}');
    Map<String, dynamic> map = json.decode(response.body);
    return map;
  }

  Future<Map<String, dynamic>> sendServicesGetWithHeaders(String url) async {
    //print(
        // '~~~ sendServicesPostWithHeaders: $_servicesBaseUrl$url ${Connect.currentUser.au} ${Connect.currentUser.token}');
    HttpClient httpClient = new HttpClient();
    HttpClientRequest request =
        await httpClient.getUrl(Uri.parse('$_servicesBaseUrl$url'));
    request.headers.add('au', Connect.currentUser.au);
    request.headers
        .add('ut-${Connect.currentUser.au}', '${Connect.currentUser.token}');
    HttpClientResponse httpClientResponse = await request.close();
    String response = await httpClientResponse.transform(utf8.decoder).join();
    httpClient.close();
    Map<String, dynamic> map = jsonDecode(response);
    //print('~~~ sendServicesPostWithHeaders: $response');
    return map;
  }
}
