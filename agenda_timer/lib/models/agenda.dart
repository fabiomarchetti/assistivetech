import 'package:freezed_annotation/freezed_annotation.dart';

part 'agenda.freezed.dart';
part 'agenda.g.dart';

// Modello Agenda: rappresenta una specifica agenda (es. casa, scuola)
@freezed
class Agenda with _$Agenda {
  const factory Agenda({
    // Identificatore interno
    int? id,
    // Nome univoco dell'agenda scelto dall'educatore
    required String nome,
    // Campi di audit
    DateTime? createdAt,
    DateTime? updatedAt,
    // Soft delete
    @Default(false) bool isDeleted,
  }) = _Agenda;

  factory Agenda.fromJson(Map<String, dynamic> json) => _$AgendaFromJson(json);
}
