import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'app_exceptions.dart';

class BaseClient {
  static const int timeOutDuration = 20;
  //GET
  Future<dynamic> get(String baseUrl, String api) async {
    var uri = Uri.parse(baseUrl + api);
    // log("uri: $uri");
    try {
      var response = await http.get(uri).timeout(const Duration(seconds: timeOutDuration));
      // log("SIMPLE RESPONSE \n  ${response.body}");
      return _processResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection', uri.toString());
    } on TimeoutException {
      throw ApiNotRespondingException('API not responded in time', uri.toString());
    }
  }

  //POST
  Future<dynamic> postOriginal(String baseUrl, String api, dynamic payloadObj) async {
    var uri = Uri.parse(baseUrl + api);
    var payload = json.encode(payloadObj);
    try {
      var response = await http.post(uri, body: payload).timeout(const Duration(seconds: timeOutDuration));
      return _processResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection', uri.toString());
    } on TimeoutException {
      throw ApiNotRespondingException('API not responded in time', uri.toString());
    }
  }

  Future<dynamic> post(String baseUrl, String api, Map<String, dynamic> body) async {
    Uri uri = Uri.parse(baseUrl + api);
    log("Generated Url  $uri");
    // var payload = json.encode(payloadObj);
    try {
      var response = await http.post(uri, body: body).timeout(const Duration(seconds: timeOutDuration));
      // log("SIMPLE RESPONSE \n  ${response.body}");

      return _processResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection', uri.toString());
    } on TimeoutException {
      throw ApiNotRespondingException('API not responded in time', uri.toString());
    }
  }

  //DELETE
  //OTHER

  dynamic _processResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        // var responseJson = utf8.decode(response.bodyBytes);

        // var responseJson = jsonDecode(response.body);
        Map<String, dynamic> responseJson = Map<String, dynamic>.from(json.decode(response.body));
        return responseJson;
        break;
      case 201:
        var responseJson = utf8.decode(response.bodyBytes);
        return responseJson;
        break;
      case 400:
        throw BadRequestException(utf8.decode(response.bodyBytes), response.request!.url.toString());
      case 401:
      case 403:
        throw UnAuthorizedException(utf8.decode(response.bodyBytes), response.request!.url.toString());
      case 422:
        throw BadRequestException(utf8.decode(response.bodyBytes), response.request!.url.toString());
      case 500:
      default:
        throw FetchDataException('Error occurred with code : ${response.statusCode}', response.request!.url.toString());
    }
  }
}
