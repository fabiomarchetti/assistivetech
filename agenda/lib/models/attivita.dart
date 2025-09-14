import 'package:freezed_annotation/freezed_annotation.dart';

part 'attivita.freezed.dart';
part 'attivita.g.dart';

// Tipologia dell'attività: pittogramma ARASAAC o foto scattata
enum TipoAttivita { pittogramma, foto }

// Modello Attività: elemento sequenziale di un'agenda
@freezed
class Attivita with _$Attivita {
  const factory Attivita({
    int? id,
    // Richiesti dalla specifica
    required String nomeUtente,
    required String nomePittogramma,
    required String nomeAgenda,
    required int posizione,
    // Dati di rendering
    required TipoAttivita tipo,
    required String filePath,
    // Frase per sintesi vocale
    @Default('') String fraseVocale,
    // Audit
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default(false) bool isDeleted,
  }) = _Attivita;

  factory Attivita.fromJson(Map<String, dynamic> json) =>
      _$AttivitaFromJson(json);
}
