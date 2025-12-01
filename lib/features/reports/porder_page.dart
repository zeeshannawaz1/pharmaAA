import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ProcessedOrdersPage extends StatefulWidget {
  const ProcessedOrdersPage({Key? key}) : super(key: key);

  @override
  State<ProcessedOrdersPage> createState() => _ProcessedOrdersPageState();
}

class _ProcessedOrdersPageState extends State<ProcessedOrdersPage> {
  final TextEditingController _bmcodeController = TextEditingController();
  final TextEditingController _clientcodeController = TextEditingController();
  DateTime? _fromDate;
  DateTime? _toDate;
  int _currentPage = 0;
  static const int _pageSize = 20;
  List<Map<String, dynamic>> _allOrders = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAndSetOrders();
  }

  Future<List<Map<String, dynamic>>> fetchProcessedOrders() async {
    final uri = Uri.parse('http://137.59.224.222:8080/zee_order_confirmed.php');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success' && data['orders'] is List) {
        return List<Map<String, dynamic>>.from(data['orders']);
      } else {
        throw Exception(data['message'] ?? 'Unknown error');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  void _fetchAndSetOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final orders = await fetchProcessedOrders();
      setState(() {
        _allOrders = _applyAppSideFilters(orders);
        _currentPage = 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _applyAppSideFilters(List<Map<String, dynamic>> orders) {
    return orders.where((order) {
      final bmcode = _bmcodeController.text.trim();
      final clientcode = _clientcodeController.text.trim();
      final qBmcode = order['BMCODE']?.toString() ?? '';
      final qClientcode = order['CLIENTCODE']?.toString() ?? '';
      final qDateStr = order['V_DATE']?.toString() ?? '';
      DateTime? qDate;
      try {
        qDate = DateFormat('dd-MMM-yyyy').parse(qDateStr);
      } catch (_) {}
      bool matches = true;
      if (bmcode.isNotEmpty) {
        matches &= qBmcode == bmcode;
      }
      if (clientcode.isNotEmpty) {
        matches &= qClientcode == clientcode;
      }
      if (_fromDate != null && qDate != null) {
        matches &= !qDate.isBefore(_fromDate!);
      }
      if (_toDate != null && qDate != null) {
        matches &= !qDate.isAfter(_toDate!);
      }
      return matches;
    }).toList();
  }

  void _applyFilters() {
    _fetchAndSetOrders();
  }

  void _clearFilters() {
    setState(() {
      _bmcodeController.clear();
      _clientcodeController.clear();
      _fromDate = null;
      _toDate = null;
    });
    _fetchAndSetOrders();
  }

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    final initialDate = isFrom ? (_fromDate ?? DateTime.now()) : (_toDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }

  void _showInsightsModal(BuildContext context) {
    final orders = _allOrders;
    // Top Products
    final productMap = <String, int>{};
    for (final order in orders) {
      final pname = order['PNAME']?.toString() ?? '';
      final q = int.tryParse(order['QNTY']?.toString() ?? '') ?? 0;
      if (pname.isNotEmpty) productMap[pname] = (productMap[pname] ?? 0) + q;
    }
    final topProducts = productMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Top Clients
    final clientMap = <String, int>{};
    for (final order in orders) {
      final client = order['CLIENTCODE']?.toString() ?? '';
      clientMap[client] = (clientMap[client] ?? 0) + 1;
    }
    final topClients = clientMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Top Booking Men
    final bmMap = <String, int>{};
    for (final order in orders) {
      final bm = order['BMCODE']?.toString() ?? '';
      bmMap[bm] = (bmMap[bm] ?? 0) + 1;
    }
    final topBMs = bmMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Date-wise summary
    final dateMap = <String, int>{};
    for (final order in orders) {
      final date = order['V_DATE']?.toString() ?? '';
      dateMap[date] = (dateMap[date] ?? 0) + 1;
    }
    final dateSummary = dateMap.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.insights, color: Colors.deepPurple, size: 28),
                    SizedBox(width: 12),
                    Text('Order Insights', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Top Products', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ...topProducts.take(5).map((e) => ListTile(
                  leading: const Icon(Icons.shopping_bag),
                  title: Text(e.key),
                  trailing: Text('Qty: ${e.value}'),
                )),
                const Divider(),
                Text('Top Clients', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ...topClients.take(5).map((e) => ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(e.key),
                  trailing: Text('Orders: ${e.value}'),
                )),
                const Divider(),
                Text('Top Booking Men', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ...topBMs.take(5).map((e) => ListTile(
                  leading: const Icon(Icons.badge),
                  title: Text(e.key),
                  trailing: Text('Orders: ${e.value}'),
                )),
                const Divider(),
                Text('Date-wise Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ...dateSummary.map((e) => ListTile(
                  leading: const Icon(Icons.calendar_today, size: 20),
                  title: Text(e.key),
                  trailing: Text('Orders: ${e.value}'),
                )),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (_allOrders.length / _pageSize).ceil();
    final start = _currentPage * _pageSize;
    final end = (_currentPage + 1) * _pageSize;
    final pageOrders = _allOrders.isNotEmpty ? _allOrders.sublist(start, end > _allOrders.length ? _allOrders.length : end) : [];

    // Calculate summary for filtered results (not all orders)
    int filteredTotalOrders = _allOrders.length;
    double filteredTotalAmount = 0;
    int filteredTotalQuantity = 0;
    for (final order in _allOrders) {
      final q = int.tryParse(order['QNTY']?.toString() ?? '') ?? 0;
      final a = double.tryParse(order['AMOUNT']?.toString() ?? '') ?? 0.0;
      filteredTotalQuantity += q;
      filteredTotalAmount += a;
    }
    // Optionally, calculate summary for current page
    int pageTotalOrders = pageOrders.length;
    double pageTotalAmount = 0;
    int pageTotalQuantity = 0;
    for (final order in pageOrders) {
      final q = int.tryParse(order['QNTY']?.toString() ?? '') ?? 0;
      final a = double.tryParse(order['AMOUNT']?.toString() ?? '') ?? 0.0;
      pageTotalQuantity += q;
      pageTotalAmount += a;
    }

    Widget summaryCard({required IconData icon, required String label, required String value, Color? color}) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color ?? Colors.blue, size: 32),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color ?? Colors.blue)),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // --- End Summary Section ---

    if (pageOrders.isEmpty) {
      return const Center(child: Text('No processed orders found.'));
    }
    final columns = pageOrders.first.keys.toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Processed Orders Report')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    child: TextField(
                      controller: _bmcodeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'BMCODE',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: TextField(
                      controller: _clientcodeController,
                      decoration: const InputDecoration(
                        labelText: 'CLIENTCODE',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 140,
                    child: OutlinedButton(
                      onPressed: () => _selectDate(context, true),
                      child: Text(_fromDate == null ? 'From Date' : DateFormat('dd-MMM-yyyy').format(_fromDate!)),
                    ),
                  ),
                  SizedBox(
                    width: 140,
                    child: OutlinedButton(
                      onPressed: () => _selectDate(context, false),
                      child: Text(_toDate == null ? 'To Date' : DateFormat('dd-MMM-yyyy').format(_toDate!)),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _applyFilters,
                    icon: const Icon(Icons.filter_alt),
                    label: const Text('Apply'),
                  ),
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
            if (_error != null)
              Center(child: Text('Error:  {_error}')),
            if (!_isLoading && _error == null && _allOrders.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.insights),
                    label: const Text('Insights'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onPressed: () => _showInsightsModal(context),
                  ),
                ),
              ),
            if (!_isLoading && _error == null && _allOrders.isNotEmpty)
              Column(
                children: [
                  // Table
                  Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          columns: columns
                              .map<DataColumn>((col) => DataColumn(label: Text(col, style: const TextStyle(fontWeight: FontWeight.bold))))
                              .toList(),
                          rows: pageOrders
                              .map<DataRow>((order) => DataRow(
                                    cells: columns
                                        .map<DataCell>((col) => DataCell(Text(order[col]?.toString() ?? '')))
                                        .toList(),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                  // --- Page Summary Row ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.spaceEvenly,
                      children: [
                        summaryCard(icon: Icons.list, label: 'Page Orders', value: pageTotalOrders.toString(), color: Colors.blueGrey),
                        summaryCard(icon: Icons.inventory, label: 'Page Quantity', value: pageTotalQuantity.toString(), color: Colors.deepOrange),
                        summaryCard(icon: Icons.monetization_on, label: 'Page Amount', value: pageTotalAmount.toStringAsFixed(2), color: Colors.teal),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: _currentPage > 0
                            ? () => setState(() => _currentPage--)
                            : null,
                      ),
                      Text('Page ${_currentPage + 1} of $totalPages'),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: _currentPage < totalPages - 1
                            ? () => setState(() => _currentPage++)
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            if (!_isLoading && _error == null && _allOrders.isEmpty)
              const Center(child: Text('No processed orders found.')),
          ],
        ),
      ),
    );
  }
} 