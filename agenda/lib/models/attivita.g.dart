// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attivita.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AttivitaImpl _$$AttivitaImplFromJson(Map<String, dynamic> json) =>
    _$AttivitaImpl(
      id: (json['id'] as num?)?.toInt(),
      nomeUtente: json['nomeUtente'] as String,
      nomePittogramma: json['nomePittogramma'] as String,
      nomeAgenda: json['nomeAgenda'] as String,
      posizione: (json['posizione'] as num).toInt(),
      tipo: $enumDecode(_$TipoAttivitaEnumMap, json['tipo']),
      filePath: json['filePath'] as String,
      fraseVocale: json['fraseVocale'] as String? ?? '',
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      isDeleted: json['isDeleted'] as bool? ?? false,
    );

Map<String, dynamic> _$$AttivitaImplToJson(_$AttivitaImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nomeUtente': instance.nomeUtente,
      'nomePittogramma': instance.nomePittogramma,
      'nomeAgenda': instance.nomeAgenda,
      'posizione': instance.posizione,
      'tipo': _$TipoAttivitaEnumMap[instance.tipo]!,
      'filePath': instance.filePath,
      'fraseVocale': instance.fraseVocale,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'isDeleted': instance.isDeleted,
    };

const _$TipoAttivitaEnumMap = {
  TipoAttivita.pittogramma: 'pittogramma',
  TipoAttivita.foto: 'foto',
};
