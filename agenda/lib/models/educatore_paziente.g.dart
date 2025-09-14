// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'educatore_paziente.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EducatorePazienteImpl _$$EducatorePazienteImplFromJson(
  Map<String, dynamic> json,
) => _$EducatorePazienteImpl(
  idAssociazione: (json['id_associazione'] as num?)?.toInt(),
  idEducatore: (json['id_educatore'] as num).toInt(),
  idPaziente: (json['id_paziente'] as num).toInt(),
  dataAssociazione: json['data_associazione'] == null
      ? null
      : DateTime.parse(json['data_associazione'] as String),
  isAttiva: json['is_attiva'] as bool? ?? false,
);

Map<String, dynamic> _$$EducatorePazienteImplToJson(
  _$EducatorePazienteImpl instance,
) => <String, dynamic>{
  'id_associazione': instance.idAssociazione,
  'id_educatore': instance.idEducatore,
  'id_paziente': instance.idPaziente,
  'data_associazione': instance.dataAssociazione?.toIso8601String(),
  'is_attiva': instance.isAttiva,
};
