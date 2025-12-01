part of 'order_draft_bloc.dart';

@freezed
class OrderDraftEvent with _$OrderDraftEvent {
  const factory OrderDraftEvent.loadDrafts() = _LoadDrafts;
  const factory OrderDraftEvent.saveDraft(OrderDraft draft) = _SaveDraft;
  const factory OrderDraftEvent.deleteDraft(String draftId) = _DeleteDraft;
  const factory OrderDraftEvent.clearDrafts() = _ClearDrafts;
  const factory OrderDraftEvent.confirmDraftForProcessing(OrderDraft draft) = _ConfirmDraftForProcessing;
} 
