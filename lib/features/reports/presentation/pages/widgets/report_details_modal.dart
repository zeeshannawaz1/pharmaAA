import 'package:flutter/material.dart';
import '../../../domain/entities/daily_report.dart';

class ReportDetailsModal extends StatelessWidget {
  final DailyReport report;

  const ReportDetailsModal({
    Key? key,
    required this.report,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.assessment,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Report Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        report.date,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Key Metrics
                  _buildSection(
                    'Key Metrics',
                    Icons.analytics,
                    [
                      _buildMetricCard('Total Sales', '${report.totalSales.toStringAsFixed(0)} PKR', Icons.attach_money, Colors.green),
                      _buildMetricCard('Total Orders', '${report.totalOrders}', Icons.shopping_cart, Colors.blue),
                      _buildMetricCard('Average Order Value', '${report.averageOrderValue.toStringAsFixed(0)} PKR', Icons.analytics, Colors.orange),
                      _buildMetricCard('Customer Count', '${report.customerCount}', Icons.people, Colors.purple),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Performance Metrics
                  _buildSection(
                    'Performance Metrics',
                    Icons.trending_up,
                    [
                      _buildMetricCard('Growth Rate', '${report.growthRate >= 0 ? '+' : ''}${report.growthRate.toStringAsFixed(1)}%', Icons.trending_up, report.growthRate >= 0 ? Colors.green : Colors.red),
                      _buildMetricCard('Profit Margin', '${report.profitMargin.toStringAsFixed(1)}%', Icons.account_balance_wallet, Colors.teal),
                      _buildMetricCard('Return Rate', '${report.returnRate.toStringAsFixed(1)}%', Icons.assignment_return, Colors.orange),
                      _buildMetricCard('Stock Level', report.stockLevel, Icons.inventory, _getStockLevelColor(report.stockLevel)),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Top Performers
                  _buildSection(
                    'Top Performers',
                    Icons.star,
                    [
                      _buildMetricCard('Top Product', report.topProduct, Icons.medical_services, Colors.indigo),
                      _buildMetricCard('Top Product Sales', '${report.topProductSales.toStringAsFixed(0)} PKR', Icons.attach_money, Colors.green),
                      _buildMetricCard('Top Category', report.topCategory, Icons.category, Colors.blue),
                      _buildMetricCard('Top Category Sales', '${report.topCategorySales.toStringAsFixed(0)} PKR', Icons.attach_money, Colors.green),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Notes
                  if (report.notes.isNotEmpty) ...[
                    _buildSection(
                      'Notes',
                      Icons.note,
                      [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Text(
                            report.notes,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ),
          
          // Action Buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Export functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Export functionality will be implemented')),
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Export'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1E3A8A),
                      side: const BorderSide(color: Color(0xFF1E3A8A)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Share functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Share functionality will be implemented')),
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF1E3A8A), size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStockLevelColor(String stockLevel) {
    switch (stockLevel.toLowerCase()) {
      case 'optimal':
      case 'excellent':
        return Colors.green;
      case 'good':
        return Colors.blue;
      case 'low':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }
} 
