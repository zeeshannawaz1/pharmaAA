// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_draft_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$OrderDraftEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadDrafts,
    required TResult Function(OrderDraft draft) saveDraft,
    required TResult Function(String draftId) deleteDraft,
    required TResult Function() clearDrafts,
    required TResult Function(OrderDraft draft) confirmDraftForProcessing,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadDrafts,
    TResult? Function(OrderDraft draft)? saveDraft,
    TResult? Function(String draftId)? deleteDraft,
    TResult? Function()? clearDrafts,
    TResult? Function(OrderDraft draft)? confirmDraftForProcessing,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadDrafts,
    TResult Function(OrderDraft draft)? saveDraft,
    TResult Function(String draftId)? deleteDraft,
    TResult Function()? clearDrafts,
    TResult Function(OrderDraft draft)? confirmDraftForProcessing,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoadDrafts value) loadDrafts,
    required TResult Function(_SaveDraft value) saveDraft,
    required TResult Function(_DeleteDraft value) deleteDraft,
    required TResult Function(_ClearDrafts value) clearDrafts,
    required TResult Function(_ConfirmDraftForProcessing value)
    confirmDraftForProcessing,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoadDrafts value)? loadDrafts,
    TResult? Function(_SaveDraft value)? saveDraft,
    TResult? Function(_DeleteDraft value)? deleteDraft,
    TResult? Function(_ClearDrafts value)? clearDrafts,
    TResult? Function(_ConfirmDraftForProcessing value)?
    confirmDraftForProcessing,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoadDrafts value)? loadDrafts,
    TResult Function(_SaveDraft value)? saveDraft,
    TResult Function(_DeleteDraft value)? deleteDraft,
    TResult Function(_ClearDrafts value)? clearDrafts,
    TResult Function(_ConfirmDraftForProcessing value)?
    confirmDraftForProcessing,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderDraftEventCopyWith<$Res> {
  factory $OrderDraftEventCopyWith(
    OrderDraftEvent value,
    $Res Function(OrderDraftEvent) then,
  ) = _$OrderDraftEventCopyWithImpl<$Res, OrderDraftEvent>;
}

/// @nodoc
class _$OrderDraftEventCopyWithImpl<$Res, $Val extends OrderDraftEvent>
    implements $OrderDraftEventCopyWith<$Res> {
  _$OrderDraftEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderDraftEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$LoadDraftsImplCopyWith<$Res> {
  factory _$$LoadDraftsImplCopyWith(
    _$LoadDraftsImpl value,
    $Res Function(_$LoadDraftsImpl) then,
  ) = __$$LoadDraftsImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadDraftsImplCopyWithImpl<$Res>
    extends _$OrderDraftEventCopyWithImpl<$Res, _$LoadDraftsImpl>
    implements _$$LoadDraftsImplCopyWith<$Res> {
  __$$LoadDraftsImplCopyWithImpl(
    _$LoadDraftsImpl _value,
    $Res Function(_$LoadDraftsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrderDraftEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadDraftsImpl implements _LoadDrafts {
  const _$LoadDraftsImpl();

  @override
  String toString() {
    return 'OrderDraftEvent.loadDrafts()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadDraftsImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadDrafts,
    required TResult Function(OrderDraft draft) saveDraft,
    required TResult Function(String draftId) deleteDraft,
    required TResult Function() clearDrafts,
    required TResult Function(OrderDraft draft) confirmDraftForProcessing,
  }) {
    return loadDrafts();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadDrafts,
    TResult? Function(OrderDraft draft)? saveDraft,
    TResult? Function(String draftId)? deleteDraft,
    TResult? Function()? clearDrafts,
    TResult? Function(OrderDraft draft)? confirmDraftForProcessing,
  }) {
    return loadDrafts?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadDrafts,
    TResult Function(OrderDraft draft)? saveDraft,
    TResult Function(String draftId)? deleteDraft,
    TResult Function()? clearDrafts,
    TResult Function(OrderDraft draft)? confirmDraftForProcessing,
    required TResult orElse(),
  }) {
    if (loadDrafts != null) {
      return loadDrafts();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoadDrafts value) loadDrafts,
    required TResult Function(_SaveDraft value) saveDraft,
    required TResult Function(_DeleteDraft value) deleteDraft,
    required TResult Function(_ClearDrafts value) clearDrafts,
    required TResult Function(_ConfirmDraftForProcessing value)
    confirmDraftForProcessing,
  }) {
    return loadDrafts(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoadDrafts value)? loadDrafts,
    TResult? Function(_SaveDraft value)? saveDraft,
    TResult? Function(_DeleteDraft value)? deleteDraft,
    TResult? Function(_ClearDrafts value)? clearDrafts,
    TResult? Function(_ConfirmDraftForProcessing value)?
    confirmDraftForProcessing,
  }) {
    return loadDrafts?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoadDrafts value)? loadDrafts,
    TResult Function(_SaveDraft value)? saveDraft,
    TResult Function(_DeleteDraft value)? deleteDraft,
    TResult Function(_ClearDrafts value)? clearDrafts,
    TResult Function(_ConfirmDraftForProcessing value)?
    confirmDraftForProcessing,
    required TResult orElse(),
  }) {
    if (loadDrafts != null) {
      return loadDrafts(this);
    }
    return orElse();
  }
}

