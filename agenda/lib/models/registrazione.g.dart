// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registrazione.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RegistrazioneImpl _$$RegistrazioneImplFromJson(Map<String, dynamic> json) =>
    _$RegistrazioneImpl(
      idRegistrazione: (json['id_registrazione'] as num?)?.toInt(),
      nomeRegistrazione: json['nome_registrazione'] as String,
      cognomeRegistrazione: json['cognome_registrazione'] as String,
      usernameRegistrazione: json['username_registrazione'] as String,
      passwordRegistrazione: json['password_registrazione'] as String,
      ruoloRegistrazione: $enumDecode(
        _$RuoloUtenteEnumMap,
        json['ruolo_registrazione'],
      ),
      dataRegistrazione: json['data_registrazione'] == null
          ? null
          : DateTime.parse(json['data_registrazione'] as String),
    );

Map<String, dynamic> _$$RegistrazioneImplToJson(_$RegistrazioneImpl instance) =>
    <String, dynamic>{
      'id_registrazione': instance.idRegistrazione,
      'nome_registrazione': instance.nomeRegistrazione,
      'cognome_registrazione': instance.cognomeRegistrazione,
      'username_registrazione': instance.usernameRegistrazione,
      'password_registrazione': instance.passwordRegistrazione,
      'ruolo_registrazione': _$RuoloUtenteEnumMap[instance.ruoloRegistrazione]!,
      'data_registrazione': instance.dataRegistrazione?.toIso8601String(),
    };

const _$RuoloUtenteEnumMap = {
  RuoloUtente.amministratore: 'amministratore',
  RuoloUtente.educatore: 'educatore',
  RuoloUtente.paziente: 'paziente',
};
