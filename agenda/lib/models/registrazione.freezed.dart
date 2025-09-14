// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'registrazione.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Registrazione _$RegistrazioneFromJson(Map<String, dynamic> json) {
  return _Registrazione.fromJson(json);
}

/// @nodoc
mixin _$Registrazione {
  @JsonKey(name: 'id_registrazione')
  int? get idRegistrazione => throw _privateConstructorUsedError;
  @JsonKey(name: 'nome_registrazione')
  String get nomeRegistrazione => throw _privateConstructorUsedError;
  @JsonKey(name: 'cognome_registrazione')
  String get cognomeRegistrazione => throw _privateConstructorUsedError;
  @JsonKey(name: 'username_registrazione')
  String get usernameRegistrazione => throw _privateConstructorUsedError;
  @JsonKey(name: 'password_registrazione')
  String get passwordRegistrazione => throw _privateConstructorUsedError;
  @JsonKey(name: 'ruolo_registrazione')
  RuoloUtente get ruoloRegistrazione => throw _privateConstructorUsedError;
  @JsonKey(name: 'data_registrazione')
  DateTime? get dataRegistrazione => throw _privateConstructorUsedError;

  /// Serializes this Registrazione to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Registrazione
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RegistrazioneCopyWith<Registrazione> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RegistrazioneCopyWith<$Res> {
  factory $RegistrazioneCopyWith(
    Registrazione value,
    $Res Function(Registrazione) then,
  ) = _$RegistrazioneCopyWithImpl<$Res, Registrazione>;
  @useResult
  $Res call({
    @JsonKey(name: 'id_registrazione') int? idRegistrazione,
    @JsonKey(name: 'nome_registrazione') String nomeRegistrazione,
    @JsonKey(name: 'cognome_registrazione') String cognomeRegistrazione,
    @JsonKey(name: 'username_registrazione') String usernameRegistrazione,
    @JsonKey(name: 'password_registrazione') String passwordRegistrazione,
    @JsonKey(name: 'ruolo_registrazione') RuoloUtente ruoloRegistrazione,
    @JsonKey(name: 'data_registrazione') DateTime? dataRegistrazione,
  });
}

/// @nodoc
class _$RegistrazioneCopyWithImpl<$Res, $Val extends Registrazione>
    implements $RegistrazioneCopyWith<$Res> {
  _$RegistrazioneCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Registrazione
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? idRegistrazione = freezed,
    Object? nomeRegistrazione = null,
    Object? cognomeRegistrazione = null,
    Object? usernameRegistrazione = null,
    Object? passwordRegistrazione = null,
    Object? ruoloRegistrazione = null,
    Object? dataRegistrazione = freezed,
  }) {
    return _then(
      _value.copyWith(
            idRegistrazione: freezed == idRegistrazione
                ? _value.idRegistrazione
                : idRegistrazione // ignore: cast_nullable_to_non_nullable
                      as int?,
            nomeRegistrazione: null == nomeRegistrazione
                ? _value.nomeRegistrazione
                : nomeRegistrazione // ignore: cast_nullable_to_non_nullable
                      as String,
            cognomeRegistrazione: null == cognomeRegistrazione
                ? _value.cognomeRegistrazione
                : cognomeRegistrazione // ignore: cast_nullable_to_non_nullable
                      as String,
            usernameRegistrazione: null == usernameRegistrazione
                ? _value.usernameRegistrazione
                : usernameRegistrazione // ignore: cast_nullable_to_non_nullable
                      as String,
            passwordRegistrazione: null == passwordRegistrazione
                ? _value.passwordRegistrazione
                : passwordRegistrazione // ignore: cast_nullable_to_non_nullable
                      as String,
            ruoloRegistrazione: null == ruoloRegistrazione
                ? _value.ruoloRegistrazione
                : ruoloRegistrazione // ignore: cast_nullable_to_non_nullable
                      as RuoloUtente,
            dataRegistrazione: freezed == dataRegistrazione
                ? _value.dataRegistrazione
                : dataRegistrazione // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RegistrazioneImplCopyWith<$Res>
    implements $RegistrazioneCopyWith<$Res> {
  factory _$$RegistrazioneImplCopyWith(
    _$RegistrazioneImpl value,
    $Res Function(_$RegistrazioneImpl) then,
  ) = __$$RegistrazioneImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id_registrazione') int? idRegistrazione,
    @JsonKey(name: 'nome_registrazione') String nomeRegistrazione,
    @JsonKey(name: 'cognome_registrazione') String cognomeRegistrazione,
    @JsonKey(name: 'username_registrazione') String usernameRegistrazione,
    @JsonKey(name: 'password_registrazione') String passwordRegistrazione,
    @JsonKey(name: 'ruolo_registrazione') RuoloUtente ruoloRegistrazione,
    @JsonKey(name: 'data_registrazione') DateTime? dataRegistrazione,
  });
}

/// @nodoc
class __$$RegistrazioneImplCopyWithImpl<$Res>
    extends _$RegistrazioneCopyWithImpl<$Res, _$RegistrazioneImpl>
    implements _$$RegistrazioneImplCopyWith<$Res> {
  __$$RegistrazioneImplCopyWithImpl(
    _$RegistrazioneImpl _value,
    $Res Function(_$RegistrazioneImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Registrazione
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? idRegistrazione = freezed,
    Object? nomeRegistrazione = null,
    Object? cognomeRegistrazione = null,
    Object? usernameRegistrazione = null,
    Object? passwordRegistrazione = null,
    Object? ruoloRegistrazione = null,
    Object? dataRegistrazione = freezed,
  }) {
    return _then(
      _$RegistrazioneImpl(
        idRegistrazione: freezed == idRegistrazione
            ? _value.idRegistrazione
            : idRegistrazione // ignore: cast_nullable_to_non_nullable
                  as int?,
        nomeRegistrazione: null == nomeRegistrazione
            ? _value.nomeRegistrazione
            : nomeRegistrazione // ignore: cast_nullable_to_non_nullable
                  as String,
        cognomeRegistrazione: null == cognomeRegistrazione
            ? _value.cognomeRegistrazione
            : cognomeRegistrazione // ignore: cast_nullable_to_non_nullable
                  as String,
        usernameRegistrazione: null == usernameRegistrazione
            ? _value.usernameRegistrazione
            : usernameRegistrazione // ignore: cast_nullable_to_non_nullable
                  as String,
        passwordRegistrazione: null == passwordRegistrazione
            ? _value.passwordRegistrazione
            : passwordRegistrazione // ignore: cast_nullable_to_non_nullable
                  as String,
        ruoloRegistrazione: null == ruoloRegistrazione
            ? _value.ruoloRegistrazione
            : ruoloRegistrazione // ignore: cast_nullable_to_non_nullable
                  as RuoloUtente,
        dataRegistrazione: freezed == dataRegistrazione
            ? _value.dataRegistrazione
            : dataRegistrazione // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RegistrazioneImpl implements _Registrazione {
  const _$RegistrazioneImpl({
    @JsonKey(name: 'id_registrazione') this.idRegistrazione,
    @JsonKey(name: 'nome_registrazione') required this.nomeRegistrazione,
    @JsonKey(name: 'cognome_registrazione') required this.cognomeRegistrazione,
    @JsonKey(name: 'username_registrazione')
    required this.usernameRegistrazione,
    @JsonKey(name: 'password_registrazione')
    required this.passwordRegistrazione,
    @JsonKey(name: 'ruolo_registrazione') required this.ruoloRegistrazione,
    @JsonKey(name: 'data_registrazione') this.dataRegistrazione,
  });

  factory _$RegistrazioneImpl.fromJson(Map<String, dynamic> json) =>
      _$$RegistrazioneImplFromJson(json);

  @override
  @JsonKey(name: 'id_registrazione')
  final int? idRegistrazione;
  @override
  @JsonKey(name: 'nome_registrazione')
  final String nomeRegistrazione;
  @override
  @JsonKey(name: 'cognome_registrazione')
  final String cognomeRegistrazione;
  @override
  @JsonKey(name: 'username_registrazione')
  final String usernameRegistrazione;
  @override
  @JsonKey(name: 'password_registrazione')
  final String passwordRegistrazione;
  @override
  @JsonKey(name: 'ruolo_registrazione')
  final RuoloUtente ruoloRegistrazione;
  @override
  @JsonKey(name: 'data_registrazione')
  final DateTime? dataRegistrazione;

  @override
  String toString() {
    return 'Registrazione(idRegistrazione: $idRegistrazione, nomeRegistrazione: $nomeRegistrazione, cognomeRegistrazione: $cognomeRegistrazione, usernameRegistrazione: $usernameRegistrazione, passwordRegistrazione: $passwordRegistrazione, ruoloRegistrazione: $ruoloRegistrazione, dataRegistrazione: $dataRegistrazione)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegistrazioneImpl &&
            (identical(other.idRegistrazione, idRegistrazione) ||
                other.idRegistrazione == idRegistrazione) &&
            (identical(other.nomeRegistrazione, nomeRegistrazione) ||
                other.nomeRegistrazione == nomeRegistrazione) &&
            (identical(other.cognomeRegistrazione, cognomeRegistrazione) ||
                other.cognomeRegistrazione == cognomeRegistrazione) &&
            (identical(other.usernameRegistrazione, usernameRegistrazione) ||
                other.usernameRegistrazione == usernameRegistrazione) &&
            (identical(other.passwordRegistrazione, passwordRegistrazione) ||
                other.passwordRegistrazione == passwordRegistrazione) &&
            (identical(other.ruoloRegistrazione, ruoloRegistrazione) ||
                other.ruoloRegistrazione == ruoloRegistrazione) &&
            (identical(other.dataRegistrazione, dataRegistrazione) ||
                other.dataRegistrazione == dataRegistrazione));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    idRegistrazione,
    nomeRegistrazione,
    cognomeRegistrazione,
    usernameRegistrazione,
    passwordRegistrazione,
    ruoloRegistrazione,
    dataRegistrazione,
  );

  /// Create a copy of Registrazione
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RegistrazioneImplCopyWith<_$RegistrazioneImpl> get copyWith =>
      __$$RegistrazioneImplCopyWithImpl<_$RegistrazioneImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RegistrazioneImplToJson(this);
  }
}

abstract class _Registrazione implements Registrazione {
  const factory _Registrazione({
    @JsonKey(name: 'id_registrazione') final int? idRegistrazione,
    @JsonKey(name: 'nome_registrazione')
    required final String nomeRegistrazione,
    @JsonKey(name: 'cognome_registrazione')
    required final String cognomeRegistrazione,
    @JsonKey(name: 'username_registrazione')
    required final String usernameRegistrazione,
    @JsonKey(name: 'password_registrazione')
    required final String passwordRegistrazione,
    @JsonKey(name: 'ruolo_registrazione')
    required final RuoloUtente ruoloRegistrazione,
    @JsonKey(name: 'data_registrazione') final DateTime? dataRegistrazione,
  }) = _$RegistrazioneImpl;

  factory _Registrazione.fromJson(Map<String, dynamic> json) =
      _$RegistrazioneImpl.fromJson;

  @override
  @JsonKey(name: 'id_registrazione')
  int? get idRegistrazione;
  @override
  @JsonKey(name: 'nome_registrazione')
  String get nomeRegistrazione;
  @override
  @JsonKey(name: 'cognome_registrazione')
  String get cognomeRegistrazione;
  @override
  @JsonKey(name: 'username_registrazione')
  String get usernameRegistrazione;
  @override
  @JsonKey(name: 'password_registrazione')
  String get passwordRegistrazione;
  @override
  @JsonKey(name: 'ruolo_registrazione')
  RuoloUtente get ruoloRegistrazione;
  @override
  @JsonKey(name: 'data_registrazione')
  DateTime? get dataRegistrazione;

  /// Create a copy of Registrazione
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RegistrazioneImplCopyWith<_$RegistrazioneImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
