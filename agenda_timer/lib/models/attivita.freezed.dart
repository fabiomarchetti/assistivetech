// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attivita.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Attivita _$AttivitaFromJson(Map<String, dynamic> json) {
  return _Attivita.fromJson(json);
}

/// @nodoc
mixin _$Attivita {
  int? get id =>
      throw _privateConstructorUsedError; // Richiesti dalla specifica
  String get nomeUtente => throw _privateConstructorUsedError;
  String get nomePittogramma => throw _privateConstructorUsedError;
  String get nomeAgenda => throw _privateConstructorUsedError;
  int get posizione => throw _privateConstructorUsedError; // Dati di rendering
  TipoAttivita get tipo => throw _privateConstructorUsedError;
  String get filePath =>
      throw _privateConstructorUsedError; // Frase per sintesi vocale
  String get fraseVocale => throw _privateConstructorUsedError; // Audit
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  bool get isDeleted => throw _privateConstructorUsedError;

  /// Serializes this Attivita to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Attivita
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AttivitaCopyWith<Attivita> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AttivitaCopyWith<$Res> {
  factory $AttivitaCopyWith(Attivita value, $Res Function(Attivita) then) =
      _$AttivitaCopyWithImpl<$Res, Attivita>;
  @useResult
  $Res call({
    int? id,
    String nomeUtente,
    String nomePittogramma,
    String nomeAgenda,
    int posizione,
    TipoAttivita tipo,
    String filePath,
    String fraseVocale,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool isDeleted,
  });
}

/// @nodoc
class _$AttivitaCopyWithImpl<$Res, $Val extends Attivita>
    implements $AttivitaCopyWith<$Res> {
  _$AttivitaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Attivita
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? nomeUtente = null,
    Object? nomePittogramma = null,
    Object? nomeAgenda = null,
    Object? posizione = null,
    Object? tipo = null,
    Object? filePath = null,
    Object? fraseVocale = null,
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
            nomeUtente: null == nomeUtente
                ? _value.nomeUtente
                : nomeUtente // ignore: cast_nullable_to_non_nullable
                      as String,
            nomePittogramma: null == nomePittogramma
                ? _value.nomePittogramma
                : nomePittogramma // ignore: cast_nullable_to_non_nullable
                      as String,
            nomeAgenda: null == nomeAgenda
                ? _value.nomeAgenda
                : nomeAgenda // ignore: cast_nullable_to_non_nullable
                      as String,
            posizione: null == posizione
                ? _value.posizione
                : posizione // ignore: cast_nullable_to_non_nullable
                      as int,
            tipo: null == tipo
                ? _value.tipo
                : tipo // ignore: cast_nullable_to_non_nullable
                      as TipoAttivita,
            filePath: null == filePath
                ? _value.filePath
                : filePath // ignore: cast_nullable_to_non_nullable
                      as String,
            fraseVocale: null == fraseVocale
                ? _value.fraseVocale
                : fraseVocale // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$AttivitaImplCopyWith<$Res>
    implements $AttivitaCopyWith<$Res> {
  factory _$$AttivitaImplCopyWith(
    _$AttivitaImpl value,
    $Res Function(_$AttivitaImpl) then,
  ) = __$$AttivitaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? id,
    String nomeUtente,
    String nomePittogramma,
    String nomeAgenda,
    int posizione,
    TipoAttivita tipo,
    String filePath,
    String fraseVocale,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool isDeleted,
  });
}

