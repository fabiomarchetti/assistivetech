import 'package:flutter_test/flutter_test.dart';
import 'package:agenda_pwa/models/attivita.dart';

void main() {
  group('Attivita', () {
    test('should create instance with required fields', () {
      final attivita = Attivita(
        nomeUtente: 'educatore',
        nomePittogramma: 'casa',
        nomeAgenda: 'Mattino',
        posizione: 1,
        tipo: TipoAttivita.pittogramma,
        filePath: '/path/to/file.png',
      );

      expect(attivita.nomeUtente, equals('educatore'));
      expect(attivita.nomePittogramma, equals('casa'));
      expect(attivita.nomeAgenda, equals('Mattino'));
      expect(attivita.posizione, equals(1));
      expect(attivita.tipo, equals(TipoAttivita.pittogramma));
      expect(attivita.filePath, equals('/path/to/file.png'));
      expect(attivita.isDeleted, equals(false)); // valore di default
    });

    test('should create instance with all fields', () {
      final createdAt = DateTime.now();
      final updatedAt = DateTime.now();
      
      final attivita = Attivita(
        id: 1,
        nomeUtente: 'educatore',
        nomePittogramma: 'scuola',
        nomeAgenda: 'Pomeriggio',
        posizione: 2,
        tipo: TipoAttivita.foto,
        filePath: '/path/to/photo.jpg',
        createdAt: createdAt,
        updatedAt: updatedAt,
        isDeleted: true,
      );

      expect(attivita.id, equals(1));
      expect(attivita.tipo, equals(TipoAttivita.foto));
      expect(attivita.createdAt, equals(createdAt));
      expect(attivita.updatedAt, equals(updatedAt));
      expect(attivita.isDeleted, equals(true));
    });

    test('should support JSON serialization', () {
      final attivita = Attivita(
        id: 1,
        nomeUtente: 'educatore',
        nomePittogramma: 'casa',
        nomeAgenda: 'Test',
        posizione: 1,
        tipo: TipoAttivita.pittogramma,
        filePath: '/test/path.png',
        createdAt: DateTime(2023, 1, 1, 12, 0, 0),
        updatedAt: DateTime(2023, 1, 1, 12, 0, 0),
      );

      // Serialize to JSON
      final json = attivita.toJson();
      
      expect(json['id'], equals(1));
      expect(json['nomeUtente'], equals('educatore'));
      expect(json['nomePittogramma'], equals('casa'));
      expect(json['nomeAgenda'], equals('Test'));
      expect(json['posizione'], equals(1));
      expect(json['tipo'], equals('pittogramma'));
      expect(json['filePath'], equals('/test/path.png'));

      // Deserialize from JSON
      final fromJson = Attivita.fromJson(json);
      expect(fromJson.id, equals(attivita.id));
      expect(fromJson.nomeUtente, equals(attivita.nomeUtente));
      expect(fromJson.nomePittogramma, equals(attivita.nomePittogramma));
      expect(fromJson.tipo, equals(attivita.tipo));
    });

    test('should handle copyWith properly', () {
      final original = Attivita(
        id: 1,
        nomeUtente: 'educatore',
        nomePittogramma: 'casa',
        nomeAgenda: 'Test',
        posizione: 1,
        tipo: TipoAttivita.pittogramma,
        filePath: '/test/path.png',
      );

      final modified = original.copyWith(
        nomePittogramma: 'scuola',
        posizione: 2,
      );

      expect(modified.id, equals(original.id)); // unchanged
      expect(modified.nomeUtente, equals(original.nomeUtente)); // unchanged
      expect(modified.nomePittogramma, equals('scuola')); // changed
      expect(modified.posizione, equals(2)); // changed
      expect(modified.tipo, equals(original.tipo)); // unchanged
    });

    group('TipoAttivita enum', () {
      test('should have correct values', () {
        expect(TipoAttivita.values.length, equals(2));
        expect(TipoAttivita.values, contains(TipoAttivita.pittogramma));
        expect(TipoAttivita.values, contains(TipoAttivita.foto));
      });

      test('should serialize correctly in JSON', () {
        final pittogrammaActivity = Attivita(
          nomeUtente: 'educatore',
          nomePittogramma: 'casa',
          nomeAgenda: 'Test',
          posizione: 1,
          tipo: TipoAttivita.pittogramma,
          filePath: '/test/path.png',
        );

        final fotoActivity = Attivita(
          nomeUtente: 'educatore',
          nomePittogramma: 'foto',
          nomeAgenda: 'Test',
          posizione: 1,
          tipo: TipoAttivita.foto,
          filePath: '/test/photo.jpg',
        );

        expect(pittogrammaActivity.toJson()['tipo'], equals('pittogramma'));
        expect(fotoActivity.toJson()['tipo'], equals('foto'));
      });
    });
  });
}