import 'package:flutter_test/flutter_test.dart';
import 'package:gymtrack/core/utils/language_resolver.dart';

void main() {
  group('LanguageResolver Tests', () {
    test('returns saved language if valid ("vi" or "en")', () {
      expect(
        resolveLanguageCode(saved: 'vi', platformLanguageCode: 'en'),
        equals('vi'),
      );
      expect(
        resolveLanguageCode(saved: 'en', platformLanguageCode: 'vi'),
        equals('en'),
      );
    });

    test('ignores invalid saved language and resolves platform language', () {
      expect(
        resolveLanguageCode(saved: 'fr', platformLanguageCode: 'vi'),
        equals('vi'),
      );
      expect(
        resolveLanguageCode(saved: '', platformLanguageCode: 'vi-VN'),
        equals('vi'),
      );
    });

    test('falls back to platform language when saved is null', () {
      expect(
        resolveLanguageCode(saved: null, platformLanguageCode: 'vi'),
        equals('vi'),
      );
      expect(
        resolveLanguageCode(saved: null, platformLanguageCode: 'vi_VN'),
        equals('vi'),
      );
      expect(
        resolveLanguageCode(saved: null, platformLanguageCode: 'VI'),
        equals('vi'),
      );
    });

    test('falls back to "en" when platform language is not Vietnamese and saved is null', () {
      expect(
        resolveLanguageCode(saved: null, platformLanguageCode: 'en'),
        equals('en'),
      );
      expect(
        resolveLanguageCode(saved: null, platformLanguageCode: 'fr'),
        equals('en'),
      );
      expect(
        resolveLanguageCode(saved: null, platformLanguageCode: 'ja'),
        equals('en'),
      );
      expect(
        resolveLanguageCode(saved: null, platformLanguageCode: null),
        equals('en'),
      );
    });
  });
}
