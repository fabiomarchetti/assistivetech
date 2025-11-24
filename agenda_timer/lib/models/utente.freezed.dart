// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'utente.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Utente _$UtenteFromJson(Map<String, dynamic> json) {
  return _Utente.fromJson(json);
}

/// @nodoc
mixin _$Utente {
  int? get id => throw _privateConstructorUsedError;
  String get nome => throw _privateConstructorUsedError;
  int? get idEducatore =>
      throw _privateConstructorUsedError; // Collegamento all'educatore responsabile
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  bool get isDeleted => throw _privateConstructorUsedError;

  /// Serializes this Utente to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Utente
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UtenteCopyWith<Utente> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UtenteCopyWith<$Res> {
  factory $UtenteCopyWith(Utente value, $Res Function(Utente) then) =
      _$UtenteCopyWithImpl<$Res, Utente>;
  @useResult
  $Res call({
    int? id,
    String nome,
    int? idEducatore,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool isDeleted,
  });
}

/// @nodoc
class _$UtenteCopyWithImpl<$Res, $Val extends Utente>
    implements $UtenteCopyWith<$Res> {
  _$UtenteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Utente
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? nome = null,
    Object? idEducatore = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? isDeleted = null,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int?,
            nome: null == nome
                ? _value.nome
                : nome // ignore: cast_nullable_to_non_nullable
                      as String,
            idEducatore: freezed == idEducatore
                ? _value.idEducatore
                : idEducatore // ignore: cast_nullable_to_non_nullable
                      as int?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            isDeleted: null == isDeleted
                ? _value.isDeleted
                : isDeleted // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UtenteImplCopyWith<$Res> implements $UtenteCopyWith<$Res> {
  factory _$$UtenteImplCopyWith(
    _$UtenteImpl value,
    $Res Function(_$UtenteImpl) then,
  ) = __$$UtenteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? id,
    String nome,
    int? idEducatore,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool isDeleted,
  });
}

/// @nodoc
class __$$UtenteImplCopyWithImpl<$Res>
    extends _$UtenteCopyWithImpl<$Res, _$UtenteImpl>
    implements _$$UtenteImplCopyWith<$Res> {
  __$$UtenteImplCopyWithImpl(
    _$UtenteImpl _value,
    $Res Function(_$UtenteImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Utente
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? nome = null,
    Object? idEducatore = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? isDeleted = null,
  }) {
    return _then(
      _$UtenteImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        nome: null == nome
            ? _value.nome
            : nome // ignore: cast_nullable_to_non_nullable
                  as String,
        idEducatore: freezed == idEducatore
            ? _value.idEducatore
            : idEducatore // ignore: cast_nullable_to_non_nullable
                  as int?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        isDeleted: null == isDeleted
            ? _value.isDeleted
            : isDeleted // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UtenteImpl implements _Utente {
  const _$UtenteImpl({
    this.id,
    required this.nome,
    this.idEducatore,
    this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
  });

  factory _$UtenteImpl.fromJson(Map<String, dynamic> json) =>
      _$$UtenteImplFromJson(json);

  @override
  final int? id;
  @override
  final String nome;
  @override
  final int? idEducatore;
  // Collegamento all'educatore responsabile
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  @JsonKey()
  final bool isDeleted;

  @override
  String toString() {
    return 'Utente(id: $id, nome: $nome, idEducatore: $idEducatore, createdAt: $createdAt, updatedAt: $updatedAt, isDeleted: $isDeleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UtenteImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nome, nome) || other.nome == nome) &&
            (identical(other.idEducatore, idEducatore) ||
                other.idEducatore == idEducatore) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    nome,
    idEducatore,
    createdAt,
    updatedAt,
    isDeleted,
  );

  /// Create a copy of Utente
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UtenteImplCopyWith<_$UtenteImpl> get copyWith =>
      __$$UtenteImplCopyWithImpl<_$UtenteImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UtenteImplToJson(this);
  }
}

abstract class _Utente implements Utente {
  const factory _Utente({
    final int? id,
    required final String nome,
    final int? idEducatore,
    final DateTime? createdAt,
    final DateTime? updatedAt,
    final bool isDeleted,
  }) = _$UtenteImpl;

  factory _Utente.fromJson(Map<String, dynamic> json) = _$UtenteImpl.fromJson;

  @override
  int? get id;
  @override
  String get nome;
  @override
  int? get idEducatore; // Collegamento all'educatore responsabile
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  bool get isDeleted;

  /// Create a copy of Utente
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UtenteImplCopyWith<_$UtenteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
