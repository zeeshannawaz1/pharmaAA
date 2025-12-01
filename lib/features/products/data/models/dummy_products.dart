import '../../domain/entities/product.dart';

class DummyProducts {
  static List<Product> getProducts() {
    return [
      Product(
        prcode: 'MED001',
        pcode: 'P001',
        pname: 'Paracetamol 500mg',
        tprice: 150.0,
        pdisc: 10.0,
      ),
      Product(
        prcode: 'MED001',
        pcode: 'P002',
        pname: 'Ibuprofen 400mg',
        tprice: 200.0,
        pdisc: 0.0,
      ),
      Product(
        prcode: 'MED002',
        pcode: 'P003',
        pname: 'Amoxicillin 500mg',
        tprice: 350.0,
        pdisc: 15.0,
      ),
      Product(
        prcode: 'MED002',
        pcode: 'P004',
        pname: 'Omeprazole 20mg',
        tprice: 450.0,
        pdisc: 5.0,
      ),
      Product(
        prcode: 'VIT001',
        pcode: 'P005',
        pname: 'Vitamin C 1000mg',
        tprice: 300.0,
        pdisc: 20.0,
      ),
      Product(
        prcode: 'VIT001',
        pcode: 'P006',
        pname: 'Vitamin D3 1000IU',
        tprice: 250.0,
        pdisc: 0.0,
      ),
      Product(
        prcode: 'VIT002',
        pcode: 'P007',
        pname: 'Multivitamin Complex',
        tprice: 500.0,
        pdisc: 25.0,
      ),
      Product(
        prcode: 'SKIN001',
        pcode: 'P008',
        pname: 'Moisturizing Cream',
        tprice: 180.0,
        pdisc: 0.0,
      ),
      Product(
        prcode: 'SKIN001',
        pcode: 'P009',
        pname: 'Sunscreen SPF 50',
        tprice: 220.0,
        pdisc: 10.0,
      ),
      Product(
        prcode: 'SKIN002',
        pcode: 'P010',
        pname: 'Anti-Aging Serum',
        tprice: 800.0,
        pdisc: 30.0,
      ),
      Product(
        prcode: 'CARD001',
        pcode: 'P011',
        pname: 'Aspirin 100mg',
        tprice: 120.0,
        pdisc: 0.0,
      ),
      Product(
        prcode: 'CARD001',
        pcode: 'P012',
        pname: 'Atorvastatin 20mg',
        tprice: 600.0,
        pdisc: 15.0,
      ),
      Product(
        prcode: 'DIAB001',
        pcode: 'P013',
        pname: 'Metformin 500mg',
        tprice: 180.0,
        pdisc: 0.0,
      ),
      Product(
        prcode: 'DIAB001',
        pcode: 'P014',
        pname: 'Glimepiride 1mg',
        tprice: 220.0,
        pdisc: 5.0,
      ),
      Product(
        prcode: 'RESP001',
        pcode: 'P015',
        pname: 'Salbutamol Inhaler',
        tprice: 280.0,
        pdisc: 0.0,
      ),
      Product(
        prcode: 'RESP001',
        pcode: 'P016',
        pname: 'Montelukast 10mg',
        tprice: 320.0,
        pdisc: 10.0,
      ),
      Product(
        prcode: 'EYE001',
        pcode: 'P017',
        pname: 'Artificial Tears',
        tprice: 150.0,
        pdisc: 0.0,
      ),
      Product(
        prcode: 'EYE001',
        pcode: 'P018',
        pname: 'Eye Drops Antibiotic',
        tprice: 200.0,
        pdisc: 5.0,
      ),
      Product(
        prcode: 'DENT001',
        pcode: 'P019',
        pname: 'Toothpaste Fluoride',
        tprice: 120.0,
        pdisc: 0.0,
      ),
      Product(
        prcode: 'DENT001',
        pcode: 'P020',
        pname: 'Mouthwash Antiseptic',
        tprice: 180.0,
        pdisc: 10.0,
      ),
    ];
  }

  static List<String> getCategories() {
    return [
      'All',
      'MED001',
      'MED002',
      'VIT001',
      'VIT002',
      'SKIN001',
      'SKIN002',
      'CARD001',
      'DIAB001',
      'RESP001',
      'EYE001',
      'DENT001',
    ];
  }

  static Map<String, String> getCategoryNames() {
    return {
      'MED001': 'Pain Relief',
      'MED002': 'Antibiotics',
      'VIT001': 'Vitamins',
      'VIT002': 'Multivitamins',
      'SKIN001': 'Skincare',
      'SKIN002': 'Anti-Aging',
      'CARD001': 'Cardiovascular',
      'DIAB001': 'Diabetes',
      'RESP001': 'Respiratory',
      'EYE001': 'Eye Care',
      'DENT001': 'Dental Care',
    };
  }
} 
