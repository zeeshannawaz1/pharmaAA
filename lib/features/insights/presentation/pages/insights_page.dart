import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'sales_trends_page.dart';
import '../../../../features/sales_order/domain/entities/order_draft.dart';
import '../../../../features/sales_order/domain/usecases/get_order_drafts.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../injection_container.dart' as di;

class InsightsPage extends StatefulWidget {
  const InsightsPage({Key? key}) : super(key: key);

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  String _selectedPeriod = 'Last 30 Days';
  String _selectedFilter = 'All Orders';
  bool _isLoading = false;
  List<OrderDraft> _allOrders = [];
  Map<String, dynamic> _stats = {
    'totalOrders': 0,
    'totalRevenue': 0.0,
    'totalClients': 0,
    'totalProducts': 0,
  };

  final List<String> _periods = [
    'Last 7 Days',
    'Last 30 Days', 
    'Last 90 Days',
    'This Month',
    'This Quarter',
    'Custom Range'
  ];

  final List<String> _filters = [
    'All Orders',
    'Draft Orders',
    'Confirmed Orders',
    'Posted Orders',
    'High Value (>₹10,000)',
    'Low Value (<₹1,000)'
  ];

  @override
  void initState() {
    super.initState();
    _loadInsightsData();
  }

  Future<void> _loadInsightsData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final getOrderDrafts = di.sl<GetOrderDrafts>();
      final result = await getOrderDrafts(NoParams());
      
