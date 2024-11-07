// ignore_for_file: constant_identifier_names

import 'dart:convert';

import 'package:http/http.dart' as http;

import 'sharedpreferences.dart';

class PictApi {
  static const String BASE_URL = 'https://pictioniary.wevox.cloud/api';
  static const String LOGIN = '/login';
  static const String REGISTER = '/players';
  static const String GAME_SESSIONS = '/game_sessions';
  static const String CHALLENGES_TO_GUESS = '/myChallengesToGuess';
  static const String FINISH_SESSION = '/answer';

  static Future<dynamic> get(String endpoint) async {
    final headers = await _headers();
    final response = await http.get(Uri.parse('$BASE_URL$endpoint'), headers: headers);
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final headers = await _headers();
    final response = await http.post(
      Uri.parse('$BASE_URL$endpoint'),
      body: jsonEncode(body),
      headers: headers,
    );
    return _handleResponse(response) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> postChallenge(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final headers = await _headers();
    final response = await http.post(
      Uri.parse('$BASE_URL$endpoint'),
      body: jsonEncode(body),
      headers: headers,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    final payload = jsonDecode(response.body);
    if (payload['message'] == 'Game session is not in the challenge phase') {
      throw Exception(payload['message']);
    }

    final buffer = StringBuffer();
    if (payload['message'] is Map) {
      payload['message'].forEach((_, value) {
        if (value is List && value.isNotEmpty) {
          buffer.writeln(value.first);
        }
      });
    }

    final message = buffer.isNotEmpty
        ? buffer.toString()
        : 'Une erreur est survenue. Veuillez réessayer plus tard.';
    throw Exception(message.trim());
  }

  static Future<Map<String, String>> _headers() async {
    final token = await SharedPreferencesHelper.getString('token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode == 404) {
      throw Exception('Not found');
    }

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Request failed');
    }

    return jsonDecode(response.body);
  }
}
