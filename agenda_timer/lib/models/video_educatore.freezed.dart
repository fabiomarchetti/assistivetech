// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video_educatore.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VideoEducatore _$VideoEducatoreFromJson(Map<String, dynamic> json) {
  return _VideoEducatore.fromJson(json);
}

/// @nodoc
mixin _$VideoEducatore {
  @JsonKey(name: 'id_video', fromJson: _parseIntFromString)
  int? get idVideo => throw _privateConstructorUsedError;
  @JsonKey(name: 'nome_video')
  String get nomeVideo => throw _privateConstructorUsedError;
  @JsonKey(name: 'categoria')
  String get categoria => throw _privateConstructorUsedError;
  @JsonKey(name: 'link_youtube')
  String get linkYoutube => throw _privateConstructorUsedError;
  @JsonKey(name: 'nome_agenda')
  String get nomeAgenda => throw _privateConstructorUsedError;
  @JsonKey(name: 'nome_utente')
  String get nomeUtente => throw _privateConstructorUsedError;
  @JsonKey(name: 'data_creazione')
  String? get dataCreazione => throw _privateConstructorUsedError;

  /// Serializes this VideoEducatore to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VideoEducatore
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VideoEducatoreCopyWith<VideoEducatore> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VideoEducatoreCopyWith<$Res> {
  factory $VideoEducatoreCopyWith(
    VideoEducatore value,
    $Res Function(VideoEducatore) then,
  ) = _$VideoEducatoreCopyWithImpl<$Res, VideoEducatore>;
  @useResult
  $Res call({
    @JsonKey(name: 'id_video', fromJson: _parseIntFromString) int? idVideo,
    @JsonKey(name: 'nome_video') String nomeVideo,
    @JsonKey(name: 'categoria') String categoria,
    @JsonKey(name: 'link_youtube') String linkYoutube,
    @JsonKey(name: 'nome_agenda') String nomeAgenda,
    @JsonKey(name: 'nome_utente') String nomeUtente,
    @JsonKey(name: 'data_creazione') String? dataCreazione,
  });
}

/// @nodoc
class _$VideoEducatoreCopyWithImpl<$Res, $Val extends VideoEducatore>
    implements $VideoEducatoreCopyWith<$Res> {
  _$VideoEducatoreCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VideoEducatore
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? idVideo = freezed,
    Object? nomeVideo = null,
    Object? categoria = null,
    Object? linkYoutube = null,
    Object? nomeAgenda = null,
    Object? nomeUtente = null,
    Object? dataCreazione = freezed,
  }) {
    return _then(
      _value.copyWith(
            idVideo: freezed == idVideo
                ? _value.idVideo
                : idVideo // ignore: cast_nullable_to_non_nullable
                      as int?,
            nomeVideo: null == nomeVideo
                ? _value.nomeVideo
                : nomeVideo // ignore: cast_nullable_to_non_nullable
                      as String,
            categoria: null == categoria
                ? _value.categoria
                : categoria // ignore: cast_nullable_to_non_nullable
                      as String,
            linkYoutube: null == linkYoutube
                ? _value.linkYoutube
                : linkYoutube // ignore: cast_nullable_to_non_nullable
                      as String,
            nomeAgenda: null == nomeAgenda
                ? _value.nomeAgenda
                : nomeAgenda // ignore: cast_nullable_to_non_nullable
                      as String,
            nomeUtente: null == nomeUtente
                ? _value.nomeUtente
                : nomeUtente // ignore: cast_nullable_to_non_nullable
                      as String,
            dataCreazione: freezed == dataCreazione
                ? _value.dataCreazione
                : dataCreazione // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VideoEducatoreImplCopyWith<$Res>
    implements $VideoEducatoreCopyWith<$Res> {
  factory _$$VideoEducatoreImplCopyWith(
    _$VideoEducatoreImpl value,
    $Res Function(_$VideoEducatoreImpl) then,
  ) = __$$VideoEducatoreImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id_video', fromJson: _parseIntFromString) int? idVideo,
    @JsonKey(name: 'nome_video') String nomeVideo,
    @JsonKey(name: 'categoria') String categoria,
    @JsonKey(name: 'link_youtube') String linkYoutube,
    @JsonKey(name: 'nome_agenda') String nomeAgenda,
    @JsonKey(name: 'nome_utente') String nomeUtente,
    @JsonKey(name: 'data_creazione') String? dataCreazione,
  });
}

/// @nodoc
class __$$VideoEducatoreImplCopyWithImpl<$Res>
    extends _$VideoEducatoreCopyWithImpl<$Res, _$VideoEducatoreImpl>
    implements _$$VideoEducatoreImplCopyWith<$Res> {
  __$$VideoEducatoreImplCopyWithImpl(
    _$VideoEducatoreImpl _value,
    $Res Function(_$VideoEducatoreImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VideoEducatore
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? idVideo = freezed,
    Object? nomeVideo = null,
    Object? categoria = null,
    Object? linkYoutube = null,
    Object? nomeAgenda = null,
    Object? nomeUtente = null,
    Object? dataCreazione = freezed,
  }) {
    return _then(
      _$VideoEducatoreImpl(
        idVideo: freezed == idVideo
            ? _value.idVideo
            : idVideo // ignore: cast_nullable_to_non_nullable
                  as int?,
        nomeVideo: null == nomeVideo
            ? _value.nomeVideo
            : nomeVideo // ignore: cast_nullable_to_non_nullable
                  as String,
        categoria: null == categoria
            ? _value.categoria
            : categoria // ignore: cast_nullable_to_non_nullable
                  as String,
        linkYoutube: null == linkYoutube
            ? _value.linkYoutube
            : linkYoutube // ignore: cast_nullable_to_non_nullable
                  as String,
        nomeAgenda: null == nomeAgenda
            ? _value.nomeAgenda
            : nomeAgenda // ignore: cast_nullable_to_non_nullable
                  as String,
        nomeUtente: null == nomeUtente
            ? _value.nomeUtente
            : nomeUtente // ignore: cast_nullable_to_non_nullable
                  as String,
        dataCreazione: freezed == dataCreazione
            ? _value.dataCreazione
            : dataCreazione // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VideoEducatoreImpl implements _VideoEducatore {
  const _$VideoEducatoreImpl({
    @JsonKey(name: 'id_video', fromJson: _parseIntFromString) this.idVideo,
    @JsonKey(name: 'nome_video') required this.nomeVideo,
    @JsonKey(name: 'categoria') required this.categoria,
    @JsonKey(name: 'link_youtube') required this.linkYoutube,
    @JsonKey(name: 'nome_agenda') required this.nomeAgenda,
    @JsonKey(name: 'nome_utente') required this.nomeUtente,
    @JsonKey(name: 'data_creazione') this.dataCreazione,
  });

  factory _$VideoEducatoreImpl.fromJson(Map<String, dynamic> json) =>
      _$$VideoEducatoreImplFromJson(json);

  @override
  @JsonKey(name: 'id_video', fromJson: _parseIntFromString)
  final int? idVideo;
  @override
  @JsonKey(name: 'nome_video')
  final String nomeVideo;
  @override
  @JsonKey(name: 'categoria')
  final String categoria;
  @override
  @JsonKey(name: 'link_youtube')
  final String linkYoutube;
  @override
  @JsonKey(name: 'nome_agenda')
  final String nomeAgenda;
  @override
  @JsonKey(name: 'nome_utente')
  final String nomeUtente;
  @override
  @JsonKey(name: 'data_creazione')
  final String? dataCreazione;

  @override
  String toString() {
    return 'VideoEducatore(idVideo: $idVideo, nomeVideo: $nomeVideo, categoria: $categoria, linkYoutube: $linkYoutube, nomeAgenda: $nomeAgenda, nomeUtente: $nomeUtente, dataCreazione: $dataCreazione)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VideoEducatoreImpl &&
            (identical(other.idVideo, idVideo) || other.idVideo == idVideo) &&
            (identical(other.nomeVideo, nomeVideo) ||
                other.nomeVideo == nomeVideo) &&
            (identical(other.categoria, categoria) ||
                other.categoria == categoria) &&
            (identical(other.linkYoutube, linkYoutube) ||
                other.linkYoutube == linkYoutube) &&
            (identical(other.nomeAgenda, nomeAgenda) ||
                other.nomeAgenda == nomeAgenda) &&
            (identical(other.nomeUtente, nomeUtente) ||
                other.nomeUtente == nomeUtente) &&
            (identical(other.dataCreazione, dataCreazione) ||
                other.dataCreazione == dataCreazione));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    idVideo,
    nomeVideo,
    categoria,
    linkYoutube,
    nomeAgenda,
    nomeUtente,
    dataCreazione,
  );

  /// Create a copy of VideoEducatore
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VideoEducatoreImplCopyWith<_$VideoEducatoreImpl> get copyWith =>
      __$$VideoEducatoreImplCopyWithImpl<_$VideoEducatoreImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$VideoEducatoreImplToJson(this);
  }
}

abstract class _VideoEducatore implements VideoEducatore {
  const factory _VideoEducatore({
    @JsonKey(name: 'id_video', fromJson: _parseIntFromString)
    final int? idVideo,
    @JsonKey(name: 'nome_video') required final String nomeVideo,
    @JsonKey(name: 'categoria') required final String categoria,
    @JsonKey(name: 'link_youtube') required final String linkYoutube,
    @JsonKey(name: 'nome_agenda') required final String nomeAgenda,
    @JsonKey(name: 'nome_utente') required final String nomeUtente,
    @JsonKey(name: 'data_creazione') final String? dataCreazione,
  }) = _$VideoEducatoreImpl;

  factory _VideoEducatore.fromJson(Map<String, dynamic> json) =
      _$VideoEducatoreImpl.fromJson;

  @override
  @JsonKey(name: 'id_video', fromJson: _parseIntFromString)
  int? get idVideo;
  @override
  @JsonKey(name: 'nome_video')
  String get nomeVideo;
  @override
  @JsonKey(name: 'categoria')
  String get categoria;
  @override
  @JsonKey(name: 'link_youtube')
  String get linkYoutube;
  @override
  @JsonKey(name: 'nome_agenda')
  String get nomeAgenda;
  @override
  @JsonKey(name: 'nome_utente')
  String get nomeUtente;
  @override
  @JsonKey(name: 'data_creazione')
  String? get dataCreazione;

  /// Create a copy of VideoEducatore
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VideoEducatoreImplCopyWith<_$VideoEducatoreImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
