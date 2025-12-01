class DailyReport {
  final String date;
  final double totalSales;
  final int totalOrders;
  final int totalProducts;
  final String topProduct;
  final double topProductSales;
  final String topCategory;
  final double topCategorySales;
  final double averageOrderValue;
  final double growthRate;
  final int customerCount;
  final double returnRate;
  final double profitMargin;
  final String stockLevel;
  final String notes;

  // Legacy properties for backward compatibility
  final String? pcode;
  final String? pname;
  final String? packing;
  final double? tprice;
  final double? opqty;
  final double? purqty;
  final double? sqlty;
  final double? clqty;

  DailyReport({
    required this.date,
    required this.totalSales,
    required this.totalOrders,
    required this.totalProducts,
    required this.topProduct,
    required this.topProductSales,
    required this.topCategory,
    required this.topCategorySales,
    required this.averageOrderValue,
    required this.growthRate,
    required this.customerCount,
    required this.returnRate,
    required this.profitMargin,
    required this.stockLevel,
    required this.notes,
    // Legacy properties
    this.pcode,
    this.pname,
    this.packing,
    this.tprice,
    this.opqty,
    this.purqty,
    this.sqlty,
    this.clqty,
  });

  // Factory constructor for legacy data
  factory DailyReport.fromLegacy({
    required String pcode,
    required String pname,
    required String packing,
    required double tprice,
    required double opqty,
    required double purqty,
    required double sqlty,
    required double clqty,
  }) {
    return DailyReport(
      date: DateTime.now().toString().split(' ')[0],
      totalSales: tprice * sqlty,
      totalOrders: 1,
      totalProducts: 1,
      topProduct: pname,
      topProductSales: tprice * sqlty,
      topCategory: 'General',
      topCategorySales: tprice * sqlty,
      averageOrderValue: tprice * sqlty,
      growthRate: 0.0,
      customerCount: 1,
      returnRate: 0.0,
      profitMargin: 25.0,
      stockLevel: 'Good',
      notes: 'Legacy data converted',
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
} 
