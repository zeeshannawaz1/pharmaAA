import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:equatable/equatable.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/order_draft.dart';
import '../../domain/usecases/get_order_drafts.dart';
import '../../domain/usecases/save_order_draft.dart';
import '../../domain/usecases/delete_order_draft.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/services/confirmed_orders_service.dart';

part 'order_draft_event.dart';
part 'order_draft_state.dart';
part 'order_draft_bloc.freezed.dart';

class OrderDraftBloc extends Bloc<OrderDraftEvent, OrderDraftState> {
  final GetOrderDrafts getOrderDrafts;
  final SaveOrderDraft saveOrderDraft;
  final DeleteOrderDraft deleteOrderDraft;
  final ConfirmedOrdersService _confirmedOrdersService = ConfirmedOrdersService();

  OrderDraftBloc({
    required this.getOrderDrafts,
    required this.saveOrderDraft,
    required this.deleteOrderDraft,
  }) : super(const OrderDraftState.initial()) {
    on<OrderDraftEvent>((event, emit) async {
      print('OrderDraftBloc: Received event: ${event.runtimeType}');
      await event.map(
        loadDrafts: (e) async => await _onLoadDrafts(e, emit),
        saveDraft: (e) async => await _onSaveDraft(e, emit),
        deleteDraft: (e) async => await _onDeleteDraft(e, emit),
        clearDrafts: (e) async => await _onClearDrafts(e, emit),
        confirmDraftForProcessing: (e) async => await _onConfirmDraftForProcessing(e, emit),
      );
    });
  }

  Future<void> _onLoadDrafts(_LoadDrafts event, Emitter<OrderDraftState> emit) async {
    print('OrderDraftBloc: Loading drafts...');
    emit(const OrderDraftState.loading());
    
    final result = await getOrderDrafts(NoParams());
    
    result.fold(
      (failure) {
        print('OrderDraftBloc: Error loading drafts: ${failure.message}');
        emit(OrderDraftState.error(failure.message));
      },
      (drafts) {
        print('OrderDraftBloc: Loaded ${drafts.length} drafts');
        emit(OrderDraftState.loaded(drafts));
      },
    );
  }

  Future<void> _onSaveDraft(_SaveDraft event, Emitter<OrderDraftState> emit) async {
    print('OrderDraftBloc: Saving draft for client: ${event.draft.clientName}');
    emit(OrderDraftState.loading());
    
    final result = await saveOrderDraft(SaveOrderDraftParams(draft: event.draft));
    
    await result.fold(
      (failure) async {
        print('OrderDraftBloc: Error saving draft: ${failure.message}');
        emit(OrderDraftState.error(failure.message));
      },
      (savedDraft) async {
        print('OrderDraftBloc: Draft saved successfully. Reloading drafts...');
        // Reload all drafts after saving
        final draftsResult = await getOrderDrafts(NoParams());
        draftsResult.fold(
          (failure) {
            print('OrderDraftBloc: Error reloading drafts: ${failure.message}');
            emit(OrderDraftState.error(failure.message));
          },
          (drafts) {
            print('OrderDraftBloc: Reloaded ${drafts.length} drafts after save');
            emit(OrderDraftState.loaded(drafts));
          },
        );
      },
    );
  }

  Future<void> _onDeleteDraft(_DeleteDraft event, Emitter<OrderDraftState> emit) async {
    print('OrderDraftBloc: Deleting draft with id: ${event.draftId}');
    emit(OrderDraftState.loading());
    
    final result = await deleteOrderDraft(event.draftId);
    
    await result.fold(
      (failure) async {
        print('OrderDraftBloc: Error deleting draft: ${failure.message}');
        emit(OrderDraftState.error(failure.message));
      },
      (_) async {
        print('OrderDraftBloc: Draft deleted. Reloading drafts...');
        // Reload all drafts after deleting
        final draftsResult = await getOrderDrafts(NoParams());
        draftsResult.fold(
          (failure) {
            print('OrderDraftBloc: Error reloading drafts after delete: ${failure.message}');
            emit(OrderDraftState.error(failure.message));
          },
          (drafts) {
            print('OrderDraftBloc: Reloaded ${drafts.length} drafts after delete');
            emit(OrderDraftState.loaded(drafts));
          },
        );
      },
    );
  }

