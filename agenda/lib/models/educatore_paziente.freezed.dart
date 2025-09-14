// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'educatore_paziente.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

EducatorePaziente _$EducatorePazienteFromJson(Map<String, dynamic> json) {
  return _EducatorePaziente.fromJson(json);
}

/// @nodoc
mixin _$EducatorePaziente {
  @JsonKey(name: 'id_associazione')
  int? get idAssociazione => throw _privateConstructorUsedError;
  @JsonKey(name: 'id_educatore')
  int get idEducatore => throw _privateConstructorUsedError;
  @JsonKey(name: 'id_paziente')
  int get idPaziente => throw _privateConstructorUsedError;
  @JsonKey(name: 'data_associazione')
  DateTime? get dataAssociazione => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_attiva')
  bool get isAttiva => throw _privateConstructorUsedError;

  /// Serializes this EducatorePaziente to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EducatorePaziente
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EducatorePazienteCopyWith<EducatorePaziente> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EducatorePazienteCopyWith<$Res> {
  factory $EducatorePazienteCopyWith(
    EducatorePaziente value,
    $Res Function(EducatorePaziente) then,
  ) = _$EducatorePazienteCopyWithImpl<$Res, EducatorePaziente>;
  @useResult
  $Res call({
    @JsonKey(name: 'id_associazione') int? idAssociazione,
    @JsonKey(name: 'id_educatore') int idEducatore,
    @JsonKey(name: 'id_paziente') int idPaziente,
    @JsonKey(name: 'data_associazione') DateTime? dataAssociazione,
    @JsonKey(name: 'is_attiva') bool isAttiva,
  });
}

/// @nodoc
class _$EducatorePazienteCopyWithImpl<$Res, $Val extends EducatorePaziente>
    implements $EducatorePazienteCopyWith<$Res> {
  _$EducatorePazienteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EducatorePaziente
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? idAssociazione = freezed,
    Object? idEducatore = null,
    Object? idPaziente = null,
    Object? dataAssociazione = freezed,
    Object? isAttiva = null,
  }) {
    return _then(
      _value.copyWith(
            idAssociazione: freezed == idAssociazione
                ? _value.idAssociazione
                : idAssociazione // ignore: cast_nullable_to_non_nullable
                      as int?,
            idEducatore: null == idEducatore
                ? _value.idEducatore
                : idEducatore // ignore: cast_nullable_to_non_nullable
                      as int,
            idPaziente: null == idPaziente
                ? _value.idPaziente
                : idPaziente // ignore: cast_nullable_to_non_nullable
                      as int,
            dataAssociazione: freezed == dataAssociazione
                ? _value.dataAssociazione
                : dataAssociazione // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            isAttiva: null == isAttiva
                ? _value.isAttiva
                : isAttiva // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EducatorePazienteImplCopyWith<$Res>
    implements $EducatorePazienteCopyWith<$Res> {
  factory _$$EducatorePazienteImplCopyWith(
    _$EducatorePazienteImpl value,
    $Res Function(_$EducatorePazienteImpl) then,
  ) = __$$EducatorePazienteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id_associazione') int? idAssociazione,
    @JsonKey(name: 'id_educatore') int idEducatore,
    @JsonKey(name: 'id_paziente') int idPaziente,
    @JsonKey(name: 'data_associazione') DateTime? dataAssociazione,
    @JsonKey(name: 'is_attiva') bool isAttiva,
  });
}

/// @nodoc
class __$$EducatorePazienteImplCopyWithImpl<$Res>
    extends _$EducatorePazienteCopyWithImpl<$Res, _$EducatorePazienteImpl>
    implements _$$EducatorePazienteImplCopyWith<$Res> {
  __$$EducatorePazienteImplCopyWithImpl(
    _$EducatorePazienteImpl _value,
    $Res Function(_$EducatorePazienteImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EducatorePaziente
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? idAssociazione = freezed,
    Object? idEducatore = null,
    Object? idPaziente = null,
    Object? dataAssociazione = freezed,
    Object? isAttiva = null,
  }) {
    return _then(
      _$EducatorePazienteImpl(
        idAssociazione: freezed == idAssociazione
            ? _value.idAssociazione
            : idAssociazione // ignore: cast_nullable_to_non_nullable
                  as int?,
        idEducatore: null == idEducatore
            ? _value.idEducatore
            : idEducatore // ignore: cast_nullable_to_non_nullable
                  as int,
        idPaziente: null == idPaziente
            ? _value.idPaziente
            : idPaziente // ignore: cast_nullable_to_non_nullable
                  as int,
        dataAssociazione: freezed == dataAssociazione
            ? _value.dataAssociazione
            : dataAssociazione // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        isAttiva: null == isAttiva
            ? _value.isAttiva
            : isAttiva // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EducatorePazienteImpl implements _EducatorePaziente {
  const _$EducatorePazienteImpl({
    @JsonKey(name: 'id_associazione') this.idAssociazione,
    @JsonKey(name: 'id_educatore') required this.idEducatore,
    @JsonKey(name: 'id_paziente') required this.idPaziente,
    @JsonKey(name: 'data_associazione') this.dataAssociazione,
    @JsonKey(name: 'is_attiva') this.isAttiva = false,
  });

  factory _$EducatorePazienteImpl.fromJson(Map<String, dynamic> json) =>
      _$$EducatorePazienteImplFromJson(json);

  @override
  @JsonKey(name: 'id_associazione')
  final int? idAssociazione;
  @override
  @JsonKey(name: 'id_educatore')
  final int idEducatore;
  @override
  @JsonKey(name: 'id_paziente')
  final int idPaziente;
  @override
  @JsonKey(name: 'data_associazione')
  final DateTime? dataAssociazione;
  @override
  @JsonKey(name: 'is_attiva')
  final bool isAttiva;

  @override
  String toString() {
    return 'EducatorePaziente(idAssociazione: $idAssociazione, idEducatore: $idEducatore, idPaziente: $idPaziente, dataAssociazione: $dataAssociazione, isAttiva: $isAttiva)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EducatorePazienteImpl &&
            (identical(other.idAssociazione, idAssociazione) ||
                other.idAssociazione == idAssociazione) &&
            (identical(other.idEducatore, idEducatore) ||
                other.idEducatore == idEducatore) &&
            (identical(other.idPaziente, idPaziente) ||
                other.idPaziente == idPaziente) &&
            (identical(other.dataAssociazione, dataAssociazione) ||
                other.dataAssociazione == dataAssociazione) &&
            (identical(other.isAttiva, isAttiva) ||
                other.isAttiva == isAttiva));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    idAssociazione,
    idEducatore,
    idPaziente,
    dataAssociazione,
    isAttiva,
  );

  /// Create a copy of EducatorePaziente
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EducatorePazienteImplCopyWith<_$EducatorePazienteImpl> get copyWith =>
      __$$EducatorePazienteImplCopyWithImpl<_$EducatorePazienteImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$EducatorePazienteImplToJson(this);
  }
}

abstract class _EducatorePaziente implements EducatorePaziente {
  const factory _EducatorePaziente({
    @JsonKey(name: 'id_associazione') final int? idAssociazione,
    @JsonKey(name: 'id_educatore') required final int idEducatore,
    @JsonKey(name: 'id_paziente') required final int idPaziente,
    @JsonKey(name: 'data_associazione') final DateTime? dataAssociazione,
    @JsonKey(name: 'is_attiva') final bool isAttiva,
  }) = _$EducatorePazienteImpl;

  factory _EducatorePaziente.fromJson(Map<String, dynamic> json) =
      _$EducatorePazienteImpl.fromJson;

  @override
  @JsonKey(name: 'id_associazione')
  int? get idAssociazione;
  @override
  @JsonKey(name: 'id_educatore')
  int get idEducatore;
  @override
  @JsonKey(name: 'id_paziente')
  int get idPaziente;
  @override
  @JsonKey(name: 'data_associazione')
  DateTime? get dataAssociazione;
  @override
  @JsonKey(name: 'is_attiva')
  bool get isAttiva;

  /// Create a copy of EducatorePaziente
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EducatorePazienteImplCopyWith<_$EducatorePazienteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
