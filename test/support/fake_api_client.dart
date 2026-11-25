import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/organization.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

class FakeApiClient extends ApiClient {
  FakeApiClient({this.createError, List<Organization> initial = const []})
    : records = List.of(initial);

  final ApiException? createError;
  final List<Organization> records;
  Organization? submitted;
  String? submittedToken;
  String? revokedToken;
  String? listToken;

  @override
  Future<List<Organization>> getOrganizations({String? token}) async {
    listToken = token;
    return List.of(records);
  }

  @override
  Future<String> obtainToken(String username, String password) async {
    if (username == 'demo' && password == 'demo-password') return 'test-token';
    throw const ApiException(400, 'Invalid credentials');
  }

  @override
  Future<void> logout({required String token}) async {
    revokedToken = token;
  }

  @override
  Future<Organization> createOrganization(
    Organization organization, {
    required String token,
  }) async {
    submitted = organization;
    submittedToken = token;
    if (createError != null) throw createError!;
    final saved = Organization.fromJson({
      ...organization.toJson(),
      'id': 'test-id',
    });
    records.add(saved);
    return saved;
  }

  @override
  Future<Organization> toggleOrganizationStar(
    String id, {
    required String token,
  }) async {
    final index = records.indexWhere((item) => item.id == id);
    final old = records[index];
    final updated = Organization.fromJson({
      ...old.toJson(),
      'id': old.id,
      'is_starred': !old.isStarred,
      'star_count': old.starCount + (old.isStarred ? -1 : 1),
    });
    records[index] = updated;
    return updated;
  }
}

Widget buildTestApp(
  Widget home, {
  FakeApiClient? client,
  String? initialToken = 'test-token',
}) {
  return MultiProvider(
    providers: [
      Provider<ApiClient>(
        create: (_) => client ?? FakeApiClient(),
        dispose: (_, api) => api.close(),
      ),
      ChangeNotifierProvider<AuthState>(
        create: (context) =>
            AuthState(context.read<ApiClient>(), initialToken: initialToken),
      ),
    ],
    child: MaterialApp(home: home),
  );
}
