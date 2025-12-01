part of 'order_draft_bloc.dart';

@freezed
class OrderDraftState with _$OrderDraftState {
  const factory OrderDraftState.initial() = _Initial;
  const factory OrderDraftState.loading() = _Loading;
  const factory OrderDraftState.loaded(List<OrderDraft> drafts) = _Loaded;
  const factory OrderDraftState.error(String message) = _Error;
} 
