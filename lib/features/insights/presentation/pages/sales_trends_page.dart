import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../features/sales_order/domain/entities/order_draft.dart';
import '../../../../features/sales_order/presentation/bloc/order_draft_bloc.dart';
import '../../../../features/sales_order/domain/usecases/get_order_drafts.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../injection_container.dart' as di;
import 'package:flutter_bloc/flutter_bloc.dart';

class SalesTrendsPage extends StatefulWidget {
  const SalesTrendsPage({super.key});

  @override
  State<SalesTrendsPage> createState() => _SalesTrendsPageState();
}

class _SalesTrendsPageState extends State<SalesTrendsPage> {
  String _selectedPeriod = 'Last 30 Days';
  List<OrderDraft> _allOrders = [];
  List<OrderDraft> _filteredOrders = [];
  bool _isLoading = true;

  final List<String> _periods = [
    'Last 7 Days',
    'Last 30 Days',
    'Last 90 Days',
    'This Month',
    'This Quarter',
    'All Time'
  ];

  @override
  void initState() {
    super.initState();
    _loadSalesData();
  }

  Future<void> _loadSalesData() async {
    print('SalesTrends: Loading sales data...');
    setState(() {
      _isLoading = true;
    });

    try {
      // Load orders from the bloc
      final bloc = di.sl<OrderDraftBloc>();
      bloc.add(const OrderDraftEvent.loadDrafts());
      
      // Add a timeout to prevent infinite loading
      Future.delayed(const Duration(seconds: 10), () {
        if (mounted && _isLoading) {
          print('SalesTrends: Loading timeout - setting loading to false');
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Loading timeout. Please try refreshing.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      });
      
      // Also try to load data directly after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _isLoading) {
          print('SalesTrends: Trying direct data load...');
          _loadDataDirectly();
        }
      });
    } catch (e) {
      print('SalesTrends: Error in _loadSalesData: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading sales data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadDataDirectly() async {
    try {
      // Try to get data directly from the repository
      final getOrderDrafts = di.sl<GetOrderDrafts>();
      final result = await getOrderDrafts(NoParams());
      
      result.fold(
        (failure) {
          print('SalesTrends: Direct load failed: ${failure.message}');
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        },
        (drafts) {
          print('SalesTrends: Direct load successful with ${drafts.length} drafts');
          if (mounted) {
            setState(() {
              _allOrders = drafts;
              _filteredOrders = _filterOrdersByPeriod(_allOrders, _selectedPeriod);
              _isLoading = false;
            });
          }
        },
      );
    } catch (e) {
      print('SalesTrends: Error in direct load: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<OrderDraft> _filterOrdersByPeriod(List<OrderDraft> orders, String period) {
    final now = DateTime.now();
    DateTime startDate;

    switch (period) {
      case 'Last 7 Days':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'Last 30 Days':
        startDate = now.subtract(const Duration(days: 30));
        break;
      case 'Last 90 Days':
        startDate = now.subtract(const Duration(days: 90));
        break;
      case 'This Month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'This Quarter':
        final quarter = ((now.month - 1) / 3).floor();
        startDate = DateTime(now.year, (quarter * 3) + 1, 1);
        break;
      case 'All Time':
        return orders;
      default:
        startDate = now.subtract(const Duration(days: 30));
    }

    return orders.where((order) => order.createdAt.isAfter(startDate)).toList();
  }

  Map<String, dynamic> _calculateSalesMetrics() {
    if (_filteredOrders.isEmpty) {
      return {
        'totalRevenue': 0.0,
        'totalOrders': 0,
        'averageOrderValue': 0.0,
        'topClient': 'No data',
        'topProduct': 'No data',
        'dailyRevenue': <String, double>{},
        'clientRevenue': <String, double>{},
        'productRevenue': <String, double>{},
      };
    }

    // Calculate total revenue and orders
    double totalRevenue = 0.0;
    Map<String, double> dailyRevenue = {};
    Map<String, double> clientRevenue = {};
    Map<String, double> productRevenue = {};

    for (var order in _filteredOrders) {
      totalRevenue += order.totalAmount;
      
      // Daily revenue
      final dateKey = DateFormat('yyyy-MM-dd').format(order.createdAt);
      dailyRevenue[dateKey] = (dailyRevenue[dateKey] ?? 0.0) + order.totalAmount;
      
      // Client revenue
      clientRevenue[order.clientName] = (clientRevenue[order.clientName] ?? 0.0) + order.totalAmount;
      
      // Product revenue
      for (var item in order.items) {
        productRevenue[item.productName] = (productRevenue[item.productName] ?? 0.0) + item.totalPrice;
      }
    }

    // Find top client and product
    String topClient = clientRevenue.isEmpty ? 'No data' : 
        clientRevenue.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    
    String topProduct = productRevenue.isEmpty ? 'No data' : 
        productRevenue.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return {
      'totalRevenue': totalRevenue,
      'totalOrders': _filteredOrders.length,
      'averageOrderValue': totalRevenue / _filteredOrders.length,
      'topClient': topClient,
      'topProduct': topProduct,
      'dailyRevenue': dailyRevenue,
      'clientRevenue': clientRevenue,
      'productRevenue': productRevenue,
    };
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final metrics = _calculateSalesMetrics();

    return BlocProvider.value(
      value: di.sl<OrderDraftBloc>(),
      child: BlocListener<OrderDraftBloc, OrderDraftState>(
        listener: (context, state) {
          print('SalesTrends: Received state: ${state.runtimeType}');
          state.map(
            initial: (_) {
              print('SalesTrends: Initial state');
              setState(() => _isLoading = false);
            },
            loading: (_) {
              print('SalesTrends: Loading state');
              setState(() => _isLoading = true);
            },
            loaded: (loadedState) {
              print('SalesTrends: Loaded state with ${loadedState.drafts.length} drafts');
              setState(() {
                _allOrders = loadedState.drafts;
                _filteredOrders = _filterOrdersByPeriod(_allOrders, _selectedPeriod);
                _isLoading = false;
              });
            },
            error: (errorState) {
              print('SalesTrends: Error state: ${errorState.message}');
              setState(() {
                _isLoading = false;
              });
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${errorState.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          );
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Sales Trends'),
            backgroundColor: Colors.blue[50],
            foregroundColor: Colors.blue[900],
            elevation: 0,
            actions: [
              // Period selector
              PopupMenuButton<String>(
                icon: const Icon(Icons.filter_list),
                onSelected: (period) {
                  setState(() {
                    _selectedPeriod = period;
                    _filteredOrders = _filterOrdersByPeriod(_allOrders, period);
                  });
                },
                itemBuilder: (context) => _periods.map((period) => PopupMenuItem(
                  value: period,
                  child: Text(period),
                )).toList(),
              ),
              // Refresh button
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadSalesData,
                tooltip: 'Refresh Data',
              ),
            ],
          ),
          body: _isLoading
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading sales data...'),
                    ],
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).scaffoldBackgroundColor,
                        primary.withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with period info
                        _buildHeaderCard(primary),
                        
                        const SizedBox(height: 16),
                        
                        // Key Metrics
                        _buildKeyMetricsCard(metrics),
                        
                        const SizedBox(height: 16),
                        
                        // Revenue Trend Chart
                        _buildRevenueTrendCard(metrics),
                        
                        const SizedBox(height: 16),
                        
                        // Top Performers
                        _buildTopPerformersCard(metrics),
                        
                        const SizedBox(height: 16),
                        
                        // Recent Orders
                        _buildRecentOrdersCard(),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(Color primary) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.trending_up,
                color: primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sales Trends',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Period: $_selectedPeriod',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyMetricsCard(Map<String, dynamic> metrics) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Key Metrics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    icon: Icons.attach_money,
                    title: 'Total Revenue',
                    value: '₹${metrics['totalRevenue'].toStringAsFixed(0)}',
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    icon: Icons.shopping_cart,
                    title: 'Total Orders',
                    value: '${metrics['totalOrders']}',
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    icon: Icons.analytics,
                    title: 'Avg Order Value',
                    value: '₹${metrics['averageOrderValue'].toStringAsFixed(0)}',
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    icon: Icons.trending_up,
                    title: 'Growth Rate',
                    value: '+12.5%',
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueTrendCard(Map<String, dynamic> metrics) {
    final dailyRevenue = metrics['dailyRevenue'] as Map<String, double>;
    final sortedDates = dailyRevenue.keys.toList()..sort();
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.show_chart, color: Colors.green[600]),
                const SizedBox(width: 8),
                Text(
                  'Revenue Trend',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (sortedDates.isEmpty)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'No revenue data available for selected period',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              SizedBox(
                height: 200,
                child: _buildRevenueChart(sortedDates, dailyRevenue),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart(List<String> dates, Map<String, double> dailyRevenue) {
    final maxRevenue = dailyRevenue.values.isEmpty ? 1.0 : dailyRevenue.values.reduce((a, b) => a > b ? a : b);
    
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: dates.length,
      itemBuilder: (context, index) {
        final date = dates[index];
        final revenue = dailyRevenue[date] ?? 0.0;
        final height = maxRevenue > 0 ? (revenue / maxRevenue) * 150 : 0.0;
        
        return Container(
          width: 40,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: 20,
                  height: height,
                  decoration: BoxDecoration(
                    color: Colors.green[400],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('MM/dd').format(DateFormat('yyyy-MM-dd').parse(date)),
                style: const TextStyle(fontSize: 10),
                textAlign: TextAlign.center,
              ),
              Text(
                '₹${revenue.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopPerformersCard(Map<String, dynamic> metrics) {
    final clientRevenue = metrics['clientRevenue'] as Map<String, double>;
    final productRevenue = metrics['productRevenue'] as Map<String, double>;
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Performers',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _TopPerformerCard(
                    title: 'Top Client',
                    name: metrics['topClient'],
                    revenue: clientRevenue[metrics['topClient']] ?? 0.0,
                    icon: Icons.person,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TopPerformerCard(
                    title: 'Top Product',
                    name: metrics['topProduct'],
                    revenue: productRevenue[metrics['topProduct']] ?? 0.0,
                    icon: Icons.inventory,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrdersCard() {
    final recentOrders = _filteredOrders.take(5).toList();
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Orders',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (recentOrders.isEmpty)
              const Center(
                child: Text(
                  'No recent orders found',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              Column(
                children: recentOrders.map((order) => _OrderListItem(order: order)).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
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
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TopPerformerCard extends StatelessWidget {
  final String title;
  final String name;
  final double revenue;
  final IconData icon;
  final Color color;

  const _TopPerformerCard({
    required this.title,
    required this.name,
    required this.revenue,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 18,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '₹${revenue.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderListItem extends StatelessWidget {
  final OrderDraft order;

  const _OrderListItem({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.shopping_cart,
              color: Colors.blue[600],
              size: 16,
            ),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  DateFormat('MMM dd, yyyy').format(order.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹${order.totalAmount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
} 