/// @nodoc
class __$$AttivitaImplCopyWithImpl<$Res>
    extends _$AttivitaCopyWithImpl<$Res, _$AttivitaImpl>
    implements _$$AttivitaImplCopyWith<$Res> {
  __$$AttivitaImplCopyWithImpl(
    _$AttivitaImpl _value,
    $Res Function(_$AttivitaImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Attivita
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? nomeUtente = null,
    Object? nomePittogramma = null,
    Object? nomeAgenda = null,
    Object? posizione = null,
    Object? tipo = null,
    Object? filePath = null,
    Object? fraseVocale = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? isDeleted = null,
  }) {
    return _then(
      _$AttivitaImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        nomeUtente: null == nomeUtente
            ? _value.nomeUtente
            : nomeUtente // ignore: cast_nullable_to_non_nullable
                  as String,
        nomePittogramma: null == nomePittogramma
            ? _value.nomePittogramma
            : nomePittogramma // ignore: cast_nullable_to_non_nullable
                  as String,
        nomeAgenda: null == nomeAgenda
            ? _value.nomeAgenda
            : nomeAgenda // ignore: cast_nullable_to_non_nullable
                  as String,
        posizione: null == posizione
            ? _value.posizione
            : posizione // ignore: cast_nullable_to_non_nullable
                  as int,
        tipo: null == tipo
            ? _value.tipo
            : tipo // ignore: cast_nullable_to_non_nullable
                  as TipoAttivita,
        filePath: null == filePath
            ? _value.filePath
            : filePath // ignore: cast_nullable_to_non_nullable
                  as String,
        fraseVocale: null == fraseVocale
            ? _value.fraseVocale
            : fraseVocale // ignore: cast_nullable_to_non_nullable
                  as String,
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
class _$AttivitaImpl implements _Attivita {
  const _$AttivitaImpl({
    this.id,
    required this.nomeUtente,
    required this.nomePittogramma,
    required this.nomeAgenda,
    required this.posizione,
    required this.tipo,
    required this.filePath,
    this.fraseVocale = '',
    this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
  });

  factory _$AttivitaImpl.fromJson(Map<String, dynamic> json) =>
      _$$AttivitaImplFromJson(json);

  @override
  final int? id;
  // Richiesti dalla specifica
  @override
  final String nomeUtente;
  @override
  final String nomePittogramma;
  @override
  final String nomeAgenda;
  @override
  final int posizione;
  // Dati di rendering
  @override
  final TipoAttivita tipo;
  @override
  final String filePath;
  // Frase per sintesi vocale
  @override
  @JsonKey()
  final String fraseVocale;
  // Audit
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  @JsonKey()
  final bool isDeleted;

  @override
  String toString() {
    return 'Attivita(id: $id, nomeUtente: $nomeUtente, nomePittogramma: $nomePittogramma, nomeAgenda: $nomeAgenda, posizione: $posizione, tipo: $tipo, filePath: $filePath, fraseVocale: $fraseVocale, createdAt: $createdAt, updatedAt: $updatedAt, isDeleted: $isDeleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AttivitaImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nomeUtente, nomeUtente) ||
                other.nomeUtente == nomeUtente) &&
            (identical(other.nomePittogramma, nomePittogramma) ||
                other.nomePittogramma == nomePittogramma) &&
            (identical(other.nomeAgenda, nomeAgenda) ||
                other.nomeAgenda == nomeAgenda) &&
            (identical(other.posizione, posizione) ||
                other.posizione == posizione) &&
            (identical(other.tipo, tipo) || other.tipo == tipo) &&
            (identical(other.filePath, filePath) ||
                other.filePath == filePath) &&
            (identical(other.fraseVocale, fraseVocale) ||
                other.fraseVocale == fraseVocale) &&
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
    nomeUtente,
    nomePittogramma,
    nomeAgenda,
    posizione,
    tipo,
    filePath,
    fraseVocale,
    createdAt,
    updatedAt,
    isDeleted,
  );

  /// Create a copy of Attivita
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AttivitaImplCopyWith<_$AttivitaImpl> get copyWith =>
      __$$AttivitaImplCopyWithImpl<_$AttivitaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AttivitaImplToJson(this);
  }
}

abstract class _Attivita implements Attivita {
  const factory _Attivita({
    final int? id,
    required final String nomeUtente,
    required final String nomePittogramma,
    required final String nomeAgenda,
    required final int posizione,
    required final TipoAttivita tipo,
    required final String filePath,
    final String fraseVocale,
    final DateTime? createdAt,
    final DateTime? updatedAt,
    final bool isDeleted,
  }) = _$AttivitaImpl;

  factory _Attivita.fromJson(Map<String, dynamic> json) =
      _$AttivitaImpl.fromJson;

  @override
  int? get id; // Richiesti dalla specifica
  @override
  String get nomeUtente;
  @override
  String get nomePittogramma;
  @override
  String get nomeAgenda;
  @override
  int get posizione; // Dati di rendering
  @override
  TipoAttivita get tipo;
  @override
  String get filePath; // Frase per sintesi vocale
  @override
  String get fraseVocale; // Audit
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  bool get isDeleted;

  /// Create a copy of Attivita
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AttivitaImplCopyWith<_$AttivitaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
