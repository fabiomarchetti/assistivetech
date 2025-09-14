import 'package:flutter_test/flutter_test.dart';
import 'package:agenda/utils/validators.dart';

void main() {
  group('InputValidators', () {
    group('validateAgendaName', () {
      test('should return error for null input', () {
        expect(InputValidators.validateAgendaName(null), isNotNull);
      });

      test('should return error for empty input', () {
        expect(InputValidators.validateAgendaName(''), isNotNull);
        expect(InputValidators.validateAgendaName('   '), isNotNull);
      });

      test('should return error for name too short', () {
        expect(InputValidators.validateAgendaName('a'), isNotNull);
      });

      test('should return error for name too long', () {
        final longName = 'a' * 51;
        expect(InputValidators.validateAgendaName(longName), isNotNull);
      });

      test('should return error for invalid characters', () {
        expect(InputValidators.validateAgendaName('test<'), isNotNull);
        expect(InputValidators.validateAgendaName('test>'), isNotNull);
        expect(InputValidators.validateAgendaName('test:'), isNotNull);
        expect(InputValidators.validateAgendaName('test"'), isNotNull);
        expect(InputValidators.validateAgendaName('test/'), isNotNull);
        expect(InputValidators.validateAgendaName('test\\'), isNotNull);
        expect(InputValidators.validateAgendaName('test|'), isNotNull);
        expect(InputValidators.validateAgendaName('test?'), isNotNull);
        expect(InputValidators.validateAgendaName('test*'), isNotNull);
      });

      test('should return error for names starting/ending with space or dot', () {
        expect(InputValidators.validateAgendaName(' test'), isNotNull);
        expect(InputValidators.validateAgendaName('test '), isNotNull);
        expect(InputValidators.validateAgendaName('.test'), isNotNull);
        expect(InputValidators.validateAgendaName('test.'), isNotNull);
      });

      test('should return null for valid names', () {
        expect(InputValidators.validateAgendaName('Test'), isNull);
        expect(InputValidators.validateAgendaName('Agenda Mattina'), isNull);
        expect(InputValidators.validateAgendaName('Attività 123'), isNull);
        expect(InputValidators.validateAgendaName('Test-Name_456'), isNull);
      });
    });

    group('validateActivityName', () {
      test('should return error for null input', () {
        expect(InputValidators.validateActivityName(null), isNotNull);
      });

      test('should return error for empty input', () {
        expect(InputValidators.validateActivityName(''), isNotNull);
        expect(InputValidators.validateActivityName('   '), isNotNull);
      });

      test('should return error for name too long', () {
        final longName = 'a' * 101;
        expect(InputValidators.validateActivityName(longName), isNotNull);
      });

      test('should return null for valid names', () {
        expect(InputValidators.validateActivityName('Test'), isNull);
        expect(InputValidators.validateActivityName('Pittogramma Casa'), isNull);
        expect(InputValidators.validateActivityName('a' * 100), isNull);
      });
    });

    group('sanitizeForFilename', () {
      test('should handle basic string', () {
        expect(
          InputValidators.sanitizeForFilename('Test Name'),
          equals('test_name'),
        );
      });

      test('should remove invalid characters', () {
        expect(
          InputValidators.sanitizeForFilename('Test@#\$Name!'),
          equals('testname'),
        );
      });

      test('should handle multiple spaces', () {
        expect(
          InputValidators.sanitizeForFilename('Test    Multiple   Spaces'),
          equals('test_multiple_spaces'),
        );
      });

      test('should trim underscores', () {
        expect(
          InputValidators.sanitizeForFilename('  _Test_  '),
          equals('test'),
        );
      });

      test('should handle special Italian characters', () {
        expect(
          InputValidators.sanitizeForFilename('Àgenda Mattinò'),
          equals('genda_mattin'),
        );
      });
    });
  });
}