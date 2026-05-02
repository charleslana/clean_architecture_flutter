import 'dart:async';
import 'dart:io';

import 'package:clean_architecture_flutter/data/services/http/error_injecting_http_service.dart';
import 'package:clean_architecture_flutter/data/services/http/error_injector.dart';
import 'package:clean_architecture_flutter/data/services/http/http_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../utils/fakes.dart';

void main() {
  group('ErrorInjectingHttpService', () {
    final inner = FakeHttpService(
      onGet: (_) async => const HttpResponse(statusCode: 200, body: 'ok'),
    );

    test('passes through when ErrorMode.none', () async {
      final injector = ErrorInjector();
      final service = ErrorInjectingHttpService(
        inner: inner,
        injector: injector,
      );

      final response = await service.get(Uri.parse('https://x.test/'));

      expect(response.statusCode, 200);
      expect(response.body, 'ok');
    });

    test('throws SocketException for noInternet', () async {
      final injector = ErrorInjector()..mode = ErrorMode.noInternet;
      final service = ErrorInjectingHttpService(
        inner: inner,
        injector: injector,
      );

      await expectLater(
        service.get(Uri.parse('https://x.test/')),
        throwsA(isA<SocketException>()),
      );
    });

    test('throws TimeoutException for timeout', () async {
      final injector = ErrorInjector()..mode = ErrorMode.timeout;
      final service = ErrorInjectingHttpService(
        inner: inner,
        injector: injector,
      );

      await expectLater(
        service.get(Uri.parse('https://x.test/')),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('unexpectedShape returns 200 OK with a malformed body', () async {
      final injector = ErrorInjector()..mode = ErrorMode.unexpectedShape;
      final service = ErrorInjectingHttpService(
        inner: inner,
        injector: injector,
      );

      final response = await service.get(Uri.parse('https://x.test/'));

      expect(response.statusCode, 200);
      expect(response.isSuccessful, isTrue);
      expect(response.body, '[{}]');
    });

    test('returns the matching status code for HTTP error modes', () async {
      const codeByMode = {
        ErrorMode.badRequest: 400,
        ErrorMode.unauthorized: 401,
        ErrorMode.forbidden: 403,
        ErrorMode.notFound: 404,
        ErrorMode.unprocessableEntity: 422,
        ErrorMode.tooManyRequests: 429,
        ErrorMode.serverError: 500,
        ErrorMode.badGateway: 502,
        ErrorMode.serviceUnavailable: 503,
      };

      for (final entry in codeByMode.entries) {
        final injector = ErrorInjector()..mode = entry.key;
        final service = ErrorInjectingHttpService(
          inner: inner,
          injector: injector,
        );

        final response = await service.get(Uri.parse('https://x.test/'));

        expect(
          response.statusCode,
          entry.value,
          reason: '${entry.key} should produce ${entry.value}',
        );
        expect(response.isSuccessful, isFalse);
      }
    });
  });
}
