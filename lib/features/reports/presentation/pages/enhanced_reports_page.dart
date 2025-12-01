import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/daily_report.dart';
import '../../data/models/dummy_reports.dart';
import '../bloc/daily_report_bloc.dart';
import '../bloc/daily_report_event.dart';
import '../bloc/daily_report_state.dart';
import '../../domain/usecases/get_daily_reports.dart';
import '../../data/repositories/daily_report_repository_impl.dart';
import '../../data/datasources/daily_report_remote_data_source.dart';
import 'widgets/report_summary_card.dart';
import 'widgets/report_chart_widget.dart';
import 'widgets/report_details_modal.dart';
import 'widgets/category_performance_widget.dart';
import 'widgets/top_products_widget.dart';

class EnhancedReportsPage extends StatefulWidget {
  const EnhancedReportsPage({Key? key}) : super(key: key);

  @override
  State<EnhancedReportsPage> createState() => _EnhancedReportsPageState();
}

class _EnhancedReportsPageState extends State<EnhancedReportsPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  bool _useDummyData = false;
  String _selectedPeriod = 'Last 10 Days';
  String _selectedReportType = 'Sales Overview';
  
  final List<String> _periods = [
    'Last 7 Days',
    'Last 10 Days',
    'Last 30 Days',
    'Last 90 Days',
    'This Month',
    'This Quarter',
  ];
  
  final List<String> _reportTypes = [
    'Sales Overview',
    'Product Performance',
    'Category Analysis',
    'Customer Insights',
    'Financial Summary',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showReportDetails(DailyReport report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReportDetailsModal(report: report),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Enhanced Reports'),
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
                  'R-2',
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
            icon: Icon(_useDummyData ? Icons.cloud_done : Icons.cloud_off),
            onPressed: () {
              setState(() {
                _useDummyData = !_useDummyData;
              });
            },
            tooltip: _useDummyData ? 'Using Dummy Data' : 'Using Real API',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterOptions();
            },
            tooltip: 'Filter Options',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Filter Section
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Data Source Indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _useDummyData 
                            ? Colors.green.shade100 
                            : Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _useDummyData 
                              ? Colors.green.shade300 
                              : Colors.blue.shade300,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _useDummyData ? Icons.cloud_done : Icons.cloud_off,
                            size: 16,
                            color: _useDummyData ? Colors.green : Colors.blue,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _useDummyData ? 'Dummy Data' : 'Real API',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _useDummyData ? Colors.green : Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Filter Controls
                    Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _selectedPeriod,
                          decoration: InputDecoration(
                            labelText: 'Period',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: _periods.map((period) {
                            return DropdownMenuItem(value: period, child: Text(period));
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedPeriod = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedReportType,
                          decoration: InputDecoration(
                            labelText: 'Report Type',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: _reportTypes.map((type) {
                            return DropdownMenuItem(value: type, child: Text(type));
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedReportType = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Reports Content
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _useDummyData
                      ? _buildDummyDataContent()
                      : _buildRealApiContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDummyDataContent() {
    final reports = DummyReports.getReports();
    final summaryStats = DummyReports.getSummaryStats();
    final chartData = DummyReports.getChartData();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Summary Cards
          ReportSummaryCard(
            title: 'Total Revenue',
            value: '${summaryStats['totalRevenue'].toStringAsFixed(0)} PKR',
            subtitle: 'Last 10 Days',
            icon: Icons.attach_money,
            color: Colors.green,
            trend: '+9.8%',
            isPositive: true,
          ),
          
          const SizedBox(height: 12),
          
          Column(
            children: [
              ReportSummaryCard(
                title: 'Total Orders',
                value: '${summaryStats['totalOrders']}',
                subtitle: 'Orders',
                icon: Icons.shopping_cart,
                color: Colors.blue,
                trend: '+12.5%',
                isPositive: true,
              ),
              const SizedBox(height: 12),
              ReportSummaryCard(
                title: 'Avg Order Value',
                value: '${summaryStats['averageOrderValue'].toStringAsFixed(0)} PKR',
                subtitle: 'Per Order',
                icon: Icons.analytics,
                color: Colors.orange,
                trend: '+5.2%',
                isPositive: true,
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Chart Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.show_chart, color: Color(0xFF1E3A8A)),
                    const SizedBox(width: 8),
                    const Text(
                      'Sales Trend',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '+9.8% Growth',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: ReportChartWidget(data: chartData),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Category Performance
          CategoryPerformanceWidget(
            categories: summaryStats['topCategories'],
          ),
          
          const SizedBox(height: 20),
          
          // Top Products
          TopProductsWidget(
            products: summaryStats['topProducts'],
          ),
          
          const SizedBox(height: 20),
          
          // Recent Reports List
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.history, color: Color(0xFF1E3A8A)),
                    const SizedBox(width: 8),
                    const Text(
                      'Recent Reports',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${reports.length} reports',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reports.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    return _buildReportCard(report);
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRealApiContent() {
    return BlocProvider(
      create: (_) => DailyReportBloc(
        getDailyReports: GetDailyReports(
          DailyReportRepositoryImpl(
            remoteDataSource: DailyReportRemoteDataSourceImpl(
              baseUrl: 'http://137.59.224.222:8080',
            ),
          ),
        ),
      )..add(const DailyReportEvent.loadReports()),
      child: BlocBuilder<DailyReportBloc, DailyReportState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Center(
              child: Text(
                'Select a report type to view data',
                style: TextStyle(color: Colors.white),
              ),
            ),
            loading: () => const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Loading reports from API...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            loaded: (reports) => _buildReportsList(reports),
            error: (message) => Center(
              child: Container(
                margin: const EdgeInsets.all(32),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading reports',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<DailyReportBloc>().add(const DailyReportEvent.loadReports());
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: Theme.of(context).elevatedButtonTheme.style,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReportsList(List<DailyReport> reports) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Summary Stats
          if (reports.isNotEmpty) ...[
            ReportSummaryCard(
              title: 'Total Revenue',
              value: '${reports.fold(0.0, (sum, report) => sum + report.totalSales).toStringAsFixed(0)} PKR',
              subtitle: 'All Reports',
              icon: Icons.attach_money,
              color: Colors.green,
              trend: '+8.5%',
              isPositive: true,
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                ReportSummaryCard(
                  title: 'Total Orders',
                  value: '${reports.fold(0, (sum, report) => sum + report.totalOrders)}',
                  subtitle: 'Orders',
                  icon: Icons.shopping_cart,
                  color: Colors.blue,
                  trend: '+10.2%',
                  isPositive: true,
                ),
                const SizedBox(height: 12),
                ReportSummaryCard(
                  title: 'Avg Order Value',
                  value: '${(reports.fold(0.0, (sum, report) => sum + report.totalSales) / reports.fold(0, (sum, report) => sum + report.totalOrders)).toStringAsFixed(0)} PKR',
                  subtitle: 'Per Order',
                  icon: Icons.analytics,
                  color: Colors.orange,
                  trend: '+3.8%',
                  isPositive: true,
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
          
          // Reports List
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.assessment, color: Color(0xFF1E3A8A)),
                    const SizedBox(width: 8),
                    const Text(
                      'Daily Reports',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${reports.length} reports',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (reports.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'No reports available',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: reports.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildReportCard(reports[index]);
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(DailyReport report) {
    return Card(
      elevation: Theme.of(context).cardTheme.elevation,
      shape: Theme.of(context).cardTheme.shape,
      color: Theme.of(context).cardTheme.color,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showReportDetails(report),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      report.date,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: report.growthRate >= 0 ? Colors.green.shade100 : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${report.growthRate >= 0 ? '+' : ''}${report.growthRate.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: report.growthRate >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${report.totalSales.toStringAsFixed(0)} PKR',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${report.totalOrders} orders • ${report.customerCount} customers',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Top: ${report.topProduct}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Filter Options',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 20),
            // Add filter options here
            const Text('Filter options will be implemented here'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
} 
