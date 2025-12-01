import '../../../sales_order/domain/entities/product.dart';

class ProductModel {
  final String prcode;
  final String pcode;
  final String pname;
  final double tprice;
  final double pdisc;

  ProductModel({
    required this.prcode,
    required this.pcode,
    required this.pname,
    required this.tprice,
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
      prcode: json['PRCODE'].toString(),
      pcode: json['PCODE'].toString(),
      pname: json['PNAME'] ?? '',
      tprice: parseDouble(json['TPRICE']),
      pdisc: parseDouble(json['PDISC']),
    );
  }

  Product toEntity() => Product(
    prcode: prcode,
    pcode: pcode,
    pname: pname,
    tprice: tprice.toString(),
    pdisc: pdisc.toString(),
  );
} 
