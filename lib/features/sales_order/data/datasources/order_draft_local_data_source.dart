import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order_draft_model.dart';
import '../../domain/entities/order_draft.dart';

abstract class OrderDraftLocalDataSource {
  Future<List<OrderDraftModel>> getOrderDrafts();
  Future<OrderDraftModel?> getOrderDraft(String id);
  Future<OrderDraftModel> saveOrderDraft(OrderDraft draft);
  Future<void> deleteOrderDraft(String id);
  Future<void> deleteAllOrderDrafts();
}

class OrderDraftLocalDataSourceImpl implements OrderDraftLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _draftsKey = 'order_drafts';

  OrderDraftLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<OrderDraftModel>> getOrderDrafts() async {
    final draftsJson = sharedPreferences.getStringList(_draftsKey) ?? [];
    print('OrderDrafts: Found ${draftsJson.length} drafts in SharedPreferences');
    final drafts = draftsJson
        .map((json) => OrderDraftModel.fromJson(jsonDecode(json)))
        .toList();
    print('OrderDrafts: Parsed ${drafts.length} drafts successfully');
    return drafts;
  }

  @override
  Future<OrderDraftModel?> getOrderDraft(String id) async {
    final drafts = await getOrderDrafts();
    try {
      return drafts.firstWhere((draft) => draft.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<OrderDraftModel> saveOrderDraft(OrderDraft draft) async {
    final drafts = await getOrderDrafts();
    print('OrderDrafts: Saving draft for client ${draft.clientName}');
    
    // Create or update draft
    final draftModel = OrderDraftModel.fromEntity(draft);
    final existingIndex = drafts.indexWhere((d) => d.id == draft.id);
    
    if (existingIndex >= 0) {
      // Update existing draft
      drafts[existingIndex] = draftModel;
      print('OrderDrafts: Updated existing draft');
    } else {
      // Add new draft
      drafts.add(draftModel);
      print('OrderDrafts: Added new draft');
    }

    // Save to SharedPreferences
    final draftsJson = drafts.map((d) => d.toJsonString()).toList();
    await sharedPreferences.setStringList(_draftsKey, draftsJson);
    print('OrderDrafts: Saved ${drafts.length} drafts to SharedPreferences');

    return draftModel;
  }

  @override
  Future<void> deleteOrderDraft(String id) async {
    print('OrderDrafts: Deleting draft with id: $id');
    final drafts = await getOrderDrafts();
    print('OrderDrafts: Found ${drafts.length} drafts before deletion');
    
    final initialCount = drafts.length;
    drafts.removeWhere((draft) => draft.id == id);
    final finalCount = drafts.length;
    
    print('OrderDrafts: Removed ${initialCount - finalCount} drafts');
    
    final draftsJson = drafts.map((d) => d.toJsonString()).toList();
    await sharedPreferences.setStringList(_draftsKey, draftsJson);
    print('OrderDrafts: Saved ${drafts.length} drafts after deletion');
  }

  @override
  Future<void> deleteAllOrderDrafts() async {
    await sharedPreferences.remove(_draftsKey);
  }
} 
