import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/sales_order/domain/entities/order_draft.dart';
import '../../features/sales_order/data/models/order_draft_model.dart';

class ConfirmedOrdersService {
  static const String _confirmedOrdersKey = 'confirmed_orders';
  static const String _pendingServerSyncKey = 'pending_server_sync';

  // Save confirmed order to local storage and POST to server
  Future<void> saveConfirmedOrder(OrderDraft draft) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get existing confirmed orders
    final confirmedOrdersJson = prefs.getStringList(_confirmedOrdersKey) ?? [];
    final confirmedOrders = confirmedOrdersJson
        .map((json) => OrderDraftModel.fromJson(jsonDecode(json)))
        .toList();
    
    // Add new confirmed order
    final confirmedDraft = draft.copyWith(
      isConfirmedForProcessing: true,
      confirmedAt: DateTime.now(),
    );
    
    final draftModel = OrderDraftModel.fromEntity(confirmedDraft);
    confirmedOrders.add(draftModel);
    
    // Save back to storage
    final updatedJson = confirmedOrders.map((d) => d.toJsonString()).toList();
    await prefs.setStringList(_confirmedOrdersKey, updatedJson);
    
    // Add to pending server sync list
    final pendingSyncJson = prefs.getStringList(_pendingServerSyncKey) ?? [];
    pendingSyncJson.add(draftModel.toJsonString());
    await prefs.setStringList(_pendingServerSyncKey, pendingSyncJson);
    
    print('=== CONFIRMED ORDER SAVED ===');
    print('Order ID: ${draft.id}');
    print('Client: ${draft.clientName}');
    print('Total Amount: ${draft.totalAmount}');
    print('Confirmed at: ${DateTime.now()}');
    print('Total confirmed orders: ${confirmedOrders.length}');
  }

  // Get all confirmed orders
  Future<List<OrderDraft>> getConfirmedOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final confirmedOrdersJson = prefs.getStringList(_confirmedOrdersKey) ?? [];
    
    return confirmedOrdersJson
        .map((json) => OrderDraftModel.fromJson(jsonDecode(json)).toEntity())
        .toList();
  }

  // Get pending server sync orders
  Future<List<OrderDraft>> getPendingServerSyncOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final pendingSyncJson = prefs.getStringList(_pendingServerSyncKey) ?? [];
    
    return pendingSyncJson
        .map((json) => OrderDraftModel.fromJson(jsonDecode(json)).toEntity())
        .toList();
  }

  // Mark order as synced to server (remove from pending)
  Future<void> markOrderAsSynced(String orderId) async {
    final prefs = await SharedPreferences.getInstance();
    final pendingSyncJson = prefs.getStringList(_pendingServerSyncKey) ?? [];
    
    final updatedPending = pendingSyncJson.where((json) {
      final order = OrderDraftModel.fromJson(jsonDecode(json));
      return order.id != orderId;
    }).toList();
    
    await prefs.setStringList(_pendingServerSyncKey, updatedPending);
  }

  // Get confirmed orders count
  Future<int> getConfirmedOrdersCount() async {
    final prefs = await SharedPreferences.getInstance();
    final confirmedOrdersJson = prefs.getStringList(_confirmedOrdersKey) ?? [];
    return confirmedOrdersJson.length;
  }

  // Get pending sync count
  Future<int> getPendingSyncCount() async {
    final prefs = await SharedPreferences.getInstance();
    final pendingSyncJson = prefs.getStringList(_pendingServerSyncKey) ?? [];
    return pendingSyncJson.length;
  }

  // Clear all confirmed orders (for testing/reset)
  Future<void> clearAllConfirmedOrders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_confirmedOrdersKey);
    await prefs.remove(_pendingServerSyncKey);
  }
} 
