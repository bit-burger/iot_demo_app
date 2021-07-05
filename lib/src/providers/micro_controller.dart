import 'dart:async';

import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:async/async.dart';
import 'package:iot_app/src/providers/preferences.dart';

class MicroController {
  static const _jsonHeaders = <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
  };

  MicroController.specifyClient(this._preferences, this._httpClient);

  MicroController(this._preferences) : _httpClient = http.Client();

  final Preferences _preferences;
  final http.Client _httpClient;

  Future<Result<dynamic?>> makeRequest(
    String path, [
    Method method = Method.GET,
    dynamic? jsonBody,
  ]) async {
    assert(method != Method.GET || jsonBody == null);
    assert(jsonBody != null || method == Method.GET);
    assert(path.startsWith('/'));

    final parsedUrl = Uri.parse(_preferences.url + path);
    final parsedBody = jsonBody == null ? null : convert.jsonEncode(jsonBody);

    try {
      final response = await _getResponse(method, parsedUrl, parsedBody);
      if (response.statusCode == 200) {
        final rawJson = response.body;

        if (rawJson.isEmpty) return Result.value(null);

        final parsedJson = convert.jsonDecode(rawJson);

        return Result.value(parsedJson);
      } else {
        return Result.error(
          'Could not reach the micro controller,'
          'make sure it is on and connected to your local w-lan',
        );
      }
    } on TimeoutException {
      return Result.error('Request to micro controller timed out');
    } on Exception {
      return Result.error(
        'Unknown error while requesting data'
        'from the micro controller',
      );
    }
  }

  Future<http.Response> _getResponse(
      Method method, Uri parsedUrl, String? parsedBody) {
    switch (method) {
      case Method.GET:
        return _httpClient.get(parsedUrl);
      case Method.PUT:
        return _httpClient.put(
          parsedUrl,
          headers: _jsonHeaders,
          body: parsedBody,
        );
      case Method.POST:
        return _httpClient.post(
          parsedUrl,
          headers: _jsonHeaders,
          body: parsedBody,
        );
      default:
        throw Error();
    }
  }
}

enum Method { GET, PUT, POST }