abstract class _LoadDrafts implements OrderDraftEvent {
  const factory _LoadDrafts() = _$LoadDraftsImpl;
}

/// @nodoc
abstract class _$$SaveDraftImplCopyWith<$Res> {
  factory _$$SaveDraftImplCopyWith(
    _$SaveDraftImpl value,
    $Res Function(_$SaveDraftImpl) then,
  ) = __$$SaveDraftImplCopyWithImpl<$Res>;
  @useResult
  $Res call({OrderDraft draft});
}

/// @nodoc
class __$$SaveDraftImplCopyWithImpl<$Res>
    extends _$OrderDraftEventCopyWithImpl<$Res, _$SaveDraftImpl>
    implements _$$SaveDraftImplCopyWith<$Res> {
  __$$SaveDraftImplCopyWithImpl(
    _$SaveDraftImpl _value,
    $Res Function(_$SaveDraftImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrderDraftEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? draft = null}) {
    return _then(
      _$SaveDraftImpl(
        null == draft
            ? _value.draft
            : draft // ignore: cast_nullable_to_non_nullable
                as OrderDraft,
      ),
    );
  }
}

/// @nodoc

class _$SaveDraftImpl implements _SaveDraft {
  const _$SaveDraftImpl(this.draft);

  @override
  final OrderDraft draft;

  @override
  String toString() {
    return 'OrderDraftEvent.saveDraft(draft: $draft)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SaveDraftImpl &&
            (identical(other.draft, draft) || other.draft == draft));
  }

  @override
  int get hashCode => Object.hash(runtimeType, draft);

  /// Create a copy of OrderDraftEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SaveDraftImplCopyWith<_$SaveDraftImpl> get copyWith =>
      __$$SaveDraftImplCopyWithImpl<_$SaveDraftImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadDrafts,
    required TResult Function(OrderDraft draft) saveDraft,
    required TResult Function(String draftId) deleteDraft,
    required TResult Function() clearDrafts,
    required TResult Function(OrderDraft draft) confirmDraftForProcessing,
  }) {
    return saveDraft(draft);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadDrafts,
    TResult? Function(OrderDraft draft)? saveDraft,
    TResult? Function(String draftId)? deleteDraft,
    TResult? Function()? clearDrafts,
    TResult? Function(OrderDraft draft)? confirmDraftForProcessing,
  }) {
    return saveDraft?.call(draft);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadDrafts,
    TResult Function(OrderDraft draft)? saveDraft,
    TResult Function(String draftId)? deleteDraft,
    TResult Function()? clearDrafts,
    TResult Function(OrderDraft draft)? confirmDraftForProcessing,
    required TResult orElse(),
  }) {
    if (saveDraft != null) {
      return saveDraft(draft);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoadDrafts value) loadDrafts,
    required TResult Function(_SaveDraft value) saveDraft,
    required TResult Function(_DeleteDraft value) deleteDraft,
    required TResult Function(_ClearDrafts value) clearDrafts,
    required TResult Function(_ConfirmDraftForProcessing value)
    confirmDraftForProcessing,
  }) {
    return saveDraft(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoadDrafts value)? loadDrafts,
    TResult? Function(_SaveDraft value)? saveDraft,
    TResult? Function(_DeleteDraft value)? deleteDraft,
    TResult? Function(_ClearDrafts value)? clearDrafts,
    TResult? Function(_ConfirmDraftForProcessing value)?
    confirmDraftForProcessing,
  }) {
    return saveDraft?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoadDrafts value)? loadDrafts,
    TResult Function(_SaveDraft value)? saveDraft,
    TResult Function(_DeleteDraft value)? deleteDraft,
    TResult Function(_ClearDrafts value)? clearDrafts,
    TResult Function(_ConfirmDraftForProcessing value)?
    confirmDraftForProcessing,
    required TResult orElse(),
  }) {
    if (saveDraft != null) {
      return saveDraft(this);
    }
    return orElse();
  }
}

