class Product {
  final String prcode;
  final String pcode;
  final String pname;
  final double tprice;
  final double pdisc;
  final String? packing;

  Product({
    required this.prcode,
    required this.pcode,
    required this.pname,
    required this.tprice,
    required this.pdisc,
    this.packing,
  });
} 
