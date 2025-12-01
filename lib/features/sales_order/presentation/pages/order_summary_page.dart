import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

import '../../domain/entities/order_draft.dart';
import '../bloc/order_draft_bloc.dart';
import '../../../../injection_container.dart' as di;
import '../../../../core/widgets/location_tracker_widget.dart';
import '../../../../core/widgets/all_users_location_widget.dart';
import '../../../../core/widgets/booking_man_tracker_widget.dart';

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
  String? _currentUserId;



  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('user_name');
    setState(() {
      _currentUserId = username;
    });
    print('OrderSummaryPage - Loaded user: $_currentUserId');
  }

  void _extractClients() {
    // Extract clients from all orders (both posted and draft) based on selected period
    final now = DateTime.now();
    List<OrderDraft> filteredOrders = _allOrders;

    // Apply the same period filtering logic as in _calculateSummary
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

    final clients = filteredOrders.map((order) => order.clientName).toSet().toList();
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

    // Show all orders (both posted and draft) - removed filter for posted orders only
    // filteredOrders = filteredOrders.where((order) => order.isConfirmedForProcessing == true).toList();

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
    int postedOrderCount = 0;
    int draftOrderCount = 0;
    Map<String, int> clientOrderCount = {};
    Map<String, double> clientRevenue = {};

    for (var order in filteredOrders) {
      // Count posted vs draft orders
      if (order.isConfirmedForProcessing == true) {
        postedOrderCount++;
      } else {
        draftOrderCount++;
      }

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
        'postedOrders': postedOrderCount,
        'draftOrders': draftOrderCount,
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
              // Export CSV Button
              PopupMenuButton<String>(
                icon: const Icon(Icons.file_download),
                tooltip: 'Export to CSV',
                onSelected: (value) {
                  switch (value) {
                    case 'export_all':
                      _exportFilteredOrdersToCSV(context, false);
                      break;
                    case 'export_posted':
                      _exportFilteredOrdersToCSV(context, true);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'export_all',
                    child: Row(
                      children: [
                        Icon(Icons.file_download, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Export All Orders (${_selectedPeriod})'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'export_posted',
                    child: Row(
                      children: [
                        Icon(Icons.file_download, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Export Posted Only (${_selectedPeriod})'),
                      ],
                    ),
                  ),
                ],
              ),
              // Location Tracking Button - Only show for super users
              if (_currentUserId != null && _currentUserId == 'Shaniji')
                IconButton(
                  icon: const Icon(Icons.location_on),
                  onPressed: _showLocationTrackingDialog,
                  tooltip: 'Location Tracking',
                ),
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
                _extractClients();
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
          'Posted Orders',
          '${_summaryData['postedOrders'] ?? 0}',
          Icons.cloud_done,
          Colors.green,
        ),
        _buildStatCard(
          'Draft Orders',
          '${_summaryData['draftOrders'] ?? 0}',
          Icons.edit_note,
          Colors.orange,
        ),
        _buildStatCard(
          'Total Revenue',
          '${(_summaryData['totalGross'] ?? 0).toStringAsFixed(0)}',
          Icons.attach_money,
          Colors.purple,
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
                    const DataCell(Text('Posted Orders')),
                    DataCell(Text('${_summaryData['postedOrders'] ?? 0}')),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text('Draft Orders')),
                    DataCell(Text('${_summaryData['draftOrders'] ?? 0}')),
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
                  Icon(
                    order.isConfirmedForProcessing ? Icons.cloud_done : Icons.edit_note,
                    color: order.isConfirmedForProcessing ? Colors.green.shade600 : Colors.orange.shade600,
                    size: 20,
                  ),
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
                          '${order.items.length} items • ${order.totalAmount.toStringAsFixed(0)} • ${order.isConfirmedForProcessing ? "Posted" : "Draft"}',
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

  void _showLocationTrackingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.indigo.shade600,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Location Tracking',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo.shade700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      tooltip: 'Close',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Status indicator
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Location tracking active for user: $_currentUserId',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Location widgets
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Current user location
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.my_location,
                                      color: Colors.blue.shade600,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'My Location',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (_currentUserId != null)
                                  LocationTrackerWidget(userId: _currentUserId!),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // All users location
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.people,
                                      color: Colors.orange.shade600,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'All Users Location',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const AllUsersLocationWidget(),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Booking Man ID Tracker
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.track_changes,
                                      color: Colors.indigo.shade600,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Booking Man ID Tracker',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.indigo.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const BookingManTrackerWidget(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Export filtered orders to CSV based on selected period
  Future<void> _exportFilteredOrdersToCSV(BuildContext context, bool postedOnly) async {
    try {
      final filteredOrders = _summaryData['filteredOrders'] as List<OrderDraft>? ?? [];
      
      // Filter for posted orders only if requested
      final ordersToExport = postedOnly 
          ? filteredOrders.where((order) => order.isConfirmedForProcessing == true).toList()
          : filteredOrders;

      if (ordersToExport.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ℹ️ No ${postedOnly ? 'posted ' : ''}orders found for ${_selectedPeriod}'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }

      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('📊 Exporting ${postedOnly ? 'posted ' : ''}orders for ${_selectedPeriod} to CSV...'),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 2),
        ),
      );

      // Generate export data
      List<Map<String, dynamic>> exportData = [];
      
      for (final order in ordersToExport) {
        if (order.exportData != null && order.exportData!.isNotEmpty) {
          // Use saved export data from confirmation
          exportData.addAll(order.exportData!);
        } else {
          // Generate new export data (for draft orders)
          for (final item in order.items) {
            exportData.add({
              'bo_id': _generateUniqueBoId(),
              'bm_code': await _getBookingManId(),
              'client_code': order.clientId,
              'client_name': order.clientName,
              'product_code': item.productId,
              'product_name': item.productName,
              'quantity': item.quantity,
              'unit_price': item.unitPrice,
              'total_price': item.totalPrice,
              'discount': item.discount ?? 0,
              'order_date': DateFormat('yyyy-MM-dd').format(order.createdAt),
              'order_time': DateFormat('HH:mm:ss').format(order.createdAt),
              'status': order.isConfirmedForProcessing ? 'Posted' : 'Draft',
            });
          }
        }
      }

      // Create CSV content
      final csvContent = _createCSVContent(exportData);
      
      // Get app documents directory
      final appDocDir = await getApplicationDocumentsDirectory();
      final bbsdDir = Directory('${appDocDir.path}/BBSD');
      
      // Create BBSD directory if it doesn't exist
      if (!await bbsdDir.exists()) {
        await bbsdDir.create(recursive: true);
      }
      
      // Create filename based on period and type
      final periodName = _selectedPeriod == 'today' ? 'today' : 
                        _selectedPeriod == 'weekly' ? 'this_week' :
                        _selectedPeriod == 'monthly' ? 'this_month' : 'all_time';
      final typeName = postedOnly ? 'posted' : 'all';
      final fileName = '${typeName}_orders_${periodName}.csv';
      
      // Remove existing CSV file if it exists
      final csvFile = File('${bbsdDir.path}/$fileName');
      if (await csvFile.exists()) {
        await csvFile.delete();
      }
      
      // Create new CSV file
      await csvFile.writeAsString(csvContent);
      
      print('✅ CSV exported successfully: ${csvFile.path}');
      print('📊 Exported ${exportData.length} records for ${ordersToExport.length} orders');
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '✅ CSV exported successfully!',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('📁 Location: ${csvFile.path}'),
              Text('📊 ${exportData.length} records from ${ordersToExport.length} orders'),
              Text('📅 Period: ${_selectedPeriod}'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Share',
            onPressed: () => _shareCSVFile(csvFile),
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

  // Generate unique 8-digit BO ID
  int _generateUniqueBoId() {
    final random = DateTime.now().millisecondsSinceEpoch % 100000000;
    return 10000000 + random;
  }

  // Get booking man ID
  Future<String> _getBookingManId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id') ?? 'BM001';
  }

  // Create CSV content
  String _createCSVContent(List<Map<String, dynamic>> exportData) {
    if (exportData.isEmpty) return '';
    
    // Get headers from the first record
    final headers = exportData.first.keys.toList();
    
    // Create CSV content
    final csvBuffer = StringBuffer();
    
    // Add headers
    csvBuffer.writeln(headers.join(','));
    
    // Add data rows
    for (final record in exportData) {
      final row = headers.map((header) => record[header]?.toString() ?? '').join(',');
      csvBuffer.writeln(row);
    }
    
    return csvBuffer.toString();
  }

  // Share CSV file
  Future<void> _shareCSVFile(File csvFile) async {
    try {
      await Share.shareXFiles(
        [XFile(csvFile.path)],
        text: 'Order Summary CSV Export',
      );
    } catch (e) {
      print('Error sharing CSV file: $e');
    }
  }
} 