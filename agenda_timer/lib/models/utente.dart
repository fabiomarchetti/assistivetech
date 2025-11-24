import 'package:freezed_annotation/freezed_annotation.dart';

part 'utente.freezed.dart';
part 'utente.g.dart';

/// Modello Utente: rappresenta un paziente dell'applicazione
@freezed
class Utente with _$Utente {
  const factory Utente({
    int? id,
    required String nome,
    int? idEducatore, // Collegamento all'educatore responsabile
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default(false) bool isDeleted,
  }) = _Utente;

  factory Utente.fromJson(Map<String, dynamic> json) =>
      _$UtenteFromJson(json);
}