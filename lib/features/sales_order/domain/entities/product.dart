class Product {
  final String prcode;
  final String pcode;
  final String pname;
  final String tprice;
  final String pdisc;
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
