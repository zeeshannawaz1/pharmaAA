// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AuthEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String baseUrl, String userId) loginRequested,
    required TResult Function() loadConfig,
    required TResult Function(
      String userId,
      String prCode,
      String groupCode,
      String pinCode,
      String baseUrl,
      String mobNo,
    )
    saveConfig,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String baseUrl, String userId)? loginRequested,
    TResult? Function()? loadConfig,
    TResult? Function(
      String userId,
      String prCode,
      String groupCode,
      String pinCode,
      String baseUrl,
      String mobNo,
    )?
    saveConfig,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String baseUrl, String userId)? loginRequested,
    TResult Function()? loadConfig,
    TResult Function(
      String userId,
      String prCode,
      String groupCode,
      String pinCode,
      String baseUrl,
      String mobNo,
    )?
    saveConfig,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoginRequested value) loginRequested,
    required TResult Function(LoadConfig value) loadConfig,
    required TResult Function(SaveConfig value) saveConfig,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoginRequested value)? loginRequested,
    TResult? Function(LoadConfig value)? loadConfig,
    TResult? Function(SaveConfig value)? saveConfig,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoginRequested value)? loginRequested,
    TResult Function(LoadConfig value)? loadConfig,
    TResult Function(SaveConfig value)? saveConfig,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthEventCopyWith<$Res> {
  factory $AuthEventCopyWith(AuthEvent value, $Res Function(AuthEvent) then) =
      _$AuthEventCopyWithImpl<$Res, AuthEvent>;
}

/// @nodoc
class _$AuthEventCopyWithImpl<$Res, $Val extends AuthEvent>
    implements $AuthEventCopyWith<$Res> {
  _$AuthEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$LoginRequestedImplCopyWith<$Res> {
  factory _$$LoginRequestedImplCopyWith(
    _$LoginRequestedImpl value,
    $Res Function(_$LoginRequestedImpl) then,
  ) = __$$LoginRequestedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String baseUrl, String userId});
}

/// @nodoc
class __$$LoginRequestedImplCopyWithImpl<$Res>
    extends _$AuthEventCopyWithImpl<$Res, _$LoginRequestedImpl>
    implements _$$LoginRequestedImplCopyWith<$Res> {
  __$$LoginRequestedImplCopyWithImpl(
    _$LoginRequestedImpl _value,
    $Res Function(_$LoginRequestedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? baseUrl = null, Object? userId = null}) {
    return _then(
      _$LoginRequestedImpl(
        baseUrl:
            null == baseUrl
                ? _value.baseUrl
                : baseUrl // ignore: cast_nullable_to_non_nullable
                    as String,
        userId:
            null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                    as String,
      ),
    );
  }
}

/// @nodoc

class _$LoginRequestedImpl implements LoginRequested {
  const _$LoginRequestedImpl({required this.baseUrl, required this.userId});

  @override
  final String baseUrl;
  @override
  final String userId;

  @override
  String toString() {
    return 'AuthEvent.loginRequested(baseUrl: $baseUrl, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginRequestedImpl &&
            (identical(other.baseUrl, baseUrl) || other.baseUrl == baseUrl) &&
            (identical(other.userId, userId) || other.userId == userId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, baseUrl, userId);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginRequestedImplCopyWith<_$LoginRequestedImpl> get copyWith =>
      __$$LoginRequestedImplCopyWithImpl<_$LoginRequestedImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String baseUrl, String userId) loginRequested,
    required TResult Function() loadConfig,
    required TResult Function(
      String userId,
      String prCode,
      String groupCode,
      String pinCode,
      String baseUrl,
      String mobNo,
    )
    saveConfig,
  }) {
    return loginRequested(baseUrl, userId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String baseUrl, String userId)? loginRequested,
    TResult? Function()? loadConfig,
    TResult? Function(
      String userId,
      String prCode,
      String groupCode,
      String pinCode,
      String baseUrl,
      String mobNo,
    )?
    saveConfig,
  }) {
    return loginRequested?.call(baseUrl, userId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String baseUrl, String userId)? loginRequested,
    TResult Function()? loadConfig,
    TResult Function(
      String userId,
      String prCode,
      String groupCode,
      String pinCode,
      String baseUrl,
      String mobNo,
    )?
    saveConfig,
    required TResult orElse(),
  }) {
    if (loginRequested != null) {
      return loginRequested(baseUrl, userId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoginRequested value) loginRequested,
    required TResult Function(LoadConfig value) loadConfig,
    required TResult Function(SaveConfig value) saveConfig,
  }) {
    return loginRequested(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoginRequested value)? loginRequested,
    TResult? Function(LoadConfig value)? loadConfig,
    TResult? Function(SaveConfig value)? saveConfig,
  }) {
    return loginRequested?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoginRequested value)? loginRequested,
    TResult Function(LoadConfig value)? loadConfig,
    TResult Function(SaveConfig value)? saveConfig,
    required TResult orElse(),
  }) {
    if (loginRequested != null) {
      return loginRequested(this);
    }
    return orElse();
  }
}

