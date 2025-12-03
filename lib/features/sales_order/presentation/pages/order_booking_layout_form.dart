import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../bloc/order_draft_bloc.dart';
import '../../domain/entities/order_draft.dart';
import '../../domain/entities/product.dart';
import '../../../../core/database/offline_database_service.dart';
import 'package:collection/collection.dart'; // Added for firstWhereOrNull

class OrderBookingLayoutForm extends StatefulWidget {
  const OrderBookingLayoutForm({Key? key}) : super(key: key);

  @override
  State<OrderBookingLayoutForm> createState() => _OrderBookingLayoutFormState();
}

class _OrderBookingLayoutFormState extends State<OrderBookingLayoutForm> {
  final _formKey = GlobalKey<FormState>();
  final List<_OrderItem> _items = List.generate(4, (i) => _OrderItem());
  final _uuid = const Uuid();
  int? _selectedRowIdx;
  
  // Add products list for proper mapping
  List<Product> _availableProducts = [];
  final OfflineDatabaseService _databaseService = OfflineDatabaseService();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _databaseService.getOfflineProducts();
      setState(() {
        _availableProducts = products;
      });
      print('Loaded ${products.length} products for order booking form');
    } catch (e) {
      print('Error loading products: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Order Booking'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'SRC-1',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text('Daily Order Booking',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(3),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(3),
              },
              children: [
                TableRow(children: [
                  _cell('Order No.'),
                  _cell(''),
                  _cell('Order Date:'),
                  _cell(''),
                ]),
                TableRow(children: [
                  _cell('Customer Name:'),
                  _cell(''),
                  _cell('Town/City:'),
                  _cell(''),
                ]),
                TableRow(children: [
                  _cell('Address:'),
                  _cell(''),
                  _cell('Area Name:'),
                  _cell(''),
                ]),
                TableRow(children: [
                  _cell('Entry Date:'),
                  _cell(''),
                  _cell('Booking Man:'),
                  _cell(''),
                ]),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Table(
                    border: TableBorder.all(color: Colors.grey.shade400),
                    columnWidths: const {
                      0: FixedColumnWidth(40),
                      1: FlexColumnWidth(3),
                      2: FlexColumnWidth(2),
                      3: FlexColumnWidth(2),
                      4: FlexColumnWidth(2),
                      5: FlexColumnWidth(2),
                      6: FlexColumnWidth(2),
                      7: FlexColumnWidth(2),
                      8: FlexColumnWidth(2),
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: Colors.yellow.shade200),
                        children: [
                          _tableHeader('Sr.#'),
                          _tableHeader('Product Name:'),
                          _tableHeader('Packing'),
                          _tableHeader('Order Qnty.'),
                          _tableHeader('Bonus'),
                          _tableHeader('Disc.%'),
                          _tableHeader('Rate'),
                          _tableHeader('Amount'),
                          const SizedBox(),
                        ],
                      ),
                    ],
                  ),
                  ..._items.asMap().entries.expand((entry) {
                    final idx = entry.key;
                    final item = entry.value;
                    return [
                      Table(
                        border: TableBorder.all(color: Colors.grey.shade400),
                        columnWidths: const {
                          0: FixedColumnWidth(40),
                          1: FlexColumnWidth(3),
                          2: FlexColumnWidth(2),
                          3: FlexColumnWidth(2),
                          4: FlexColumnWidth(2),
                          5: FlexColumnWidth(2),
                          6: FlexColumnWidth(2),
                          7: FlexColumnWidth(2),
                          8: FlexColumnWidth(2),
                        },
                        children: [
                          TableRow(
                            children: [
                              _tableCell('${idx + 1}'),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedRowIdx = idx == _selectedRowIdx ? null : idx;
                                  });
                                },
                                child: _tableCellField(item.product),
                              ),
                              _tableCellField(item.packing),
                              _tableCellField(item.qty),
                              _tableCellField(item.bonus),
                              _tableCellField(item.disc),
                              _tableCellField(item.rate),
                              _tableCellField(item.amount),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                onPressed: () {
                                  setState(() { _items.removeAt(idx); });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ];
                  }).toList(),
                ],
              ),
            ),
            // Show product detail card below the table if a row is selected
            if (_selectedRowIdx != null && _selectedRowIdx! < _items.length)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.shade100.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Product Details',
                      style: TextStyle(
                        color: Colors.green[900],
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Product: 9${_items[_selectedRowIdx!].product.text.isNotEmpty ? _items[_selectedRowIdx!].product.text : 'No product selected.'}',
                      style: TextStyle(color: Colors.green[900], fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Packing: ${_items[_selectedRowIdx!].packing.text}',
                      style: TextStyle(color: Colors.green[900]),
                    ),
                    Text(
                      'Rate: ${_items[_selectedRowIdx!].rate.text}',
                      style: TextStyle(color: Colors.green[900]),
                    ),
                    Text(
                      'Bonus: ${_items[_selectedRowIdx!].bonus.text}',
                      style: TextStyle(color: Colors.green[900]),
                    ),
                    Text(
                      'Discount: ${_items[_selectedRowIdx!].disc.text}',
                      style: TextStyle(color: Colors.green[900]),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Row'),
                onPressed: () {
                  setState(() { _items.add(_OrderItem()); });
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('TOTAL:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
                Container(
                  width: 120,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Text(
                    _items.fold<double>(0, (sum, item) => sum + (double.tryParse(item.amount.text) ?? 0)).toStringAsFixed(2),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _saveDraft,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save Draft'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      textStyle: const TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _submitOrder,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Submit Order'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }

  static Widget _cell(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
  );

  static Widget _tableHeader(String text) => Padding(
    padding: const EdgeInsets.all(6),
    child: Text(text, style: TextStyle(fontWeight: FontWeight.bold)),
  );

  static Widget _tableCell(String text) => Padding(
    padding: const EdgeInsets.all(6),
    child: Text(text),
  );

  static Widget _tableCellField(TextEditingController controller) => Padding(
    padding: const EdgeInsets.all(4),
    child: TextField(
      controller: controller,
      decoration: const InputDecoration(
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      ),
      style: const TextStyle(fontSize: 14),
    ),
  );

  void _saveDraft() {
    // Example booking man code (should be from logged-in user)
    final String bookingManCode = 'SRC-1'; // TODO: Replace with actual user code
    final orderItems = _items
        .where((item) => item.product.text.isNotEmpty && 
                        item.qty.text.isNotEmpty && 
                        item.rate.text.isNotEmpty)
        .map((item) {
          final quantity = int.tryParse(item.qty.text) ?? 0;
          final unitPrice = double.tryParse(item.rate.text) ?? 0.0;
          final totalPrice = quantity * unitPrice;
          final discount = double.tryParse(item.disc.text) ?? 0.0;
          final bonus = double.tryParse(item.bonus.text) ?? 0.0;
          // Generate unique id for each item
          final String itemId = _uuid.v4();
          
          // Find the actual Product entity by name to get correct codes - NO DUMMY VALUES ALLOWED
          print('  === SEARCHING FOR PRODUCT IN DATABASE ===');
          print('  Available products count: ${_availableProducts.length}');
          print('  Searching for: "${item.product.text}"');
          
          Product? selectedProduct = _availableProducts.firstWhereOrNull(
            (p) => p.pname.toLowerCase().trim() == item.product.text.toLowerCase().trim(),
          );
          
          // Try partial match if exact match failed
          if (selectedProduct == null) {
            selectedProduct = _availableProducts.firstWhereOrNull(
              (p) => p.pname.toLowerCase().contains(item.product.text.toLowerCase()) ||
                     item.product.text.toLowerCase().contains(p.pname.toLowerCase()),
            );
          }
          
          if (selectedProduct == null) {
            print('  ❌ CRITICAL ERROR: Product "${item.product.text}" not found in offline database!');
            print('  ❌ Available products:');
            _availableProducts.take(10).forEach((p) {
              print('    - ${p.pname} (${p.pcode}) [${p.prcode}]');
            });
            
            // Instead of dummy values, throw an error
            throw Exception('CRITICAL: Product "${item.product.text}" not found in offline database. '
                'Please sync offline data before creating orders. '
                'This prevents sending incorrect product codes to server.');
          }
          
          print('=== ORDER ITEM DEBUG ===');
          print('Product Name: ${item.product.text}');
          print('Found Product: ${selectedProduct.pname}');
          print('PRCODE (Category): ${selectedProduct.prcode}');
          print('PCODE (Product): ${selectedProduct.pcode}');
          print('=========================');
          
          return OrderItem(
            id: itemId,
            bmCode: bookingManCode,
            prCode: selectedProduct.prcode, // Use actual prcode from Product entity
            productId: selectedProduct.pcode, // Use actual pcode as productId
            productName: selectedProduct.pname,
            productCode: selectedProduct.pcode, // Use actual pcode from Product entity
            unitPrice: unitPrice,
            quantity: quantity,
            totalPrice: totalPrice,
            discount: discount,
            bonus: bonus,
            packing: item.packing.text.isNotEmpty ? item.packing.text : null,
          );
        })
        .toList();

    if (orderItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one item to save as draft'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Create draft order
    final draft = OrderDraft(
      id: _uuid.v4(),
      clientId: 'draft_client',
      clientName: 'Draft Order',
      clientCity: 'Draft City',
      items: orderItems,
      totalAmount: orderItems.fold(0.0, (sum, item) => sum + item.totalPrice),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Save draft
    context.read<OrderDraftBloc>().add(OrderDraftEvent.saveDraft(draft));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Draft saved successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _submitOrder() {
    // TODO: Implement order submission logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Order submission not implemented yet'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

class _OrderItem {
  final TextEditingController product = TextEditingController();
  final TextEditingController packing = TextEditingController();
  final TextEditingController qty = TextEditingController();
  final TextEditingController bonus = TextEditingController();
  final TextEditingController disc = TextEditingController();
  final TextEditingController rate = TextEditingController();
  final TextEditingController amount = TextEditingController();
} 
