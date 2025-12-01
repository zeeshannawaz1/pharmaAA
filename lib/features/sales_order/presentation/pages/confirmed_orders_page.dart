import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ConfirmedOrdersPage extends StatefulWidget {
  const ConfirmedOrdersPage({Key? key}) : super(key: key);

  @override
  State<ConfirmedOrdersPage> createState() => _ConfirmedOrdersPageState();
}

class _ConfirmedOrdersPageState extends State<ConfirmedOrdersPage> {
  late Future<List<Map<String, dynamic>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = fetchConfirmedOrders();
  }

  Future<List<Map<String, dynamic>>> fetchConfirmedOrders() async {
    try {
      final url = Uri.parse('http://137.59.224.222:8080/zee_order_confirmed.php');
      final response = await http.get(url);
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
      
      final decoded = json.decode(response.body);
      print('Decoded response: $decoded');
      
      if (decoded is Map<String, dynamic>) {
        // Handle the expected format: {"status": "success", "count": X, "orders": [...]}
        if (decoded['status'] == 'success' && decoded['orders'] is List) {
          final orders = decoded['orders'] as List;
          print('Found ${orders.length} orders in response');
          return orders.cast<Map<String, dynamic>>();
        } else if (decoded['status'] == 'error') {
          throw Exception('Server error: ${decoded['message'] ?? 'Unknown error'}');
        } else {
          // Fallback: try to find any list in the response
          final listValue = decoded.values.firstWhere(
            (v) => v is List,
            orElse: () => null,
          );
          if (listValue != null && listValue is List) {
            return listValue.cast<Map<String, dynamic>>();
          }
        }
      } else if (decoded is List) {
        // Direct list response
        return decoded.cast<Map<String, dynamic>>();
      }
      
      throw Exception('Unexpected response format: ${decoded.runtimeType}');
    } catch (e) {
      print('Error fetching confirmed orders: $e');
      rethrow;
    }
  }

  void _refresh() {
    setState(() {
      _ordersFuture = fetchConfirmedOrders();
    });
  }

  Future<void> _exportToCSV() async {
    try {
      final orders = await _ordersFuture;
      
      if (orders.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No orders to export'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('📊 Exporting ${orders.length} orders to CSV...'),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 2),
        ),
      );

      // Create CSV content
      final csvContent = _createCSVContent(orders);
      
      // Get app documents directory
      final appDocDir = await getApplicationDocumentsDirectory();
      final bbsdDir = Directory('${appDocDir.path}/BBSD');
      
      // Create BBSD directory if it doesn't exist
      if (!await bbsdDir.exists()) {
        await bbsdDir.create(recursive: true);
      }
      
      // Create CSV file with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final csvFile = File('${bbsdDir.path}/confirmed_orders_$timestamp.csv');
      
      // Write CSV content
      await csvFile.writeAsString(csvContent);
      print('✅ Created CSV file: ${csvFile.path}');
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '✅ CSV exported successfully!',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('📁 Location: ${csvFile.path}'),
              Text('📊 ${orders.length} orders exported'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 6),
          action: SnackBarAction(
            label: 'View File',
            onPressed: () => _showFileInfo(csvFile.path, orders.length),
          ),
        ),
      );
      
    } catch (e) {
      print('Error exporting CSV: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error exporting CSV: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  String _createCSVContent(List<Map<String, dynamic>> orders) {
    // CSV header
    final header = 'Order Reference,Client Code,Product Name,Quantity,Amount,Date,BO ID\n';
    
    // CSV rows
    final rows = orders.map((order) {
      return '"${order['ORDER_REFRENCE'] ?? order['ORDNO'] ?? 'N/A'}",'
             '"${order['CLIENTCODE'] ?? order['ClientCode'] ?? 'N/A'}",'
             '"${order['PNAME'] ?? order['PName'] ?? 'N/A'}",'
             '${order['QNTY'] ?? order['Qnty'] ?? 'N/A'},'
             '${order['AMOUNT'] ?? order['Amount'] ?? 'N/A'},'
             '"${order['V_DATE'] ?? 'N/A'}",'
             '${order['BO_ID'] ?? order['id'] ?? 'N/A'}';
    }).join('\n');
    
    return header + rows;
  }

  void _showFileInfo(String filePath, int orderCount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('CSV Export Complete'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('✅ Successfully exported $orderCount orders'),
            const SizedBox(height: 8),
            Text('📁 File location:'),
            Text(filePath, style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
            const SizedBox(height: 8),
            const Text('You can find this file in your device\'s documents folder.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmed Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _exportToCSV,
            tooltip: 'Export to CSV',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading orders',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refresh,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, color: Colors.grey, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'No confirmed orders found',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Orders will appear here once they are confirmed and posted to the server.',
                    style: TextStyle(color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refresh,
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }
          
          final orders = snapshot.data!;
          return ListView.separated(
            itemCount: orders.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, i) {
              final order = orders[i];
              return ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text('Order Ref: ${order['ORDER_REFRENCE'] ?? order['ORDNO'] ?? 'N/A'}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Client: ${order['CLIENTCODE'] ?? order['ClientCode'] ?? 'N/A'}'),
                    Text('Product: ${order['PNAME'] ?? order['PName'] ?? 'N/A'}'),
                    Text('Qty: ${order['QNTY'] ?? order['Qnty'] ?? 'N/A'}'),
                    Text('Amount: ${order['AMOUNT'] ?? order['Amount'] ?? 'N/A'}'),
                  ],
                ),
                trailing: Text(order['BO_ID']?.toString() ?? order['id']?.toString() ?? ''),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }
} 