abstract class _SaveDraft implements OrderDraftEvent {
  const factory _SaveDraft(final OrderDraft draft) = _$SaveDraftImpl;

  OrderDraft get draft;

  /// Create a copy of OrderDraftEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SaveDraftImplCopyWith<_$SaveDraftImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DeleteDraftImplCopyWith<$Res> {
  factory _$$DeleteDraftImplCopyWith(
    _$DeleteDraftImpl value,
    $Res Function(_$DeleteDraftImpl) then,
  ) = __$$DeleteDraftImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String draftId});
}

/// @nodoc
class __$$DeleteDraftImplCopyWithImpl<$Res>
    extends _$OrderDraftEventCopyWithImpl<$Res, _$DeleteDraftImpl>
    implements _$$DeleteDraftImplCopyWith<$Res> {
  __$$DeleteDraftImplCopyWithImpl(
    _$DeleteDraftImpl _value,
    $Res Function(_$DeleteDraftImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrderDraftEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? draftId = null}) {
    return _then(
      _$DeleteDraftImpl(
        null == draftId
            ? _value.draftId
            : draftId // ignore: cast_nullable_to_non_nullable
                as String,
      ),
    );
  }
}

/// @nodoc

class _$DeleteDraftImpl implements _DeleteDraft {
  const _$DeleteDraftImpl(this.draftId);

  @override
  final String draftId;

  @override
  String toString() {
    return 'OrderDraftEvent.deleteDraft(draftId: $draftId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeleteDraftImpl &&
            (identical(other.draftId, draftId) || other.draftId == draftId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, draftId);

  /// Create a copy of OrderDraftEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeleteDraftImplCopyWith<_$DeleteDraftImpl> get copyWith =>
      __$$DeleteDraftImplCopyWithImpl<_$DeleteDraftImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadDrafts,
    required TResult Function(OrderDraft draft) saveDraft,
    required TResult Function(String draftId) deleteDraft,
    required TResult Function() clearDrafts,
    required TResult Function(OrderDraft draft) confirmDraftForProcessing,
  }) {
    return deleteDraft(draftId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadDrafts,
    TResult? Function(OrderDraft draft)? saveDraft,
    TResult? Function(String draftId)? deleteDraft,
    TResult? Function()? clearDrafts,
    TResult? Function(OrderDraft draft)? confirmDraftForProcessing,
  }) {
    return deleteDraft?.call(draftId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadDrafts,
    TResult Function(OrderDraft draft)? saveDraft,
    TResult Function(String draftId)? deleteDraft,
    TResult Function()? clearDrafts,
    TResult Function(OrderDraft draft)? confirmDraftForProcessing,
    required TResult orElse(),
  }) {
    if (deleteDraft != null) {
      return deleteDraft(draftId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoadDrafts value) loadDrafts,
    required TResult Function(_SaveDraft value) saveDraft,
    required TResult Function(_DeleteDraft value) deleteDraft,
    required TResult Function(_ClearDrafts value) clearDrafts,
    required TResult Function(_ConfirmDraftForProcessing value)
    confirmDraftForProcessing,
  }) {
    return deleteDraft(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoadDrafts value)? loadDrafts,
    TResult? Function(_SaveDraft value)? saveDraft,
    TResult? Function(_DeleteDraft value)? deleteDraft,
    TResult? Function(_ClearDrafts value)? clearDrafts,
    TResult? Function(_ConfirmDraftForProcessing value)?
    confirmDraftForProcessing,
  }) {
    return deleteDraft?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoadDrafts value)? loadDrafts,
    TResult Function(_SaveDraft value)? saveDraft,
    TResult Function(_DeleteDraft value)? deleteDraft,
    TResult Function(_ClearDrafts value)? clearDrafts,
    TResult Function(_ConfirmDraftForProcessing value)?
    confirmDraftForProcessing,
    required TResult orElse(),
  }) {
    if (deleteDraft != null) {
      return deleteDraft(this);
    }
    return orElse();
  }
}

abstract class _DeleteDraft implements OrderDraftEvent {
  const factory _DeleteDraft(final String draftId) = _$DeleteDraftImpl;