abstract class LoginRequested implements AuthEvent {
  const factory LoginRequested({
    required final String baseUrl,
    required final String userId,
  }) = _$LoginRequestedImpl;

  String get baseUrl;
  String get userId;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoginRequestedImplCopyWith<_$LoginRequestedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$LoadConfigImplCopyWith<$Res> {
  factory _$$LoadConfigImplCopyWith(
    _$LoadConfigImpl value,
    $Res Function(_$LoadConfigImpl) then,
  ) = __$$LoadConfigImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadConfigImplCopyWithImpl<$Res>
    extends _$AuthEventCopyWithImpl<$Res, _$LoadConfigImpl>
    implements _$$LoadConfigImplCopyWith<$Res> {
  __$$LoadConfigImplCopyWithImpl(
    _$LoadConfigImpl _value,
    $Res Function(_$LoadConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadConfigImpl implements LoadConfig {
  const _$LoadConfigImpl();

  @override
  String toString() {
    return 'AuthEvent.loadConfig()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadConfigImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String baseUrl, String userId) loginRequested,
    required TResult Function() loadConfig,
    required TResult Function(
      String userId,
      String prCode,
      String groupCode,
      String pinCode,
      String baseUrl,
      String mobNo,
    )
    saveConfig,
  }) {
    return loadConfig();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String baseUrl, String userId)? loginRequested,
    TResult? Function()? loadConfig,
    TResult? Function(
      String userId,
      String prCode,
      String groupCode,
      String pinCode,
      String baseUrl,
      String mobNo,
    )?
    saveConfig,
  }) {
    return loadConfig?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String baseUrl, String userId)? loginRequested,
    TResult Function()? loadConfig,
    TResult Function(
      String userId,
      String prCode,
      String groupCode,
      String pinCode,
      String baseUrl,
      String mobNo,
    )?
    saveConfig,
    required TResult orElse(),
  }) {
    if (loadConfig != null) {
      return loadConfig();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoginRequested value) loginRequested,
    required TResult Function(LoadConfig value) loadConfig,
    required TResult Function(SaveConfig value) saveConfig,
  }) {
    return loadConfig(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoginRequested value)? loginRequested,
    TResult? Function(LoadConfig value)? loadConfig,
    TResult? Function(SaveConfig value)? saveConfig,
  }) {
    return loadConfig?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoginRequested value)? loginRequested,
    TResult Function(LoadConfig value)? loadConfig,
    TResult Function(SaveConfig value)? saveConfig,
    required TResult orElse(),
  }) {
    if (loadConfig != null) {
      return loadConfig(this);
    }
    return orElse();
  }
}

abstract class LoadConfig implements AuthEvent {
  const factory LoadConfig() = _$LoadConfigImpl;
}

/// @nodoc
abstract class _$$SaveConfigImplCopyWith<$Res> {
  factory _$$SaveConfigImplCopyWith(
    _$SaveConfigImpl value,
    $Res Function(_$SaveConfigImpl) then,
  ) = __$$SaveConfigImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    String userId,
    String prCode,
    String groupCode,
    String pinCode,
    String baseUrl,
    String mobNo,
  });
}