  Future<void> _onClearDrafts(_ClearDrafts event, Emitter<OrderDraftState> emit) async {
    print('OrderDraftBloc: Clearing all drafts');
    emit(const OrderDraftState.loaded([]));
  }

  Future<void> _onConfirmDraftForProcessing(_ConfirmDraftForProcessing event, Emitter<OrderDraftState> emit) async {
    print('OrderDraftBloc: Confirming draft for processing: ${event.draft.clientName}');
    emit(OrderDraftState.loading());
    
    try {
      // Generate export data during confirmation
      final exportData = await _generateExportDataForDraft(event.draft);
      print('OrderDraftBloc: Generated ${exportData.length} export records for confirmation');
      
      // Save to confirmed orders service
      await _confirmedOrdersService.saveConfirmedOrder(event.draft);
      
      // Update the draft in local storage to mark it as confirmed with export data
      final confirmedDraft = event.draft.copyWith(
        isConfirmedForProcessing: true,
        confirmedAt: DateTime.now(),
        exportData: exportData,
      );
      
      final result = await saveOrderDraft(SaveOrderDraftParams(draft: confirmedDraft));
      
      await result.fold(
        (failure) async {
          print('OrderDraftBloc: Error updating draft confirmation: ${failure.message}');
          emit(OrderDraftState.error(failure.message));
        },
        (savedDraft) async {
          print('OrderDraftBloc: Draft confirmed successfully with export data. Reloading drafts...');
          // Reload all drafts after confirming
          final draftsResult = await getOrderDrafts(NoParams());
          draftsResult.fold(
            (failure) {
              print('OrderDraftBloc: Error reloading drafts: ${failure.message}');
              emit(OrderDraftState.error(failure.message));
            },
            (drafts) {
              print('OrderDraftBloc: Reloaded ${drafts.length} drafts after confirmation');
              emit(OrderDraftState.loaded(drafts));
            },
          );
        },
      );
    } catch (e) {
      print('OrderDraftBloc: Error confirming draft: $e');
      emit(OrderDraftState.error('Failed to confirm draft: $e'));
    }
  }

  // Generate export data for a draft
  Future<List<Map<String, dynamic>>> _generateExportDataForDraft(OrderDraft draft) async {
    try {
      // Get booking man ID from SharedPreferences
      String bookingManId = '123'; // Default fallback
      try {
        final prefs = await SharedPreferences.getInstance();
        final savedBookingManId = prefs.getString('booking_man_id');
        if (savedBookingManId != null && savedBookingManId.isNotEmpty) {
          bookingManId = savedBookingManId;
        }
        print('Loaded Booking Man ID: $bookingManId');
      } catch (e) {
        print('Error loading booking man ID: $e');
      }
      
      List<Map<String, dynamic>> exportData = [];
      
      for (final item in draft.items) {
        // Generate unique 8-digit BO ID for each item
        final uniqueBoId = _generateUniqueBoId();
        
        print('Generating export data for item: ${item.productName}');
        print('  - Unique BO_ID: $uniqueBoId (8-digit format)');
        
        exportData.add({
          'bo_id': uniqueBoId,
          'bm_code': int.tryParse(bookingManId) ?? 123,
          'client_code': draft.clientId,
          'pr_code': item.prCode,
          'pcode': item.productCode,
          'item_name': item.productName,
          'qty': item.quantity,
          'bonus': item.bonus ?? 0,
          'dis_percent': item.discount ?? 0,
          'total_amount': item.totalPrice,
        });
      }
      
      print('Generated ${exportData.length} export records for draft: ${draft.clientName}');
      return exportData;
      
    } catch (e) {
      print('Error generating export data: $e');
      return [];
    }
  }

  // Generate unique 8-digit BO ID for professional export
  int _generateUniqueBoId() {
    final random = Random();
    // Generate random 8-digit number between 10000000 and 99999999
    final baseId = 10000000 + random.nextInt(90000000);
    
    // Add timestamp-based uniqueness to ensure no duplicates
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final timestampSuffix = timestamp % 1000; // Last 3 digits of timestamp
    
    // Combine base ID with timestamp for uniqueness, ensuring 8 digits
    final uniqueId = (baseId + timestampSuffix) % 100000000;
    
    // Ensure it's always 8 digits (minimum 10000000)
    return uniqueId < 10000000 ? uniqueId + 10000000 : uniqueId;
  }
} 
