import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../../../core/services/confirmed_orders_service.dart';
import '../../../sales_order/domain/entities/order_draft.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({Key? key}) : super(key: key);

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  DateTimeRange? _selectedRange;
  String? _selectedClient;
  String? _selectedProduct;
  bool _isLoading = false;
  List<Map<String, dynamic>> _orders = [];
  List<String> _clients = ['All Clients'];
  List<String> _products = ['All Products'];
  String? _error;

  final ConfirmedOrdersService _confirmedOrdersService = ConfirmedOrdersService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load confirmed orders from local storage
      final confirmedOrders = await _confirmedOrdersService.getConfirmedOrders();
      
      // Also try to fetch from server
      List<Map<String, dynamic>> serverOrders = [];
      try {
        final url = Uri.parse('http://137.59.224.222:8080/zee_order_confirmed.php');
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final decoded = json.decode(response.body);
          if (decoded is Map && decoded['orders'] is List) {
            serverOrders = List<Map<String, dynamic>>.from(decoded['orders']);
          }
        }
      } catch (e) {
        print('Server fetch error: $e');
      }

      // Combine local and server data
      final allOrders = <Map<String, dynamic>>[];
      
      // Add confirmed orders from local storage
      for (final order in confirmedOrders) {
        for (final item in order.items) {
          allOrders.add({
            'date': DateFormat('yyyy-MM-dd').format(order.createdAt),
            'client': order.clientName,
            'product': item.productName,
            'qty': item.quantity,
            'price': item.unitPrice,
            'discount': item.discount ?? 0,
            'bonus': item.bonus ?? 0,
            'total': item.totalPrice,
            'order_id': order.id,
          });
        }
      }

      // Add server orders
      for (final order in serverOrders) {
        // Safe conversion of numeric values
        final qty = order['QNTY'];
        final price = order['TPRICE'];
        final discount = order['ODISC'];
        final bonus = order['BQNTY'];
        final amount = order['AMOUNT'];
        
        allOrders.add({
          'date': order['V_DATE']?.toString().split(' ')[0] ?? '',
          'client': order['CLIENTCODE']?.toString() ?? 'Unknown',
          'product': order['PNAME']?.toString() ?? 'Unknown',
          'qty': _safeToInt(qty),
          'price': _safeToDouble(price),
          'discount': _safeToDouble(discount),
          'bonus': _safeToDouble(bonus),
          'total': _safeToDouble(amount),
          'order_id': order['BO_ID']?.toString() ?? '',
        });
      }

      // Extract unique clients and products
      final uniqueClients = <String>{};
      final uniqueProducts = <String>{};
      
      for (final order in allOrders) {
        uniqueClients.add(order['client'] as String);
        uniqueProducts.add(order['product'] as String);
      }

      setState(() {
        _orders = allOrders;
        _clients = ['All Clients', ...uniqueClients.toList()..sort()];
        _products = ['All Products', ...uniqueProducts.toList()..sort()];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getFilteredOrders() {
    List<Map<String, dynamic>> filtered = List.from(_orders);

    // Apply date range filter
    if (_selectedRange != null) {
      filtered = filtered.where((order) {
        final orderDate = DateTime.tryParse(order['date'] as String);
        if (orderDate == null) return false;
        return orderDate.isAfter(_selectedRange!.start.subtract(const Duration(days: 1))) &&
               orderDate.isBefore(_selectedRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    // Apply client filter
    if (_selectedClient != null && _selectedClient != 'All Clients') {
      filtered = filtered.where((order) => order['client'] == _selectedClient).toList();
    }

    // Apply product filter
    if (_selectedProduct != null && _selectedProduct != 'All Products') {
      filtered = filtered.where((order) => order['product'] == _selectedProduct).toList();
    }

    return filtered;
  }

  Map<String, dynamic> _calculateSummary(List<Map<String, dynamic>> orders) {
    if (orders.isEmpty) {
      return {
        'totalSales': 0.0,
        'totalOrders': 0,
        'topClient': '-',
        'topProduct': '-',
      };
    }

    double totalSales = 0;
    final clientSales = <String, double>{};
    final productSales = <String, double>{};
    final orderIds = <String>{};

    for (final order in orders) {
      // Safe conversion of total value
      double total = 0;
      final totalValue = order['total'];
      if (totalValue is num) {
        total = totalValue.toDouble();
      } else if (totalValue is String) {
        total = double.tryParse(totalValue) ?? 0;
      }
      
      final client = order['client']?.toString() ?? 'Unknown';
      final product = order['product']?.toString() ?? 'Unknown';
      final orderId = order['order_id']?.toString() ?? '';

      totalSales += total;
      if (orderId.isNotEmpty) {
        orderIds.add(orderId);
      }
      
      clientSales[client] = (clientSales[client] ?? 0) + total;
      productSales[product] = (productSales[product] ?? 0) + total;
    }

    final topClient = clientSales.entries.isEmpty 
        ? '-' 
        : clientSales.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    
    final topProduct = productSales.entries.isEmpty 
        ? '-' 
        : productSales.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return {
      'totalSales': totalSales,
      'totalOrders': orderIds.length,
      'topClient': topClient,
      'topProduct': topProduct,
    };
  }

  // Helper methods for safe type conversion
  int _safeToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  double _safeToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _getFilteredOrders();
    final summary = _calculateSummary(filteredOrders);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
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
                  'R-1',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text('Error loading data', style: TextStyle(color: Colors.red[700])),
                      const SizedBox(height: 8),
                      Text(_error!, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(
                              width: 150,
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          initialDateRange: _selectedRange,
                        );
                        if (picked != null) {
                          setState(() => _selectedRange = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date Range',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.date_range),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          constraints: BoxConstraints(maxHeight: 48),
                        ),
                        child: Text(
                          _selectedRange == null
                              ? 'Select range'
                              : '${_selectedRange!.start.toString().split(' ')[0]} - ${_selectedRange!.end.toString().split(' ')[0]}',
                          overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                              width: 120,
                    child: DropdownButtonFormField<String>(
                      isDense: true,
                      value: _selectedClient ?? _clients.first,
                      items: _clients
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(
                                  c,
                                  overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 12),
                                ),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedClient = val),
                      decoration: const InputDecoration(
                        labelText: 'Client',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        constraints: BoxConstraints(maxHeight: 48),
                      ),
                                menuMaxHeight: 200,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                              width: 120,
                    child: DropdownButtonFormField<String>(
                      isDense: true,
                      value: _selectedProduct ?? _products.first,
                      items: _products
                          .map((p) => DropdownMenuItem(
                                value: p,
                                child: Text(
                                  p,
                                  overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 12),
                                ),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedProduct = val),
                      decoration: const InputDecoration(
                        labelText: 'Product',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        constraints: BoxConstraints(maxHeight: 48),
                      ),
                                menuMaxHeight: 200,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Summary Cards Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                            _SummaryCard(title: 'Total Sales', value: 'PKR ${summary['totalSales'].toStringAsFixed(0)}'),
                            _SummaryCard(title: 'Total Orders', value: '${summary['totalOrders']}'),
                            _SummaryCard(title: 'Top Client', value: summary['topClient']),
                            _SummaryCard(title: 'Top Product', value: summary['topProduct']),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Reports Table/List
            Expanded(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                                    Flexible(flex: 2, child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11), overflow: TextOverflow.ellipsis)),
                                    Flexible(flex: 2, child: Text('Client', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11), overflow: TextOverflow.ellipsis)),
                                    Flexible(flex: 2, child: Text('Product', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11), overflow: TextOverflow.ellipsis)),
                                    Flexible(flex: 1, child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11), overflow: TextOverflow.ellipsis)),
                                    Flexible(flex: 1, child: Text('Price', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11), overflow: TextOverflow.ellipsis)),
                                    Flexible(flex: 1, child: Text('Disc', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11), overflow: TextOverflow.ellipsis)),
                                    Flexible(flex: 1, child: Text('Bonus', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11), overflow: TextOverflow.ellipsis)),
                                    Flexible(flex: 2, child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11), overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                      const Divider(),
                                Expanded(
                                  child: filteredOrders.isEmpty
                                      ? const Center(
                          child: Text('No data for selected filters.', style: TextStyle(color: Colors.grey)),
                                        )
                                      : ListView.builder(
                                          itemCount: filteredOrders.length,
                                          itemBuilder: (context, index) {
                                            final order = filteredOrders[index];
                                            return Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 4),
                                              child: Row(
                                                children: [
                                                  Flexible(flex: 2, child: Text(order['date']?.toString() ?? '-', style: const TextStyle(fontSize: 10), overflow: TextOverflow.ellipsis)),
                                                  Flexible(flex: 2, child: Text(order['client']?.toString() ?? '-', style: const TextStyle(fontSize: 10), overflow: TextOverflow.ellipsis)),
                                                  Flexible(flex: 2, child: Text(order['product']?.toString() ?? '-', style: const TextStyle(fontSize: 10), overflow: TextOverflow.ellipsis)),
                                                  Flexible(flex: 1, child: Text('${order['qty']?.toString() ?? '-'}', style: const TextStyle(fontSize: 10), overflow: TextOverflow.ellipsis)),
                                                  Flexible(flex: 1, child: Text('${order['price']?.toString() ?? '-'}', style: const TextStyle(fontSize: 10), overflow: TextOverflow.ellipsis)),
                                                  Flexible(flex: 1, child: Text('${order['discount']?.toString() ?? '-'}', style: const TextStyle(fontSize: 10), overflow: TextOverflow.ellipsis)),
                                                  Flexible(flex: 1, child: Text('${order['bonus']?.toString() ?? '-'}', style: const TextStyle(fontSize: 10), overflow: TextOverflow.ellipsis)),
                                                  Flexible(flex: 2, child: Text('${order['total']?.toString() ?? '-'}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                                                ],
                                              ),
                                            );
                                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  const _SummaryCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 1,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        child: Column(
          children: [
            Text(
              title, 
              style: TextStyle(fontSize: 11, color: Colors.blue[900], fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            const SizedBox(height: 6),
            Text(
              value, 
              style: TextStyle(fontSize: 14, color: Colors.blue[800], fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
} 
