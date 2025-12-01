// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_report_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DailyReportEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String date, String prcode, String prgcode) load,
    required TResult Function() loadReports,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String date, String prcode, String prgcode)? load,
    TResult? Function()? loadReports,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String date, String prcode, String prgcode)? load,
    TResult Function()? loadReports,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Load value) load,
    required TResult Function(_LoadReports value) loadReports,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Load value)? load,
    TResult? Function(_LoadReports value)? loadReports,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Load value)? load,
    TResult Function(_LoadReports value)? loadReports,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyReportEventCopyWith<$Res> {
  factory $DailyReportEventCopyWith(
    DailyReportEvent value,
    $Res Function(DailyReportEvent) then,
  ) = _$DailyReportEventCopyWithImpl<$Res, DailyReportEvent>;
}

/// @nodoc
class _$DailyReportEventCopyWithImpl<$Res, $Val extends DailyReportEvent>
    implements $DailyReportEventCopyWith<$Res> {
  _$DailyReportEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyReportEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$LoadImplCopyWith<$Res> {
  factory _$$LoadImplCopyWith(
    _$LoadImpl value,
    $Res Function(_$LoadImpl) then,
  ) = __$$LoadImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String date, String prcode, String prgcode});
}

/// @nodoc
class __$$LoadImplCopyWithImpl<$Res>
    extends _$DailyReportEventCopyWithImpl<$Res, _$LoadImpl>
    implements _$$LoadImplCopyWith<$Res> {
  __$$LoadImplCopyWithImpl(_$LoadImpl _value, $Res Function(_$LoadImpl) _then)
    : super(_value, _then);

  /// Create a copy of DailyReportEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? prcode = null,
    Object? prgcode = null,
  }) {
    return _then(
      _$LoadImpl(
        date:
            null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                    as String,
        prcode:
            null == prcode
                ? _value.prcode
                : prcode // ignore: cast_nullable_to_non_nullable
                    as String,
        prgcode:
            null == prgcode
                ? _value.prgcode
                : prgcode // ignore: cast_nullable_to_non_nullable
                    as String,
      ),
    );
  }
}

/// @nodoc

class _$LoadImpl implements _Load {
  const _$LoadImpl({
    required this.date,
    required this.prcode,
    required this.prgcode,
  });

  @override
  final String date;
  @override
  final String prcode;
  @override
  final String prgcode;

  @override
  String toString() {
    return 'DailyReportEvent.load(date: $date, prcode: $prcode, prgcode: $prgcode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.prcode, prcode) || other.prcode == prcode) &&
            (identical(other.prgcode, prgcode) || other.prgcode == prgcode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, date, prcode, prgcode);

  /// Create a copy of DailyReportEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoadImplCopyWith<_$LoadImpl> get copyWith =>
      __$$LoadImplCopyWithImpl<_$LoadImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String date, String prcode, String prgcode) load,
    required TResult Function() loadReports,
  }) {
    return load(date, prcode, prgcode);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String date, String prcode, String prgcode)? load,
    TResult? Function()? loadReports,
  }) {
    return load?.call(date, prcode, prgcode);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String date, String prcode, String prgcode)? load,
    TResult Function()? loadReports,
    required TResult orElse(),
  }) {
    if (load != null) {
      return load(date, prcode, prgcode);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Load value) load,
    required TResult Function(_LoadReports value) loadReports,
  }) {
    return load(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Load value)? load,
    TResult? Function(_LoadReports value)? loadReports,
  }) {
    return load?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Load value)? load,
    TResult Function(_LoadReports value)? loadReports,
    required TResult orElse(),
  }) {
    if (load != null) {
      return load(this);
    }
    return orElse();
  }
}

abstract class _Load implements DailyReportEvent {
  const factory _Load({
    required final String date,
    required final String prcode,
    required final String prgcode,
  }) = _$LoadImpl;

  String get date;
  String get prcode;
  String get prgcode;

  /// Create a copy of DailyReportEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoadImplCopyWith<_$LoadImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$LoadReportsImplCopyWith<$Res> {
  factory _$$LoadReportsImplCopyWith(
    _$LoadReportsImpl value,
    $Res Function(_$LoadReportsImpl) then,
  ) = __$$LoadReportsImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadReportsImplCopyWithImpl<$Res>
    extends _$DailyReportEventCopyWithImpl<$Res, _$LoadReportsImpl>
    implements _$$LoadReportsImplCopyWith<$Res> {
  __$$LoadReportsImplCopyWithImpl(
    _$LoadReportsImpl _value,
    $Res Function(_$LoadReportsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DailyReportEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadReportsImpl implements _LoadReports {
  const _$LoadReportsImpl();

  @override
  String toString() {
    return 'DailyReportEvent.loadReports()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadReportsImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String date, String prcode, String prgcode) load,
    required TResult Function() loadReports,
  }) {
    return loadReports();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String date, String prcode, String prgcode)? load,
    TResult? Function()? loadReports,
  }) {
    return loadReports?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String date, String prcode, String prgcode)? load,
    TResult Function()? loadReports,
    required TResult orElse(),
  }) {
    if (loadReports != null) {
      return loadReports();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Load value) load,
    required TResult Function(_LoadReports value) loadReports,
  }) {
    return loadReports(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Load value)? load,
    TResult? Function(_LoadReports value)? loadReports,
  }) {
    return loadReports?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Load value)? load,
    TResult Function(_LoadReports value)? loadReports,
    required TResult orElse(),
  }) {
    if (loadReports != null) {
      return loadReports(this);
    }
    return orElse();
  }
}

abstract class _LoadReports implements DailyReportEvent {
  const factory _LoadReports() = _$LoadReportsImpl;
}
