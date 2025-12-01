import '../../domain/entities/daily_report.dart';

class DailyReportModel {
  final String pcode;
  final String pname;
  final String packing;
  final double tprice;
  final double opqty;
  final double purqty;
  final double sqlty;
  final double clqty;

  DailyReportModel({
    required this.pcode,
    required this.pname,
    required this.packing,
    required this.tprice,
    required this.opqty,
    required this.purqty,
    required this.sqlty,
    required this.clqty,
  });

  factory DailyReportModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }
    return DailyReportModel(
      pcode: json['PCODE'].toString(),
      pname: json['PNAME'] ?? '',
      packing: json['PACKING'] ?? '',
      tprice: parseDouble(json['TPRICE']),
      opqty: parseDouble(json['OPQTY']),
      purqty: parseDouble(json['PURQTY']),
      sqlty: parseDouble(json['SQLTY']),
      clqty: parseDouble(json['CLQTY']),
    );
  }

  DailyReport toEntity() => DailyReport.fromLegacy(
    pcode: pcode,
    pname: pname,
    packing: packing,
    tprice: tprice,
    opqty: opqty,
    purqty: purqty,
    sqlty: sqlty,
    clqty: clqty,
  );
} 
