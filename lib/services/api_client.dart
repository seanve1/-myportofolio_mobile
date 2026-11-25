import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/config.dart';
import 'package:myportofolio_mobile/models/organization.dart';

/// Exception thrown when an API request returns a non-2xx status code.
class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  // SessionAuthentication comes first in the existing Django views, so
  // DRF can return 403 rather than 401 for an invalid token.
  bool get isAuthenticationFailure {
    if (statusCode == 401) return true;
    if (statusCode != 403) return false;
    try {
      final data = jsonDecode(message);
      if (data is! Map<String, dynamic>) return false;
      final detail = data['detail'];
      return detail is String &&
          (detail == 'Invalid token.' ||
              detail == 'Authentication credentials were not provided.' ||
              detail == 'User inactive or deleted.' ||
              detail.startsWith('Invalid token header.'));
    } on FormatException {
      return false;
    }
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// HTTP client for the MyPortfolio Django REST Framework backend.
class ApiClient {
  ApiClient({http.Client? client, this.baseUrl = apiBaseUrl})
    : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;

  void close() {
    _client.close();
  }

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  /// Retrieve all organizations from Django.
  Future<List<Organization>> getOrganizations({String? token}) async {
    final headers = <String, String>{'Accept': 'application/json'};

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Token $token';
    }

    final response = await _client.get(
      _uri('/api/v1/organizations/'),
      headers: headers,
    );

    _ensureSuccess(response);

    final decoded =
        jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;

    return decoded
        .map((item) => Organization.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Create a new organization using token authentication.
  Future<Organization> createOrganization(
    Organization organization, {
    required String token,
  }) async {
    final response = await _client.post(
      _uri('/api/v1/organizations/'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Token $token',
      },
      body: jsonEncode(organization.toJson()),
    );

    _ensureSuccess(response);

    final decoded =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

    return Organization.fromJson(decoded);
  }

  /// Toggle the current user's star on an existing organization.
  Future<Organization> toggleOrganizationStar(
    String id, {
    required String token,
  }) async {
    final response = await _client.post(
      _uri('/api/v1/organizations/$id/star/'),
      headers: {'Accept': 'application/json', 'Authorization': 'Token $token'},
    );
    _ensureSuccess(response);
    return Organization.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }

  /// Exchange username and password for an authentication token.
  Future<String> obtainToken(String username, String password) async {
    final response = await _client.post(
      _uri('/api/v1/auth/token/'),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'username': username, 'password': password}),
    );

    _ensureSuccess(response);

    final decoded =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

    return decoded['token'] as String;
  }

  /// Revoke the current authentication token.
  Future<void> logout({required String token}) async {
    final response = await _client.post(
      _uri('/api/v1/auth/logout/'),
      headers: {'Accept': 'application/json', 'Authorization': 'Token $token'},
    );

    _ensureSuccess(response);
  }

  /// Check whether the HTTP response indicates success.
  void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw ApiException(
      response.statusCode,
      utf8.decode(response.bodyBytes, allowMalformed: true),
    );
  }
}
