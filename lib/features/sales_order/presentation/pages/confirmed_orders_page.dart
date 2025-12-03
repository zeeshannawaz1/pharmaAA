import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../main_screen.dart';

class ConfirmedOrdersPage extends StatefulWidget {
  const ConfirmedOrdersPage({super.key});

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
    final url = Uri.parse('http://137.59.224.222:8080/zee_order_confirmed.php');
    final response = await http.get(url);
    print('Response body: ${response.body}'); // Debug print
    final decoded = json.decode(response.body);
    if (decoded is List) {
      return decoded.cast<Map<String, dynamic>>();
    } else if (decoded is Map) {
      // Try to find the first list value in the map
      final listValue = decoded.values.firstWhere(
        (v) => v is List,
        orElse: () => null,
      );
      if (listValue != null && listValue is List) {
        return listValue.cast<Map<String, dynamic>>();
      } else {
        // If no list, wrap the map itself
        return [decoded.cast<String, dynamic>()];
      }
    } else {
      throw Exception('Unexpected response format');
    }
  }

  void _refresh() {
    setState(() {
      _ordersFuture = fetchConfirmedOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmed Orders'),
        actions: [
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
              child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No confirmed orders found.'));
          }
          final orders = snapshot.data!;
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
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
                ),
              ),
              const BannerAdWidget(),
            ],
          );
        },
      ),
    );
  }
} 