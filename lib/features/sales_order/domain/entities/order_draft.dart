import 'package:equatable/equatable.dart';

class OrderDraft extends Equatable {
  final String id;
  final String clientId;
  final String clientName;
  final String clientCity;
  final List<OrderItem> items;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;
  final bool isConfirmedForProcessing; // New field for confirmation status
  final DateTime? confirmedAt; // When the order was confirmed
  final List<Map<String, dynamic>>? exportData; // Export data saved during confirmation

  const OrderDraft({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.clientCity,
    required this.items,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.isConfirmedForProcessing = false,
    this.confirmedAt,
    this.exportData,
  });

  @override
  List<Object?> get props => [
        id,
        clientId,
        clientName,
        clientCity,
        items,
        totalAmount,
        createdAt,
        updatedAt,
        notes,
        isConfirmedForProcessing,
        confirmedAt,
        exportData,
      ];

  OrderDraft copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? clientCity,
    List<OrderItem>? items,
    double? totalAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    bool? isConfirmedForProcessing,
    DateTime? confirmedAt,
    List<Map<String, dynamic>>? exportData,
  }) {
    return OrderDraft(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      clientCity: clientCity ?? this.clientCity,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      isConfirmedForProcessing: isConfirmedForProcessing ?? this.isConfirmedForProcessing,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      exportData: exportData ?? this.exportData,
    );
  }
}

class OrderItem extends Equatable {
  final String id; // unique per item
  final String bmCode; // booking man/user code
  final String prCode; // product reference code
  final String productId;
  final String productName;
  final String productCode;
  final double unitPrice;
  final int quantity;
  final double totalPrice;
  final double? discount; // nullable
  final double? bonus;    // nullable
  final String? packing;  // nullable - packing information

  const OrderItem({
    required this.id,
    required this.bmCode,
    required this.prCode,
    required this.productId,
    required this.productName,
    required this.productCode,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
    this.discount,
    this.bonus,
    this.packing,
  });

  @override
  List<Object?> get props => [
    id,
    bmCode,
    prCode,
    productId,
    productName,
    productCode,
    unitPrice,
    quantity,
    totalPrice,
    discount,
    bonus,
    packing,
  ];

  OrderItem copyWith({
    String? id,
    String? bmCode,
    String? prCode,
    String? productId,
    String? productName,
    String? productCode,
    double? unitPrice,
    int? quantity,
    double? totalPrice,
    double? discount,
    double? bonus,
    String? packing,
  }) {
    return OrderItem(
      id: id ?? this.id,
      bmCode: bmCode ?? this.bmCode,
      prCode: prCode ?? this.prCode,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productCode: productCode ?? this.productCode,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      totalPrice: totalPrice ?? this.totalPrice,
      discount: discount ?? this.discount,
      bonus: bonus ?? this.bonus,
      packing: packing ?? this.packing,
    );
  }
} 
