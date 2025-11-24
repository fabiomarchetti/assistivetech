// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agenda.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AgendaImpl _$$AgendaImplFromJson(Map<String, dynamic> json) => _$AgendaImpl(
  id: (json['id'] as num?)?.toInt(),
  nome: json['nome'] as String,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  isDeleted: json['isDeleted'] as bool? ?? false,
);

Map<String, dynamic> _$$AgendaImplToJson(_$AgendaImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nome': instance.nome,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'isDeleted': instance.isDeleted,
    };
