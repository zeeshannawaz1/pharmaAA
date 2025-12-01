class ProductModel {
  final String code;
  final String name;
  final double price;
  final int stock;

  ProductModel({
    required this.code,
    required this.name,
    required this.price,
    required this.stock,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      code: json['PCODE'] as String,
      name: json['PNAME'] as String,
      price: double.tryParse(json['TPRICE'].toString()) ?? 0.0,
      stock: int.tryParse(json['CLQTY'].toString()) ?? 0,
    );
  }
} 