      result.fold(
        (failure) {
          print('Insights: Failed to load data: ${failure.message}');
          setState(() {
            _isLoading = false;
          });
        },
        (orders) {
          print('Insights: Loaded ${orders.length} orders');
          _calculateStats(orders);
          setState(() {
            _allOrders = orders;
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      print('Insights: Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _calculateStats(List<OrderDraft> orders) {
    final totalOrders = orders.length;
    final totalRevenue = orders.fold(0.0, (sum, order) => sum + order.totalAmount);
    final uniqueClients = orders.map((order) => order.clientName).toSet().length;
    final allProducts = <String>{};
    
    for (var order in orders) {
      for (var item in order.items) {
        allProducts.add(item.productName);
      }
    }
    
    final totalProducts = allProducts.length;
    
    setState(() {
      _stats = {
        'totalOrders': totalOrders,
        'totalRevenue': totalRevenue,
        'totalClients': uniqueClients,
        'totalProducts': totalProducts,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
        backgroundColor: Colors.blue[50],
        foregroundColor: Colors.blue[900],
        elevation: 0,
        actions: [
          // Filter Button
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
            tooltip: 'Filter Data',
          ),
          // Export Button
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _showExportDialog(context),
            tooltip: 'Export Data',
          ),
          // Refresh Button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadInsightsData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Refreshing insights data...'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            tooltip: 'Refresh Insights',
          ),
        ],
      ),
      body: Container(
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
        child: _isLoading 
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading insights data...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  _buildHeaderCard(primary),
                  
                  const SizedBox(height: 16),
                  
                  // Data Integration Section
                  _buildDataIntegrationSection(),
                  
                  const SizedBox(height: 16),
                  
                  // Charts & Analytics Section
                  _buildChartsAnalyticsSection(),
                  
                  const SizedBox(height: 16),
                  
                  // Export & Filter Section
                  _buildExportFilterSection(),
                  
                  const SizedBox(height: 16),
                  
                  // Quick Stats
                  _buildQuickStatsSection(),
                  
                  const SizedBox(height: 16),
                  
                  // Recent Activity
                  _buildRecentActivitySection(),
                  
                  const SizedBox(height: 16),
                  
                  // Action Buttons
                  _buildActionButtons(),
                ],
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.analytics,
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
                        'Business Insights',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Period: $_selectedPeriod | Filter: $_selectedFilter',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataIntegrationSection() {
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
                Icon(Icons.data_usage, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Text(
                  'Data Integration',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.sync,
                    label: 'Sync Orders',
                    onTap: () => _showDataSyncDialog(),
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.history,
                    label: 'Load History',
                    onTap: () => _showLoadHistoryDialog(),
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.update,
                    label: 'Update Analytics',
                    onTap: () => _showUpdateAnalyticsDialog(),
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.backup,
                    label: 'Backup Data',
                    onTap: () => _showBackupDialog(),
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

  Widget _buildChartsAnalyticsSection() {
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
                Icon(Icons.bar_chart, color: Colors.green[600]),
                const SizedBox(width: 8),
                Text(
                  'Charts & Analytics',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.trending_up,
                    label: 'Sales Trends',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SalesTrendsPage(),
                        ),
                      );
                    },
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.pie_chart,
                    label: 'Revenue Chart',
                    onTap: () => _showRevenueChartDialog(),
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.people,
                    label: 'Customer Analytics',
                    onTap: () => _showCustomerAnalyticsDialog(),
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.inventory,
                    label: 'Product Performance',
                    onTap: () => _showProductPerformanceDialog(),
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

  Widget _buildExportFilterSection() {
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
                Icon(Icons.file_download, color: Colors.orange[600]),
                const SizedBox(width: 8),
                Text(
                  'Export & Filter',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.picture_as_pdf,
                    label: 'Export PDF',
                    onTap: () => _showExportPDFDialog(),
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.table_chart,
                    label: 'Export Excel',
                    onTap: () => _showExportExcelDialog(),
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.search,
                    label: 'Advanced Search',
                    onTap: () => _showAdvancedSearchDialog(),
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.filter_alt,
                    label: 'Custom Filters',
                    onTap: () => _showCustomFiltersDialog(),
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

  Widget _buildQuickStatsSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Stats',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.shopping_cart,
                    title: 'Total Orders',
                    value: '${_stats['totalOrders']}',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.attach_money,
                    title: 'Revenue',
                    value: '₹${_stats['totalRevenue'].toStringAsFixed(0)}',
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.people,
                    title: 'Clients',
                    value: '${_stats['totalClients']}',
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.inventory,
                    title: 'Products',
                    value: '${_stats['totalProducts']}',
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

  Widget _buildRecentActivitySection() {
    final recentOrders = _allOrders.take(3).toList();
    
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
                Icon(Icons.history, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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
                children: recentOrders.map((order) => _RecentOrderItem(order: order)).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.analytics,
                    label: 'Generate Report',
                    onTap: () => _showGenerateReportDialog(),
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.share,
                    label: 'Share Insights',
                    onTap: () => _showShareInsightsDialog(),
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

  // Dialog Methods
  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedPeriod,
              decoration: const InputDecoration(labelText: 'Time Period'),
              items: _periods.map((period) => DropdownMenuItem(
                value: period,
                child: Text(period),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPeriod = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedFilter,
              decoration: const InputDecoration(labelText: 'Filter Type'),
              items: _filters.map((filter) => DropdownMenuItem(
                value: filter,
                child: Text(filter),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filters applied successfully!')),
              );
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text('Choose export format and data range.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export started...')),
              );
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  // Placeholder dialog methods for all action buttons
  void _showDataSyncDialog() => _showFeatureDialog('Data Sync');
  void _showLoadHistoryDialog() => _showFeatureDialog('Load History');
  void _showUpdateAnalyticsDialog() => _showFeatureDialog('Update Analytics');
  void _showBackupDialog() => _showFeatureDialog('Backup Data');
  void _showSalesTrendsDialog() => _showFeatureDialog('Sales Trends');
  void _showRevenueChartDialog() => _showFeatureDialog('Revenue Chart');
  void _showCustomerAnalyticsDialog() => _showFeatureDialog('Customer Analytics');
  void _showProductPerformanceDialog() => _showFeatureDialog('Product Performance');
  void _showExportPDFDialog() => _showFeatureDialog('Export PDF');
  void _showExportExcelDialog() => _showFeatureDialog('Export Excel');
  void _showAdvancedSearchDialog() => _showFeatureDialog('Advanced Search');
  void _showCustomFiltersDialog() => _showFeatureDialog('Custom Filters');
  void _showGenerateReportDialog() => _showFeatureDialog('Generate Report');
  void _showShareInsightsDialog() => _showFeatureDialog('Share Insights');

  void _showFeatureDialog(String featureName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$featureName'),
        content: Text('$featureName feature is coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentOrderItem extends StatelessWidget {
  final OrderDraft order;

  const _RecentOrderItem({required this.order});

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
                  '${order.items.length} items • ₹${order.totalAmount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            DateFormat('MMM dd').format(order.createdAt),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
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