  String get draftId;

  /// Create a copy of OrderDraftEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeleteDraftImplCopyWith<_$DeleteDraftImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ClearDraftsImplCopyWith<$Res> {
  factory _$$ClearDraftsImplCopyWith(
    _$ClearDraftsImpl value,
    $Res Function(_$ClearDraftsImpl) then,
  ) = __$$ClearDraftsImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ClearDraftsImplCopyWithImpl<$Res>
    extends _$OrderDraftEventCopyWithImpl<$Res, _$ClearDraftsImpl>
    implements _$$ClearDraftsImplCopyWith<$Res> {
  __$$ClearDraftsImplCopyWithImpl(
    _$ClearDraftsImpl _value,
    $Res Function(_$ClearDraftsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrderDraftEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$ClearDraftsImpl implements _ClearDrafts {
  const _$ClearDraftsImpl();

  @override
  String toString() {
    return 'OrderDraftEvent.clearDrafts()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$ClearDraftsImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadDrafts,
    required TResult Function(OrderDraft draft) saveDraft,
    required TResult Function(String draftId) deleteDraft,
    required TResult Function() clearDrafts,
    required TResult Function(OrderDraft draft) confirmDraftForProcessing,
  }) {
    return clearDrafts();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadDrafts,
    TResult? Function(OrderDraft draft)? saveDraft,
    TResult? Function(String draftId)? deleteDraft,
    TResult? Function()? clearDrafts,
    TResult? Function(OrderDraft draft)? confirmDraftForProcessing,
  }) {
    return clearDrafts?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadDrafts,
    TResult Function(OrderDraft draft)? saveDraft,
    TResult Function(String draftId)? deleteDraft,
    TResult Function()? clearDrafts,
    TResult Function(OrderDraft draft)? confirmDraftForProcessing,
    required TResult orElse(),
  }) {
    if (clearDrafts != null) {
      return clearDrafts();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoadDrafts value) loadDrafts,
    required TResult Function(_SaveDraft value) saveDraft,
    required TResult Function(_DeleteDraft value) deleteDraft,
    required TResult Function(_ClearDrafts value) clearDrafts,
    required TResult Function(_ConfirmDraftForProcessing value)
    confirmDraftForProcessing,
  }) {
    return clearDrafts(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoadDrafts value)? loadDrafts,
    TResult? Function(_SaveDraft value)? saveDraft,
    TResult? Function(_DeleteDraft value)? deleteDraft,
    TResult? Function(_ClearDrafts value)? clearDrafts,
    TResult? Function(_ConfirmDraftForProcessing value)?
    confirmDraftForProcessing,
  }) {
    return clearDrafts?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoadDrafts value)? loadDrafts,
    TResult Function(_SaveDraft value)? saveDraft,
    TResult Function(_DeleteDraft value)? deleteDraft,
    TResult Function(_ClearDrafts value)? clearDrafts,
    TResult Function(_ConfirmDraftForProcessing value)?
    confirmDraftForProcessing,
    required TResult orElse(),
  }) {
    if (clearDrafts != null) {
      return clearDrafts(this);
    }
    return orElse();
  }
}

abstract class _ClearDrafts implements OrderDraftEvent {
  const factory _ClearDrafts() = _$ClearDraftsImpl;
}

/// @nodoc
abstract class _$$ConfirmDraftForProcessingImplCopyWith<$Res> {
  factory _$$ConfirmDraftForProcessingImplCopyWith(
    _$ConfirmDraftForProcessingImpl value,
    $Res Function(_$ConfirmDraftForProcessingImpl) then,
  ) = __$$ConfirmDraftForProcessingImplCopyWithImpl<$Res>;
  @useResult
  $Res call({OrderDraft draft});
}

/// @nodoc
class __$$ConfirmDraftForProcessingImplCopyWithImpl<$Res>
    extends _$OrderDraftEventCopyWithImpl<$Res, _$ConfirmDraftForProcessingImpl>
    implements _$$ConfirmDraftForProcessingImplCopyWith<$Res> {
  __$$ConfirmDraftForProcessingImplCopyWithImpl(
    _$ConfirmDraftForProcessingImpl _value,
    $Res Function(_$ConfirmDraftForProcessingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrderDraftEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? draft = null}) {
    return _then(
      _$ConfirmDraftForProcessingImpl(
        null == draft
            ? _value.draft
            : draft // ignore: cast_nullable_to_non_nullable
                as OrderDraft,
      ),
    );
  }
}

