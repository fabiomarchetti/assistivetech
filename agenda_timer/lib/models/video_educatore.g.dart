// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_educatore.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VideoEducatoreImpl _$$VideoEducatoreImplFromJson(Map<String, dynamic> json) =>
    _$VideoEducatoreImpl(
      idVideo: _parseIntFromString(json['id_video']),
      nomeVideo: json['nome_video'] as String,
      categoria: json['categoria'] as String,
      linkYoutube: json['link_youtube'] as String,
      nomeAgenda: json['nome_agenda'] as String,
      nomeUtente: json['nome_utente'] as String,
      dataCreazione: json['data_creazione'] as String?,
    );

Map<String, dynamic> _$$VideoEducatoreImplToJson(
  _$VideoEducatoreImpl instance,
) => <String, dynamic>{
  'id_video': instance.idVideo,
  'nome_video': instance.nomeVideo,
  'categoria': instance.categoria,
  'link_youtube': instance.linkYoutube,
  'nome_agenda': instance.nomeAgenda,
  'nome_utente': instance.nomeUtente,
  'data_creazione': instance.dataCreazione,
};