/// @nodoc
class __$$SaveConfigImplCopyWithImpl<$Res>
    extends _$AuthEventCopyWithImpl<$Res, _$SaveConfigImpl>
    implements _$$SaveConfigImplCopyWith<$Res> {
  __$$SaveConfigImplCopyWithImpl(
    _$SaveConfigImpl _value,
    $Res Function(_$SaveConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? prCode = null,
    Object? groupCode = null,
    Object? pinCode = null,
    Object? baseUrl = null,
    Object? mobNo = null,
  }) {
    return _then(
      _$SaveConfigImpl(
        userId:
            null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                    as String,
        prCode:
            null == prCode
                ? _value.prCode
                : prCode // ignore: cast_nullable_to_non_nullable
                    as String,
        groupCode:
            null == groupCode
                ? _value.groupCode
                : groupCode // ignore: cast_nullable_to_non_nullable
                    as String,
        pinCode:
            null == pinCode
                ? _value.pinCode
                : pinCode // ignore: cast_nullable_to_non_nullable
                    as String,
        baseUrl:
            null == baseUrl
                ? _value.baseUrl
                : baseUrl // ignore: cast_nullable_to_non_nullable
                    as String,
        mobNo:
            null == mobNo
                ? _value.mobNo
                : mobNo // ignore: cast_nullable_to_non_nullable
                    as String,
      ),
    );
  }
}

/// @nodoc

class _$SaveConfigImpl implements SaveConfig {
  const _$SaveConfigImpl({
    required this.userId,
    required this.prCode,
    required this.groupCode,
    required this.pinCode,
    required this.baseUrl,
    required this.mobNo,
  });

  @override
  final String userId;
  @override
  final String prCode;
  @override
  final String groupCode;
  @override
  final String pinCode;
  @override
  final String baseUrl;
  @override
  final String mobNo;

  @override
  String toString() {
    return 'AuthEvent.saveConfig(userId: $userId, prCode: $prCode, groupCode: $groupCode, pinCode: $pinCode, baseUrl: $baseUrl, mobNo: $mobNo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SaveConfigImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.prCode, prCode) || other.prCode == prCode) &&
            (identical(other.groupCode, groupCode) ||
                other.groupCode == groupCode) &&
            (identical(other.pinCode, pinCode) || other.pinCode == pinCode) &&
            (identical(other.baseUrl, baseUrl) || other.baseUrl == baseUrl) &&
            (identical(other.mobNo, mobNo) || other.mobNo == mobNo));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    prCode,
    groupCode,
    pinCode,
    baseUrl,
    mobNo,
  );

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SaveConfigImplCopyWith<_$SaveConfigImpl> get copyWith =>
      __$$SaveConfigImplCopyWithImpl<_$SaveConfigImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String baseUrl, String userId) loginRequested,
    required TResult Function() loadConfig,
    required TResult Function(
      String userId,
      String prCode,
      String groupCode,
      String pinCode,
      String baseUrl,
      String mobNo,
    )
    saveConfig,
  }) {
    return saveConfig(userId, prCode, groupCode, pinCode, baseUrl, mobNo);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String baseUrl, String userId)? loginRequested,
    TResult? Function()? loadConfig,
    TResult? Function(
      String userId,
      String prCode,
      String groupCode,
      String pinCode,
      String baseUrl,
      String mobNo,
    )?
    saveConfig,
  }) {
    return saveConfig?.call(userId, prCode, groupCode, pinCode, baseUrl, mobNo);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String baseUrl, String userId)? loginRequested,
    TResult Function()? loadConfig,
    TResult Function(
      String userId,
      String prCode,
      String groupCode,
      String pinCode,
      String baseUrl,
      String mobNo,
    )?
    saveConfig,
    required TResult orElse(),
  }) {
    if (saveConfig != null) {
      return saveConfig(userId, prCode, groupCode, pinCode, baseUrl, mobNo);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoginRequested value) loginRequested,
    required TResult Function(LoadConfig value) loadConfig,
    required TResult Function(SaveConfig value) saveConfig,
  }) {
    return saveConfig(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoginRequested value)? loginRequested,
    TResult? Function(LoadConfig value)? loadConfig,
    TResult? Function(SaveConfig value)? saveConfig,
  }) {
    return saveConfig?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoginRequested value)? loginRequested,
    TResult Function(LoadConfig value)? loadConfig,
    TResult Function(SaveConfig value)? saveConfig,
    required TResult orElse(),
  }) {
    if (saveConfig != null) {
      return saveConfig(this);
    }
    return orElse();
  }
}

abstract class SaveConfig implements AuthEvent {
  const factory SaveConfig({
    required final String userId,
    required final String prCode,
    required final String groupCode,
    required final String pinCode,
    required final String baseUrl,
    required final String mobNo,
  }) = _$SaveConfigImpl;

  String get userId;
  String get prCode;
  String get groupCode;
  String get pinCode;
  String get baseUrl;
  String get mobNo;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SaveConfigImplCopyWith<_$SaveConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
