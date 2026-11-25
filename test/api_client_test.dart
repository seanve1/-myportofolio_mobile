import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/models/organization.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

void main() {
  const baseUrl = 'http://localhost:8000';

  test(
    'GET public and authenticated organizations decode JSON correctly',
    () async {
      var requests = 0;
      final client = ApiClient(
        baseUrl: baseUrl,
        client: MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, '/api/v1/organizations/');
          expect(
            request.headers['authorization'],
            requests == 0 ? isNull : 'Token test-token',
          );
          requests++;
          return http.Response.bytes(
            utf8.encode(
              jsonEncode([
                {
                  'id': 'demo-id',
                  'title': 'Pengalaman',
                  'category': 'Organisasi',
                  'desc_1': 'Tugas – kegiatan',
                  'started_at': '2026-01-01T00:00:00Z',
                  'star_count': 2,
                  'is_starred': requests == 2,
                },
              ]),
            ),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      addTearDown(client.close);
      final public = await client.getOrganizations();
      expect(public.single.desc1, 'Tugas – kegiatan');
      expect(public.single.startedAt, DateTime.utc(2026, 1, 1));
      expect(public.single.endedAt, isNull);
      expect(public.single.isStarred, isFalse);
      final authenticated = await client.getOrganizations(token: 'test-token');
      expect(authenticated.single.isStarred, isTrue);
      expect(authenticated.single.starCount, 2);
    },
  );

  test(
    'POST sends the serializer fields and excludes server-computed fields',
    () async {
      final client = ApiClient(
        baseUrl: baseUrl,
        client: MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.path, '/api/v1/organizations/');
          expect(request.headers['authorization'], 'Token test-token');
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['title'], 'Staff');
          expect(body['category'], 'Organization');
          expect(body['desc_1'], 'Description');
          expect(body['ended_at'], isNull);
          expect(body.keys, isNot(contains('id')));
          expect(body.keys, isNot(contains('star_count')));
          expect(body.keys, isNot(contains('is_starred')));
          expect(body.keys, isNot(contains('starred_by_names')));
          return http.Response(jsonEncode({...body, 'id': 'server-id'}), 201);
        }),
      );
      addTearDown(client.close);
      final saved = await client.createOrganization(
        const Organization(
          title: 'Staff',
          category: 'Organization',
          desc1: 'Description',
        ),
        token: 'test-token',
      );
      expect(saved.id, 'server-id');
    },
  );

  test('Login, star and logout send the expected requests', () async {
    final client = ApiClient(
      baseUrl: baseUrl,
      client: MockClient((request) async {
        expect(request.method, 'POST');
        if (request.url.path == '/api/v1/auth/token/') {
          expect(jsonDecode(request.body), {
            'username': 'demo',
            'password': 'demo-password',
          });
          return http.Response('{"token":"test-token"}', 200);
        }
        expect(request.headers['authorization'], 'Token test-token');
        if (request.url.path == '/api/v1/organizations/demo-id/star/') {
          return http.Response(
            '{"id":"demo-id","title":"Staff","category":"Organization","star_count":1,"is_starred":true}',
            200,
          );
        }
        expect(request.url.path, '/api/v1/auth/logout/');
        return http.Response('', 204);
      }),
    );
    addTearDown(client.close);
    final token = await client.obtainToken('demo', 'demo-password');
    expect(token, 'test-token');
    final starred = await client.toggleOrganizationStar(
      'demo-id',
      token: token,
    );
    expect(starred.isStarred, isTrue);
    expect(starred.starCount, 1);
    await client.logout(token: token);
  });

  test('401 and invalid-token 403 differ from permission-denied 403', () async {
    expect(const ApiException(401, '{}').isAuthenticationFailure, isTrue);
    expect(
      const ApiException(
        403,
        '{"detail":"Invalid token."}',
      ).isAuthenticationFailure,
      isTrue,
    );
    expect(
      const ApiException(
        403,
        '{"detail":"Permission denied."}',
      ).isAuthenticationFailure,
      isFalse,
    );
    final client = ApiClient(
      baseUrl: baseUrl,
      client: MockClient(
        (_) async => http.Response('{"detail":"Permission denied."}', 403),
      ),
    );
    addTearDown(client.close);
    await expectLater(
      client.getOrganizations(),
      throwsA(
        isA<ApiException>().having((e) => e.statusCode, 'statusCode', 403),
      ),
    );
  });
}
