class ProductModel {
  final String code;
  final String name;
  final double price;
  final int stock;
  final double pdisc;

  ProductModel({
    required this.code,
    required this.name,
    required this.price,
    required this.stock,
    required this.pdisc,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return ProductModel(
      code: json['PCODE'] as String,
      name: json['PNAME'] as String,
      price: double.tryParse(json['TPRICE'].toString()) ?? 0.0,
      stock: int.tryParse(json['CLQTY']?.toString() ?? '0') ?? 0,
      pdisc: parseDouble(json['PDISC']),
    );
  }
} 