/// @nodoc

class _$ConfirmDraftForProcessingImpl implements _ConfirmDraftForProcessing {
  const _$ConfirmDraftForProcessingImpl(this.draft);

  @override
  final OrderDraft draft;

  @override
  String toString() {
    return 'OrderDraftEvent.confirmDraftForProcessing(draft: $draft)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConfirmDraftForProcessingImpl &&
            (identical(other.draft, draft) || other.draft == draft));
  }

  @override
  int get hashCode => Object.hash(runtimeType, draft);

  /// Create a copy of OrderDraftEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConfirmDraftForProcessingImplCopyWith<_$ConfirmDraftForProcessingImpl>
  get copyWith => __$$ConfirmDraftForProcessingImplCopyWithImpl<
    _$ConfirmDraftForProcessingImpl
  >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadDrafts,
    required TResult Function(OrderDraft draft) saveDraft,
    required TResult Function(String draftId) deleteDraft,
    required TResult Function() clearDrafts,
    required TResult Function(OrderDraft draft) confirmDraftForProcessing,
  }) {
    return confirmDraftForProcessing(draft);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadDrafts,
    TResult? Function(OrderDraft draft)? saveDraft,
    TResult? Function(String draftId)? deleteDraft,
    TResult? Function()? clearDrafts,
    TResult? Function(OrderDraft draft)? confirmDraftForProcessing,
  }) {
    return confirmDraftForProcessing?.call(draft);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadDrafts,
    TResult Function(OrderDraft draft)? saveDraft,
    TResult Function(String draftId)? deleteDraft,
    TResult Function()? clearDrafts,
    TResult Function(OrderDraft draft)? confirmDraftForProcessing,
    required TResult orElse(),
  }) {
    if (confirmDraftForProcessing != null) {
      return confirmDraftForProcessing(draft);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoadDrafts value) loadDrafts,
    required TResult Function(_SaveDraft value) saveDraft,
    required TResult Function(_DeleteDraft value) deleteDraft,
    required TResult Function(_ClearDrafts value) clearDrafts,
    required TResult Function(_ConfirmDraftForProcessing value)
    confirmDraftForProcessing,
  }) {
    return confirmDraftForProcessing(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoadDrafts value)? loadDrafts,
    TResult? Function(_SaveDraft value)? saveDraft,
    TResult? Function(_DeleteDraft value)? deleteDraft,
    TResult? Function(_ClearDrafts value)? clearDrafts,
    TResult? Function(_ConfirmDraftForProcessing value)?
    confirmDraftForProcessing,
  }) {
    return confirmDraftForProcessing?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoadDrafts value)? loadDrafts,
    TResult Function(_SaveDraft value)? saveDraft,
    TResult Function(_DeleteDraft value)? deleteDraft,
    TResult Function(_ClearDrafts value)? clearDrafts,
    TResult Function(_ConfirmDraftForProcessing value)?
    confirmDraftForProcessing,
    required TResult orElse(),
  }) {
    if (confirmDraftForProcessing != null) {
      return confirmDraftForProcessing(this);
    }
    return orElse();
  }
}

abstract class _ConfirmDraftForProcessing implements OrderDraftEvent {
  const factory _ConfirmDraftForProcessing(final OrderDraft draft) =
      _$ConfirmDraftForProcessingImpl;

  OrderDraft get draft;

  /// Create a copy of OrderDraftEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConfirmDraftForProcessingImplCopyWith<_$ConfirmDraftForProcessingImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$OrderDraftState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<OrderDraft> drafts) loaded,
    required TResult Function(String message) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<OrderDraft> drafts)? loaded,
    TResult? Function(String message)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<OrderDraft> drafts)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderDraftStateCopyWith<$Res> {
  factory $OrderDraftStateCopyWith(
    OrderDraftState value,
    $Res Function(OrderDraftState) then,
  ) = _$OrderDraftStateCopyWithImpl<$Res, OrderDraftState>;
}

