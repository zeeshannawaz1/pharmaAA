import 'package:flutter/material.dart';
import 'dart:math';
import 'new_order_form_page.dart';

class DailyOrderBookingPage extends StatefulWidget {
  const DailyOrderBookingPage({Key? key}) : super(key: key);

  @override
  State<DailyOrderBookingPage> createState() => _DailyOrderBookingPageState();
}

class _DailyOrderBookingPageState extends State<DailyOrderBookingPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<Map<String, dynamic>> _dummyOrders = List.generate(3, (i) => {
    'client': 'Client ${i + 1}',
    'date': DateTime.now().subtract(Duration(days: i)),
    'items': List.generate(Random().nextInt(3) + 1, (j) => {
      'product': 'Product ${j + 1}',
      'qty': Random().nextInt(10) + 1,
      'price': (Random().nextDouble() * 100).toStringAsFixed(2),
    })
  });

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                  'SRC-9',
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
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NewOrderFormPage()),
              );
            },
            tooltip: 'Add New Order',
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Opacity(
            opacity: _animation.value,
            child: Transform.translate(
              offset: Offset(0, 40 * (1 - _animation.value)),
              child: child,
            ),
          );
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [Colors.blue.shade300, Colors.blue.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade100,
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Opacity(
                      opacity: 0.2,
                      child: Image.asset(
                        'assets/order_graphic.png',
                        width: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.shopping_bag, size: 100, color: Colors.white24),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('Book Your Daily Orders', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('Quickly create and manage daily sales orders with ease.', style: TextStyle(color: Colors.white70, fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ..._dummyOrders.map((order) => Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: const Icon(Icons.person, color: Colors.blue),
                ),
                title: Text(order['client'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Date: ${order['date'].toString().split(' ')[0]}'),
                children: [
                  ...order['items'].map<Widget>((item) => ListTile(
                    leading: const Icon(Icons.shopping_cart_outlined),
                    title: Text(item['product']),
                    subtitle: Text('Qty: ${item['qty']}  |  Price: ${item['price']}'),
                  )),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        label: const Text('Edit'),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text('Delete'),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NewOrderFormPage()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Order'),
      ),
    );
  }
} 
