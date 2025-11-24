// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'utente.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UtenteImpl _$$UtenteImplFromJson(Map<String, dynamic> json) => _$UtenteImpl(
  id: (json['id'] as num?)?.toInt(),
  nome: json['nome'] as String,
  idEducatore: (json['idEducatore'] as num?)?.toInt(),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  isDeleted: json['isDeleted'] as bool? ?? false,
);

Map<String, dynamic> _$$UtenteImplToJson(_$UtenteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nome': instance.nome,
      'idEducatore': instance.idEducatore,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'isDeleted': instance.isDeleted,
    };