/// @nodoc
class _$OrderDraftStateCopyWithImpl<$Res, $Val extends OrderDraftState>
    implements $OrderDraftStateCopyWith<$Res> {
  _$OrderDraftStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderDraftState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$InitialImplCopyWith<$Res> {
  factory _$$InitialImplCopyWith(
    _$InitialImpl value,
    $Res Function(_$InitialImpl) then,
  ) = __$$InitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$InitialImplCopyWithImpl<$Res>
    extends _$OrderDraftStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
    _$InitialImpl _value,
    $Res Function(_$InitialImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrderDraftState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl();

  @override
  String toString() {
    return 'OrderDraftState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$InitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<OrderDraft> drafts) loaded,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<OrderDraft> drafts)? loaded,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<OrderDraft> drafts)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements OrderDraftState {
  const factory _Initial() = _$InitialImpl;
}

/// @nodoc
abstract class _$$LoadingImplCopyWith<$Res> {
  factory _$$LoadingImplCopyWith(
    _$LoadingImpl value,
    $Res Function(_$LoadingImpl) then,
  ) = __$$LoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadingImplCopyWithImpl<$Res>
    extends _$OrderDraftStateCopyWithImpl<$Res, _$LoadingImpl>
    implements _$$LoadingImplCopyWith<$Res> {
  __$$LoadingImplCopyWithImpl(
    _$LoadingImpl _value,
    $Res Function(_$LoadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrderDraftState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadingImpl implements _Loading {
  const _$LoadingImpl();

  @override
  String toString() {
    return 'OrderDraftState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<OrderDraft> drafts) loaded,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<OrderDraft> drafts)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<OrderDraft> drafts)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _Loading implements OrderDraftState {
  const factory _Loading() = _$LoadingImpl;
}

/// @nodoc
abstract class _$$LoadedImplCopyWith<$Res> {
  factory _$$LoadedImplCopyWith(
    _$LoadedImpl value,
    $Res Function(_$LoadedImpl) then,
  ) = __$$LoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<OrderDraft> drafts});
}

/// @nodoc
class __$$LoadedImplCopyWithImpl<$Res>
    extends _$OrderDraftStateCopyWithImpl<$Res, _$LoadedImpl>
    implements _$$LoadedImplCopyWith<$Res> {
  __$$LoadedImplCopyWithImpl(
    _$LoadedImpl _value,
    $Res Function(_$LoadedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrderDraftState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? drafts = null}) {
    return _then(
      _$LoadedImpl(
        null == drafts
            ? _value._drafts
            : drafts // ignore: cast_nullable_to_non_nullable
                as List<OrderDraft>,
      ),
    );
  }
}

/// @nodoc

class _$LoadedImpl implements _Loaded {
  const _$LoadedImpl(final List<OrderDraft> drafts) : _drafts = drafts;

  final List<OrderDraft> _drafts;
  @override
  List<OrderDraft> get drafts {
    if (_drafts is EqualUnmodifiableListView) return _drafts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_drafts);
  }

  @override
  String toString() {
    return 'OrderDraftState.loaded(drafts: $drafts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadedImpl &&
            const DeepCollectionEquality().equals(other._drafts, _drafts));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_drafts));

  /// Create a copy of OrderDraftState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoadedImplCopyWith<_$LoadedImpl> get copyWith =>
      __$$LoadedImplCopyWithImpl<_$LoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<OrderDraft> drafts) loaded,
    required TResult Function(String message) error,
  }) {
    return loaded(drafts);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<OrderDraft> drafts)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loaded?.call(drafts);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<OrderDraft> drafts)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(drafts);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class _Loaded implements OrderDraftState {
  const factory _Loaded(final List<OrderDraft> drafts) = _$LoadedImpl;

  List<OrderDraft> get drafts;

  /// Create a copy of OrderDraftState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoadedImplCopyWith<_$LoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrorImplCopyWith<$Res> {
  factory _$$ErrorImplCopyWith(
    _$ErrorImpl value,
    $Res Function(_$ErrorImpl) then,
  ) = __$$ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$ErrorImplCopyWithImpl<$Res>
    extends _$OrderDraftStateCopyWithImpl<$Res, _$ErrorImpl>
    implements _$$ErrorImplCopyWith<$Res> {
  __$$ErrorImplCopyWithImpl(
    _$ErrorImpl _value,
    $Res Function(_$ErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrderDraftState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$ErrorImpl(
        null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                as String,
      ),
    );
  }
}

/// @nodoc

class _$ErrorImpl implements _Error {
  const _$ErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'OrderDraftState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of OrderDraftState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      __$$ErrorImplCopyWithImpl<_$ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<OrderDraft> drafts) loaded,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<OrderDraft> drafts)? loaded,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<OrderDraft> drafts)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _Error implements OrderDraftState {
  const factory _Error(final String message) = _$ErrorImpl;

  String get message;

  /// Create a copy of OrderDraftState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
