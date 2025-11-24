import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_educatore.freezed.dart';
part 'video_educatore.g.dart';

/// Modello per i video salvati dall'educatore
@freezed
class VideoEducatore with _$VideoEducatore {
  const factory VideoEducatore({
    @JsonKey(name: 'id_video', fromJson: _parseIntFromString) int? idVideo,
    @JsonKey(name: 'nome_video') required String nomeVideo,
    @JsonKey(name: 'categoria') required String categoria,
    @JsonKey(name: 'link_youtube') required String linkYoutube,
    @JsonKey(name: 'nome_agenda') required String nomeAgenda,
    @JsonKey(name: 'nome_utente') required String nomeUtente,
    @JsonKey(name: 'data_creazione') String? dataCreazione,
  }) = _VideoEducatore;

  factory VideoEducatore.fromJson(Map<String, dynamic> json) =>
      _$VideoEducatoreFromJson(json);
}

// Funzione helper per convertire string in int
int? _parseIntFromString(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  return null;
}