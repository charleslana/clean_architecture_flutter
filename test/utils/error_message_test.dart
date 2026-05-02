import 'dart:async';
import 'dart:io';

import 'package:clean_architecture_flutter/data/services/api/api_client.dart';
import 'package:clean_architecture_flutter/utils/error_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('errorMessageFor', () {
    test('null returns generic Unknown error', () {
      expect(errorMessageFor(null), 'Unknown error');
    });

    test('TimeoutException returns "Timeout"', () {
      expect(errorMessageFor(TimeoutException('x')), 'Timeout');
    });

    test('SocketException returns "No internet"', () {
      expect(errorMessageFor(const SocketException('x')), 'No internet');
    });

    test('mapped HTTP status codes return "<code> <reason>"', () {
      expect(
        errorMessageFor(const HttpException(401, 'm')),
        '401 Unauthorized',
      );
      expect(errorMessageFor(const HttpException(404, 'm')), '404 Not Found');
      expect(
        errorMessageFor(const HttpException(500, 'm')),
        '500 Internal Server Error',
      );
    });

    test(
      'UNMAPPED status codes fall through to "<code> (unmapped status)"',
      () {
        // 422 is intentionally not in the table — exercises the fallback.
        expect(
          errorMessageFor(const HttpException(422, 'm')),
          '422 (unmapped status)',
        );
        expect(
          errorMessageFor(const HttpException(418, 'm')),
          '418 (unmapped status)',
        );
      },
    );

    test('unknown Exception returns its toString', () {
      expect(errorMessageFor(Exception('boom')), 'Exception: boom');
    });
  });
}
