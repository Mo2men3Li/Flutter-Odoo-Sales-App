import 'dart:convert';

import 'package:http/http.dart' as http;

class OdooApi {
  OdooApi({required this.baseUrl, required this.db});

  final String baseUrl;
  final String db;

  String? _sessionCookie;
  int? uid;

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_sessionCookie != null) 'Cookie': _sessionCookie!,
  };

  Future<bool> login(String login, String password) async {
    final res = await http.post(
      _uri('/web/session/authenticate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'jsonrpc': '2.0',
        'method': 'call',
        'params': {'db': db, 'login': login, 'password': password},
      }),
    );

    final body = jsonDecode(res.body);
    if (body['error'] != null) return false;

    final result = body['result'];
    if (result == null || result['uid'] == null) return false;

    uid = result['uid'];

    final setCookie = res.headers['set-cookie'];
    if (setCookie != null) {
      _sessionCookie = setCookie.split(';').first;
    }
    return true;
  }

  Future<dynamic> callKw({
    required String model,
    required String method,
    List<dynamic> args = const [],
    Map<String, dynamic> kwargs = const {},
  }) async {
    final res = await http.post(
      _uri('/web/dataset/call_kw'),
      headers: _headers,
      body: jsonEncode({
        'jsonrpc': '2.0',
        'method': 'call',
        'params': {
          'model': model,
          'method': method,
          'args': args,
          'kwargs': kwargs,
        },
      }),
    );

    final body = jsonDecode(res.body);
    if (body['error'] != null) {
      throw Exception(body['error']['data']?['message'] ?? 'Odoo error');
    }
    return body['result'];
  }

  Future<List<dynamic>> searchRead({
    required String model,
    List<dynamic> domain = const [],
    required List<String> fields,
  }) async {
    final result = await callKw(
      model: model,
      method: 'search_read',
      args: [domain, fields],
    );
    return result as List<dynamic>;
  }

  Future<void> writeRecord({
    required String model,
    required int id,
    required Map<String, dynamic> values,
  }) async {
    await callKw(
      model: model,
      method: 'write',
      args: [
        [id],
        values,
      ],
    );
  }

  Future<bool> isInternalUser() async {
    final result = await callKw(
      model: 'res.users',
      method: 'has_group',
      args: [
        [uid],
        'base.group_user'
      ],
    );
    return result == true;
  }
}
