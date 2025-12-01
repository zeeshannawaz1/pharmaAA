import 'dart:convert';
import '../../domain/entities/order_draft.dart';
import 'package:uuid/uuid.dart';

class OrderDraftModel extends OrderDraft {
  const OrderDraftModel({
    required super.id,
    required super.clientId,
    required super.clientName,
    required super.clientCity,
    required super.items,
    required super.totalAmount,
    required super.createdAt,
    required super.updatedAt,
    super.notes,
    super.isConfirmedForProcessing,
    super.confirmedAt,
  });

  factory OrderDraftModel.fromJson(Map<String, dynamic> json) {
    return OrderDraftModel(
      id: json['id'] as String,
      clientId: json['clientId'] as String,
      clientName: json['clientName'] as String,
      clientCity: json['clientCity'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      notes: json['notes'] as String?,
      isConfirmedForProcessing: json['isConfirmedForProcessing'] as bool? ?? false,
      confirmedAt: json['confirmedAt'] != null ? DateTime.parse(json['confirmedAt'] as String) : null,
    );
  }

  factory OrderDraftModel.fromEntity(OrderDraft entity) {
    return OrderDraftModel(
      id: entity.id,
      clientId: entity.clientId,
      clientName: entity.clientName,
      clientCity: entity.clientCity,
      items: entity.items.map((item) => item is OrderItemModel ? item : OrderItemModel.fromEntity(item)).toList(),
      totalAmount: entity.totalAmount,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      notes: entity.notes,
      isConfirmedForProcessing: entity.isConfirmedForProcessing,
      confirmedAt: entity.confirmedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'clientName': clientName,
      'clientCity': clientCity,
      'items': items.map((item) => (item as OrderItemModel).toJson()).toList(),
      'totalAmount': totalAmount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'notes': notes,
      'isConfirmedForProcessing': isConfirmedForProcessing,
      'confirmedAt': confirmedAt?.toIso8601String(),
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  OrderDraft toEntity() {
    return OrderDraft(
      id: id,
      clientId: clientId,
      clientName: clientName,
      clientCity: clientCity,
      items: items.map((item) => (item as OrderItemModel).toEntity()).toList(),
      totalAmount: totalAmount,
      createdAt: createdAt,
      updatedAt: updatedAt,
      notes: notes,
      isConfirmedForProcessing: isConfirmedForProcessing,
      confirmedAt: confirmedAt,
    );
  }
}

class OrderItemModel extends OrderItem {
  const OrderItemModel({
    required super.id,
    required super.bmCode,
    required super.prCode,
    required super.productId,
    required super.productName,
    required super.productCode,
    required super.unitPrice,
    required super.quantity,
    required super.totalPrice,
    double? discount,
    double? bonus,
    String? packing,
  }) : super(discount: discount, bonus: bonus, packing: packing);

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as String? ?? Uuid().v4(),
      bmCode: json['bmCode'] as String? ?? 'SRC-1',
      prCode: json['prCode'] as String? ?? (json['productCode'] as String? ?? ''),
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      productCode: json['productCode'] as String,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      quantity: json['quantity'] as int,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      discount: json['discount'] == null ? null : (json['discount'] as num).toDouble(),
      bonus: json['bonus'] == null ? null : (json['bonus'] as num).toDouble(),
      packing: json['packing'] as String?,
    );
  }

  factory OrderItemModel.fromEntity(OrderItem entity) {
    return OrderItemModel(
      id: entity.id,
      bmCode: entity.bmCode,
      prCode: entity.prCode,
      productId: entity.productId,
      productName: entity.productName,
      productCode: entity.productCode,
      unitPrice: entity.unitPrice,
      quantity: entity.quantity,
      totalPrice: entity.totalPrice,
      discount: entity.discount,
      bonus: entity.bonus,
      packing: entity.packing,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bmCode': bmCode,
      'prCode': prCode,
      'productId': productId,
      'productName': productName,
      'productCode': productCode,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'totalPrice': totalPrice,
      if (discount != null) 'discount': discount,
      if (bonus != null) 'bonus': bonus,
      if (packing != null) 'packing': packing,
    };
  }

  @override
  OrderItem toEntity() {
    return OrderItem(
      id: id,
      bmCode: bmCode,
      prCode: prCode,
      productId: productId,
      productName: productName,
      productCode: productCode,
      unitPrice: unitPrice,
      quantity: quantity,
      totalPrice: totalPrice,
      discount: discount,
      bonus: bonus,
      packing: packing,
    );
  }
} 
