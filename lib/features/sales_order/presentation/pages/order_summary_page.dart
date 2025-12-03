import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/order_draft.dart';
import '../bloc/order_draft_bloc.dart';
import '../../../../injection_container.dart' as di;

class OrderSummaryPage extends StatefulWidget {
  const OrderSummaryPage({super.key});

  @override
  State<OrderSummaryPage> createState() => _OrderSummaryPageState();
}

class _OrderSummaryPageState extends State<OrderSummaryPage> {
  String _selectedPeriod = 'today';
  String? _selectedClient;
  List<String> _availableClients = [];
  List<OrderDraft> _allOrders = [];
  Map<String, dynamic> _summaryData = {};



  void _extractClients() {
    // Only extract clients from posted/confirmed orders
    final postedOrders = _allOrders.where((order) => order.isConfirmedForProcessing == true).toList();
    final clients = postedOrders.map((order) => order.clientName).toSet().toList();
    clients.sort();
    setState(() {
      _availableClients = clients;
    });
  }

  void _calculateSummary() {
    final now = DateTime.now();
    List<OrderDraft> filteredOrders = _allOrders;

    // Filter by client if selected
    if (_selectedClient != null) {
      filteredOrders = filteredOrders.where((order) => order.clientName == _selectedClient).toList();
    }

    // Filter to only show posted/confirmed orders
    filteredOrders = filteredOrders.where((order) => order.isConfirmedForProcessing == true).toList();

    // Filter by period
    switch (_selectedPeriod) {
      case 'today':
        filteredOrders = filteredOrders.where((order) {
          return order.createdAt.year == now.year &&
                 order.createdAt.month == now.month &&
                 order.createdAt.day == now.day;
        }).toList();
        break;
      case 'weekly':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        filteredOrders = filteredOrders.where((order) {
          return order.createdAt.isAfter(weekStart.subtract(const Duration(days: 1)));
        }).toList();
        break;
      case 'monthly':
        final monthStart = DateTime(now.year, now.month, 1);
        filteredOrders = filteredOrders.where((order) {
          return order.createdAt.isAfter(monthStart.subtract(const Duration(days: 1)));
        }).toList();
        break;
      case 'all':
        // No date filtering
        break;
    }

    // Calculate summary
    double totalGross = 0;
    double totalNet = 0;
    double totalSubTotal = 0;
    double totalDiscount = 0;
    int orderCount = filteredOrders.length;
    Map<String, int> clientOrderCount = {};
    Map<String, double> clientRevenue = {};

    for (var order in filteredOrders) {
      // Client statistics
      clientOrderCount[order.clientName] = (clientOrderCount[order.clientName] ?? 0) + 1;
      clientRevenue[order.clientName] = (clientRevenue[order.clientName] ?? 0) + order.totalAmount;

      double orderDiscount = 0;
      double orderSubTotal = 0;
      for (var item in order.items) {
        final dis = item.discount ?? 0;
        final itemSubTotal = (item.totalPrice / 100) * (100 - dis);
        orderSubTotal += itemSubTotal;
        orderDiscount += (item.totalPrice - itemSubTotal);
      }
      totalGross += order.totalAmount;
      totalNet += order.totalAmount - orderDiscount;
      totalSubTotal += orderSubTotal;
      totalDiscount += orderDiscount;
    }

    setState(() {
      _summaryData = {
        'totalOrders': orderCount,
        'totalGross': totalGross,
        'totalNet': totalNet,
        'totalSubTotal': totalSubTotal,
        'totalDiscount': totalDiscount,
        'clientOrderCount': clientOrderCount,
        'clientRevenue': clientRevenue,
        'filteredOrders': filteredOrders,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<OrderDraftBloc>()..add(const OrderDraftEvent.loadDrafts()),
      child: BlocListener<OrderDraftBloc, OrderDraftState>(
        listener: (context, state) {
          state.map(
            initial: (_) => null,
            loading: (_) => null,
            loaded: (loadedState) {
              setState(() {
                _allOrders = loadedState.drafts;
                _extractClients();
                _calculateSummary();
              });
            },
            error: (_) => null,
          );
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Order Summary'),
            backgroundColor: Colors.indigo.shade600,
            foregroundColor: Colors.white,
            elevation: 2,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  context.read<OrderDraftBloc>().add(const OrderDraftEvent.loadDrafts());
                },
                tooltip: 'Refresh Data',
              ),
            ],
          ),
          body: Column(
            children: [
              _buildFilterSection(),
              Expanded(
                child: _buildSummaryContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Options',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.indigo.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPeriodSelector(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildClientSelector(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Period',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.indigo.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: DropdownButton<String>(
            value: _selectedPeriod,
            isExpanded: true,
            underline: const SizedBox(),
            icon: Icon(Icons.arrow_drop_down, color: Colors.indigo.shade600),
            items: [
              DropdownMenuItem(
                value: 'today',
                child: Row(
                  children: [
                    Icon(Icons.today, size: 16, color: Colors.green.shade600),
                    const SizedBox(width: 8),
                    const Text('Today'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'weekly',
                child: Row(
                  children: [
                    Icon(Icons.view_week, size: 16, color: Colors.blue.shade600),
                    const SizedBox(width: 8),
                    const Text('This Week'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'monthly',
                child: Row(
                  children: [
                    Icon(Icons.calendar_month, size: 16, color: Colors.orange.shade600),
                    const SizedBox(width: 8),
                    const Text('This Month'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    Icon(Icons.all_inclusive, size: 16, color: Colors.purple.shade600),
                    const SizedBox(width: 8),
                    const Text('All Time'),
                  ],
                ),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedPeriod = value!;
                _calculateSummary();
              });
            },
            dropdownColor: Colors.white,
            elevation: 4,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClientSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Client',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.indigo.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: DropdownButton<String?>(
            value: _selectedClient,
            isExpanded: true,
            underline: const SizedBox(),
            icon: Icon(Icons.arrow_drop_down, color: Colors.indigo.shade600),
            hint: Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  'All Clients',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Row(
                  children: [
                    Icon(Icons.people, size: 16, color: Colors.indigo.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'All Clients',
                      style: TextStyle(
                        color: Colors.indigo.shade600,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              ..._availableClients.map((client) => DropdownMenuItem(
                value: client,
                child: Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        client,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )),
            ],
            onChanged: (value) {
              setState(() {
                _selectedClient = value;
                _calculateSummary();
              });
            },
            dropdownColor: Colors.white,
            elevation: 4,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            _buildOverviewCards(),
          const SizedBox(height: 24),
          _buildSummaryTable(),
          const SizedBox(height: 24),
          _buildRecentOrders(),
        ],
      ),
    );
  }

  Widget _buildOverviewCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Total Orders',
          '${_summaryData['totalOrders'] ?? 0}',
          Icons.shopping_cart,
          Colors.blue,
        ),
        _buildStatCard(
          'Total Revenue',
          '${(_summaryData['totalGross'] ?? 0).toStringAsFixed(0)}',
          Icons.attach_money,
          Colors.green,
        ),
        _buildStatCard(
          'Total Net',
          '${(_summaryData['totalNet'] ?? 0).toStringAsFixed(0)}',
          Icons.account_balance_wallet,
          Colors.orange,
        ),
        _buildStatCard(
          'Total Discount',
          '${(_summaryData['totalDiscount'] ?? 0).toStringAsFixed(0)}',
          Icons.discount,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryTable() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Summary Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 16,
                headingRowHeight: 40,
                dataRowHeight: 40,
                columns: const [
                  DataColumn(label: Text('Metric')),
                  DataColumn(label: Text('Value')),
                ],
                rows: [
                  DataRow(cells: [
                    const DataCell(Text('Total Orders')),
                    DataCell(Text('${_summaryData['totalOrders'] ?? 0}')),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text('Gross Amount')),
                    DataCell(Text('${(_summaryData['totalGross'] ?? 0).toStringAsFixed(0)}')),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text('Net Amount')),
                    DataCell(Text('${(_summaryData['totalNet'] ?? 0).toStringAsFixed(0)}')),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text('Sub Total')),
                    DataCell(Text('${(_summaryData['totalSubTotal'] ?? 0).toStringAsFixed(0)}')),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text('Total Discount')),
                    DataCell(Text('${(_summaryData['totalDiscount'] ?? 0).toStringAsFixed(0)}')),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildRecentOrders() {
    final filteredOrders = _summaryData['filteredOrders'] as List<OrderDraft>? ?? [];
    
    if (filteredOrders.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get last 5 orders
    final recentOrders = filteredOrders.take(5).toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Orders',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...recentOrders.map((order) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.shopping_bag, color: Colors.blue.shade600, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.clientName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${order.items.length} items • ${order.totalAmount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    DateFormat('MMM dd').format(order.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }




} 