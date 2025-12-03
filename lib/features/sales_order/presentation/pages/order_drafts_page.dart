import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/order_draft_bloc.dart';
import '../../domain/entities/order_draft.dart';
import '../../../../injection_container.dart' as di;
import '../../../../main_screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import '../../domain/entities/product.dart';
import '../../../../core/database/offline_database_service.dart';
import 'package:collection/collection.dart'; // Added for firstWhereOrNull
import 'package:shared_preferences/shared_preferences.dart';
import 'order_summary_page.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';
import 'package:cross_file/cross_file.dart';

class OrderDraftsPage extends StatefulWidget {
  const OrderDraftsPage({super.key});

  @override
  State<OrderDraftsPage> createState() => _OrderDraftsPageState();
}

class _OrderDraftsPageState extends State<OrderDraftsPage> {
  String? _latestLog;
  String? _currentUserId;
  String? _currentBookingManId;
  final Set<String> _selectedDraftIds = {}; // Track selected drafts
  bool _isSelectionMode = false; // Track if we're in selection mode
  int _previousDraftCount = 0; // Track previous draft count to detect clear action

  // Generate unique 8-digit BO ID for professional export
  static int generateUniqueBoId() {
    final random = Random();
    // Generate random 8-digit number between 10000000 and 99999999
    final baseId = 10000000 + random.nextInt(90000000);
    
    // Add timestamp-based uniqueness to ensure no duplicates
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final timestampSuffix = timestamp % 1000; // Last 3 digits of timestamp
    
    // Combine base ID with timestamp for uniqueness, ensuring 8 digits
    final uniqueId = (baseId + timestampSuffix) % 100000000;
    
    // Ensure it's always 8 digits (minimum 10000000)
    return uniqueId < 10000000 ? uniqueId + 10000000 : uniqueId;
  }

  @override
  void initState() {
    super.initState();
    print('OrderDraftsPage: initState called');
    _loadUserData();
  }

  // Load user data from SharedPreferences
  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username');
      final bookingManId = prefs.getString('booking_man_id');
      
      setState(() {
        _currentUserId = username ?? 'unknown_user';
        _currentBookingManId = bookingManId ?? 'unknown_bm';
      });
      
      print('Loaded user data - Username: $_currentUserId, Booking Man ID: $_currentBookingManId');
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _currentUserId = 'unknown_user';
        _currentBookingManId = 'unknown_bm';
      });
    }
  }

  void _setLog(String log) {
    setState(() {
      _latestLog = log;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('OrderDraftsPage: build called');
    return BlocProvider(
      create: (context) => di.sl<OrderDraftBloc>()..add(const OrderDraftEvent.loadDrafts()),
      child: Scaffold(
                  appBar: AppBar(
            title: const Text('Order Drafts'),
            backgroundColor: Colors.black87,
            foregroundColor: Colors.black,
            elevation: 0,
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
                    'SRC-5',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            // Export CSV button - always visible for professional testing
            BlocBuilder<OrderDraftBloc, OrderDraftState>(
              builder: (context, state) {
                return PopupMenuButton<String>(
                  icon: const Icon(Icons.file_download),
                  tooltip: 'Export All Posted Orders to CSV',
                  onSelected: (value) {
                    switch (value) {
                      case 'export':
                        _exportAllPostedOrdersToCSV(context, context.read<OrderDraftBloc>());
                        break;
                      case 'export_all':
                        _exportAllExistingOrdersToCSV(context, context.read<OrderDraftBloc>());
                        break;
                      case 'clear':
                        _clearExistingCSV(context);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'export',
                      child: Row(
                        children: [
                          Icon(Icons.file_download, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Export All Posted Orders'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'export_all',
                      child: Row(
                        children: [
                          Icon(Icons.download, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Export All Existing Orders'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'clear',
                      child: Row(
                        children: [
                          Icon(Icons.delete_sweep, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Clear Existing CSV'),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            // Reset button - always visible for professional testing
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _showResetConfirmation(context),
              tooltip: 'Reset Drafts (Clear & Reload)',
            ),
            BlocBuilder<OrderDraftBloc, OrderDraftState>(
              builder: (context, state) {
                return state.maybeWhen(
                  loaded: (drafts) => drafts.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.delete_sweep),
                          onPressed: () => _showClearConfirmation(context),
                          tooltip: 'Clear all drafts',
                        )
                      : const SizedBox.shrink(),
                  orElse: () => const SizedBox.shrink(),
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<OrderDraftBloc, OrderDraftState>(
          listener: (context, state) {
            state.maybeWhen(
              error: (message) {
                _setLog('Error: $message');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              loading: () {
                _setLog('Loading drafts...');
              },
              loaded: (drafts) {
                // Check if drafts were cleared (went from non-empty to empty)
                if (drafts.isEmpty && _previousDraftCount > 0) {
                  _setLog('All drafts cleared successfully.');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ All drafts cleared successfully'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  _previousDraftCount = 0;
                } else if (drafts.isEmpty) {
                  _setLog('No drafts found.');
                  _previousDraftCount = 0;
                } else {
                  _setLog('Loaded ${drafts.length} drafts.');
                  _previousDraftCount = drafts.length;
                }
              },
              orElse: () {},
            );
          },
          builder: (context, state) {
            Widget mainView = state.map(
              initial: (_) => const _InitialView(),
              loading: (_) => const _EnhancedLoadingView(),
              loaded: (loadedState) => _LoadedView(drafts: loadedState.drafts),
              error: (errorState) => _ErrorView(message: errorState.message),
            );
            return Column(
              children: [
                Expanded(child: mainView),
                if (_latestLog != null)
                  Container(
                    width: double.infinity,
                    color: Colors.black.withOpacity(0.05),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Text(
                      _latestLog!,
                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ),
                // Selection summary widget
                if (_isSelectionMode && _selectedDraftIds.isNotEmpty)
                  Container(
                    width: double.infinity,
                    color: Colors.blue.shade50,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.blue.shade700, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              '${_selectedDraftIds.length} draft(s) selected',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _selectedDraftIds.clear();
                                });
                              },
                              child: const Text('Clear All'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _postAllSelectedDrafts,
                                icon: const Icon(Icons.cloud_upload, size: 16),
                                label: const Text('Post to Server'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _exportSelectedDraftsToCSV,
                                icon: const Icon(Icons.file_download, size: 16),
                                label: const Text('Export to CSV'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
        floatingActionButton: BlocBuilder<OrderDraftBloc, OrderDraftState>(
          builder: (context, state) {
            return state.maybeWhen(
              loaded: (drafts) {
                if (drafts.isEmpty) {
                  return const SizedBox.shrink(); // No FAB when no drafts
                }
                
                if (_isSelectionMode) {
                  // Selection mode - show bulk actions
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: FloatingActionButton.extended(
                            onPressed: _selectedDraftIds.isEmpty ? null : _postAllSelectedDrafts,
                            backgroundColor: _selectedDraftIds.isEmpty ? Colors.grey : Colors.green,
                            icon: const Icon(Icons.cloud_upload),
                            label: Text('Post ${_selectedDraftIds.length}'),
                            tooltip: 'Post selected drafts to server for processing',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: FloatingActionButton.extended(
                            onPressed: _selectedDraftIds.isEmpty ? null : _exportSelectedDraftsToCSV,
                            backgroundColor: _selectedDraftIds.isEmpty ? Colors.grey : Colors.orange,
                            icon: const Icon(Icons.file_download),
                            label: Text('Export ${_selectedDraftIds.length}'),
                            tooltip: 'Export selected drafts to CSV file',
                          ),
                        ),
                        const SizedBox(width: 8),
                        FloatingActionButton(
                          onPressed: _exitSelectionMode,
                          backgroundColor: Colors.red,
                          tooltip: 'Exit selection mode',
                          child: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Normal mode - no selection button
                  return const SizedBox.shrink();
                }
              },
              orElse: () => const SizedBox.shrink(),
            );
          },
        ),
      ),
    );
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Drafts'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'This will:\n'
              '• Clear all existing drafts\n'
              '• Reset the drafts page state\n'
              '• Provide a clean testing environment\n\n'
              'This action cannot be undone.',
            ),
            const SizedBox(height: 16),
            const BannerAdWidget(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _performProfessionalReset(context);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _performProfessionalReset(BuildContext context) {
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔄 Resetting drafts...'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );

    // Clear all drafts first
    context.read<OrderDraftBloc>().add(const OrderDraftEvent.clearDrafts());
    
    // Wait a moment then reload to ensure clean state
    Future.delayed(const Duration(milliseconds: 500), () {
      context.read<OrderDraftBloc>().add(const OrderDraftEvent.loadDrafts());
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Drafts reset successfully! Ready for testing.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    });
  }

  void _showClearConfirmation(BuildContext context) {
    // Capture the current draft count before showing dialog
    final currentState = context.read<OrderDraftBloc>().state;
    int currentDraftCount = 0;
    currentState.maybeWhen(
      loaded: (drafts) => currentDraftCount = drafts.length,
      orElse: () => currentDraftCount = 0,
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear All Drafts'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to delete all order drafts? This action cannot be undone.'),
            const SizedBox(height: 16),
            const BannerAdWidget(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Set the previous count before clearing
              setState(() {
                _previousDraftCount = currentDraftCount;
              });
              // Use the original context, not dialogContext, to access the bloc
              context.read<OrderDraftBloc>().add(const OrderDraftEvent.clearDrafts());
              Navigator.of(dialogContext).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  // Export all posted orders to CSV
  Future<void> _exportAllPostedOrdersToCSV(BuildContext context, OrderDraftBloc bloc) async {
    try {
              // Show loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📊 Exporting all posted orders to CSV...'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );

      // Get all posted orders
      final allPostedOrders = await _getAllPostedOrders(context, bloc);
      
      if (allPostedOrders.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ℹ️ No posted orders found\n\nTo test CSV export:\n1. Create an order\n2. Confirm it for processing\n3. Try export again'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Create Test Data',
              onPressed: () => _createTestOrderData(context, bloc),
            ),
          ),
        );
        return;
      }

      // Create CSV content
      final csvContent = _createCSVContent(allPostedOrders);
      
      // Get app documents directory
      final appDocDir = await getApplicationDocumentsDirectory();
      final bbsdDir = Directory('${appDocDir.path}/BBSD');
      
      // Create BBSD directory if it doesn't exist
      if (!await bbsdDir.exists()) {
        await bbsdDir.create(recursive: true);
      }
      
      // Remove existing CSV file if it exists
      final csvFile = File('${bbsdDir.path}/salord.csv');
      if (await csvFile.exists()) {
        await csvFile.delete();
        print('🗑️ Removed existing CSV file');
      }
      
      // Create new CSV file
      await csvFile.writeAsString(csvContent);
      print('✅ Created new CSV file: ${csvFile.path}');
      
      // Also copy to external storage for better sharing
      await _copyToExternalStorage(csvFile.path, csvContent);
      
      // Show success message with View and Share buttons
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
              Text('📊 ${allPostedOrders.length} orders exported'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 6),
          action: SnackBarAction(
            label: 'View & Share',
            onPressed: () => _showViewAndShareOptions(context, csvFile.path, csvContent, allPostedOrders.length),
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

  // Export all existing orders to CSV (no limit, includes posted and non-posted)
  Future<void> _exportAllExistingOrdersToCSV(BuildContext context, OrderDraftBloc bloc) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📊 Exporting all existing orders to CSV...'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );

      // Get all existing orders (no filter)
      final allExistingOrders = await _getAllExistingOrders(context, bloc);
      
      if (allExistingOrders.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ℹ️ No orders found to export'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      // Create CSV content
      final csvContent = _createCSVContent(allExistingOrders);
      
      // Get app documents directory
      final appDocDir = await getApplicationDocumentsDirectory();
      final bbsdDir = Directory('${appDocDir.path}/BBSD');
      
      // Create BBSD directory if it doesn't exist
      if (!await bbsdDir.exists()) {
        await bbsdDir.create(recursive: true);
      }
      
      // Create CSV file with timestamp to avoid overwriting
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final csvFile = File('${bbsdDir.path}/all_orders_$timestamp.csv');
      
      // Create new CSV file
      await csvFile.writeAsString(csvContent);
      print('✅ Created new CSV file: ${csvFile.path}');
      
      // Also copy to external storage for better sharing
      await _copyToExternalStorage(csvFile.path, csvContent);
      
      // Show success message with View and Share buttons
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '✅ CSV exported successfully!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('📁 Location: ${csvFile.path}'),
              Text('📊 ${allExistingOrders.length} order records exported'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 6),
          action: SnackBarAction(
            label: 'View & Share',
            onPressed: () => _showViewAndShareOptions(context, csvFile.path, csvContent, allExistingOrders.length),
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

  // Get all existing orders (no filter - includes posted and non-posted)
  Future<List<Map<String, dynamic>>> _getAllExistingOrders(BuildContext context, OrderDraftBloc bloc) async {
    try {
      // Get all drafts from the provided bloc
      final state = bloc.state;
      List<OrderDraft> allDrafts = [];
      
      state.maybeWhen(
        loaded: (drafts) => allDrafts = drafts,
        orElse: () => allDrafts = [],
      );
      
      print('Found ${allDrafts.length} total drafts (all orders)');
      
      // Debug: Show all drafts
      for (final draft in allDrafts) {
        print('Draft: ${draft.clientName}');
        print('  - ID: ${draft.id}');
        print('  - Created: ${draft.createdAt}');
        print('  - Is Confirmed: ${draft.isConfirmedForProcessing}');
        print('  - Items: ${draft.items.length}');
        print('  - Export Data: ${draft.exportData?.length ?? 0} records');
      }
      
      // No filtering - include ALL orders regardless of confirmation status
      print('Including all ${allDrafts.length} orders (no filter applied)');
      
      // Generate export data for all orders
      List<Map<String, dynamic>> exportData = [];
      
      for (final draft in allDrafts) {
        if (draft.exportData != null && draft.exportData!.isNotEmpty && draft.isConfirmedForProcessing) {
          // Use saved export data for confirmed orders
          print('Using saved export data for ${draft.clientName}');
          exportData.addAll(draft.exportData!);
        } else {
          // Generate new export data for non-confirmed orders or confirmed orders without saved data
          print('Generating new export data for ${draft.clientName}');
          final draftExportData = await _generateExportDataForDraft(draft);
          exportData.addAll(draftExportData);
        }
      }
      
      print('Generated ${exportData.length} export records for all existing orders');
      return exportData;
      
    } catch (e) {
      print('Error in _getAllExistingOrders: $e');
      rethrow;
    }
  }

  // Get all posted orders (not just today's)
  Future<List<Map<String, dynamic>>> _getAllPostedOrders(BuildContext context, OrderDraftBloc bloc) async {
    try {
      // Get all drafts from the provided bloc
      final state = bloc.state;
      List<OrderDraft> allDrafts = [];
      
      state.maybeWhen(
        loaded: (drafts) => allDrafts = drafts,
        orElse: () => allDrafts = [],
      );
      
      print('Found ${allDrafts.length} total drafts');
      
      // Debug: Show all drafts
      for (final draft in allDrafts) {
        print('Draft: ${draft.clientName}');
        print('  - ID: ${draft.id}');
        print('  - Created: ${draft.createdAt}');
        print('  - Is Confirmed: ${draft.isConfirmedForProcessing}');
        print('  - Items: ${draft.items.length}');
        print('  - Export Data: ${draft.exportData?.length ?? 0} records');
      }
      
      // Filter for ALL confirmed orders (not just today's)
      final allPostedOrders = allDrafts.where((draft) {
        final isConfirmed = draft.isConfirmedForProcessing;
        print('Checking draft: ${draft.clientName}');
        print('  - Created: ${draft.createdAt}');
        print('  - Is confirmed: $isConfirmed');
        print('  - Will include: $isConfirmed');
        return isConfirmed;
      }).toList();
      
      print('Found ${allPostedOrders.length} total posted orders');
      
      // Debug: Show filtered orders
      for (final order in allPostedOrders) {
        print('Posted order: ${order.clientName}');
        print('  - Created: ${order.createdAt}');
        print('  - Items: ${order.items.length}');
        print('  - Export Data: ${order.exportData?.length ?? 0} records');
        for (final item in order.items) {
          print('    - ${item.productName}: ${item.quantity} x ${item.unitPrice} = ${item.totalPrice}');
        }
      }
      
      // Use saved export data if available, otherwise generate new
      List<Map<String, dynamic>> exportData = [];
      
      for (final draft in allPostedOrders) {
        if (draft.exportData != null && draft.exportData!.isNotEmpty) {
          // Use saved export data from confirmation
          print('Using saved export data for ${draft.clientName}');
          exportData.addAll(draft.exportData!);
        } else {
          // Generate new export data (fallback)
          print('Generating new export data for ${draft.clientName}');
          for (final item in draft.items) {
            exportData.add({
              'bo_id': _OrderDraftsPageState.generateUniqueBoId(), // 8-digit BO ID
              'bm_code': await _getBookingManId(),
              'client_code': draft.clientId,
              'pr_code': item.prCode,
              'pcode': item.productCode,
              'item_name': item.productName,
              'qty': item.quantity,
              'bonus': item.bonus ?? 0,
              'dis_percent': item.discount ?? 0,
              'total_amount': item.totalPrice,
            });
          }
        }
      }
      
      print('Generated ${exportData.length} export records for all posted orders');
      return exportData;
      
    } catch (e) {
      print('Error in _getAllPostedOrders: $e');
      rethrow;
    }
  }

  // Create test order data for CSV export testing
  void _createTestOrderData(BuildContext context, OrderDraftBloc bloc) {
    try {
      // Create a test order draft with confirmed status
      final testDraft = OrderDraft(
        id: 'test_${DateTime.now().millisecondsSinceEpoch}',
        clientId: 'TEST001',
        clientName: 'Test Client',
        clientCity: 'Test City',
        items: [
          OrderItem(
            id: 'item_1',
            bmCode: 'BM001',
            prCode: 'PR001',
            productId: 'PROD001',
            productCode: 'P001',
            productName: 'Test Product 1',
            quantity: 10,
            unitPrice: 100.0,
            totalPrice: 1000.0,
            bonus: 2.0,
            discount: 5.0,
            packing: 'Box',
          ),
          OrderItem(
            id: 'item_2',
            bmCode: 'BM002',
            prCode: 'PR002',
            productId: 'PROD002',
            productCode: 'P002',
            productName: 'Test Product 2',
            quantity: 5,
            unitPrice: 200.0,
            totalPrice: 1000.0,
            bonus: 1.0,
            discount: 10.0,
            packing: 'Bottle',
          ),
        ],
        totalAmount: 2000.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isConfirmedForProcessing: true, // This makes it a "posted" order
        confirmedAt: DateTime.now(),
        notes: 'Test order for CSV export',
        exportData: [
          {
            'bo_id': _OrderDraftsPageState.generateUniqueBoId(), // 8-digit BO ID
            'bm_code': '123',
            'client_code': 'TEST001',
            'pr_code': 'PR001',
            'pcode': 'P001',
            'item_name': 'Test Product 1',
            'qty': 10,
            'bonus': 2.0,
            'dis_percent': 5.0,
            'total_amount': 1000.0,
          },
          {
            'bo_id': _OrderDraftsPageState.generateUniqueBoId(), // 8-digit BO ID
            'bm_code': '123',
            'client_code': 'TEST001',
            'pr_code': 'PR002',
            'pcode': 'P002',
            'item_name': 'Test Product 2',
            'qty': 5,
            'bonus': 1.0,
            'dis_percent': 10.0,
            'total_amount': 1000.0,
          },
        ],
      );

      // Add the test draft to the bloc
      bloc.add(OrderDraftEvent.saveDraft(testDraft));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Test order created! Now try exporting CSV again.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

    } catch (e) {
      print('Error creating test data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error creating test data: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Create CSV content
  String _createCSVContent(List<Map<String, dynamic>> orders) {
    // CSV header
    final header = 'bo id,bm code,client code,pr code,pcode,item name,Qty,bonus,dis%,total Amount\n';
    
    // CSV rows
    final rows = orders.map((order) {
      return '${order['bo_id']},'
             '${order['bm_code']},'
             '${order['client_code']},'
             '${order['pr_code']},'
             '${order['pcode']},'
             '"${order['item_name']}",'
             '${order['qty']},'
             '${order['bonus']},'
             '${order['dis_percent']},'
             '${order['total_amount']}';
    }).join('\n');
    
    return header + rows;
  }

  // Get booking man ID from SharedPreferences
  Future<String> _getBookingManId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('booking_man_id') ?? '123';
    } catch (e) {
      print('Error loading booking man ID: $e');
      return '123';
    }
  }

  // Show View and Share options dialog
  void _showViewAndShareOptions(BuildContext context, String filePath, String csvContent, int orderCount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.file_download, color: Colors.green),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'CSV Export Options',
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'File: salord.csv',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
            Text('Orders: $orderCount'),
            Text('Location: ${filePath.split('/').last}'),
            const SizedBox(height: 16),
            const Text(
              'Choose an action:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const BannerAdWidget(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _viewCSVFile(context, filePath, csvContent, orderCount);
            },
            icon: const Icon(Icons.visibility, size: 16),
            label: const Text('View'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _shareCSVFile(context, filePath);
            },
            icon: const Icon(Icons.share, size: 16),
            label: const Text('Share'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // View CSV file content
  void _viewCSVFile(BuildContext context, String filePath, String csvContent, int orderCount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.visibility, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'CSV File Preview',
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Text(
              '($orderCount orders)',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.file_present, color: Colors.green[600], size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'salord.csv',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[600],
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _openCSVFile(context, filePath),
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('Open File'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100]!,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      csvContent,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Share CSV file
  void _shareCSVFile(BuildContext context, String filePath) async {
    try {
      // Try internal file first
      File file = File(filePath);
      String sharePath = filePath;
      
      // If internal file doesn't exist, try external storage
      if (!await file.exists()) {
        final externalFile = File('/storage/emulated/0/Download/salord.csv');
        if (await externalFile.exists()) {
          file = externalFile;
          sharePath = externalFile.path;
          print('Using external CSV file for sharing: $sharePath');
        }
      }
      
      if (await file.exists()) {
        // Share the actual CSV file
        await Share.shareXFiles(
          [XFile(sharePath)],
          text: 'CSV Export - Today\'s Posted Orders',
          subject: 'Sales Orders Export',
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📤 Sharing CSV file...'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ CSV file not found'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error sharing file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error sharing file: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Open CSV file with system app
  void _openCSVFile(BuildContext context, String filePath) async {
    try {
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error opening file: ${result.message}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error opening file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error opening file: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Copy CSV file to external storage for better sharing
  Future<void> _copyToExternalStorage(String internalPath, String csvContent) async {
    try {
      // Get external storage directory
      final externalDir = Directory('/storage/emulated/0/Download');
      if (await externalDir.exists()) {
        final externalFile = File('${externalDir.path}/salord.csv');
        await externalFile.writeAsString(csvContent);
        print('✅ Copied CSV to external storage: ${externalFile.path}');
      }
    } catch (e) {
      print('Error copying to external storage: $e');
      // This is not critical, so we don't show error to user
    }
  }

  // Clear existing CSV file
  void _clearExistingCSV(BuildContext context) async {
    try {
      // Get app documents directory
      final appDocDir = await getApplicationDocumentsDirectory();
      final bbsdDir = Directory('${appDocDir.path}/BBSD');
      final csvFile = File('${bbsdDir.path}/salord.csv');
      
      if (await csvFile.exists()) {
        await csvFile.delete();
        print('🗑️ Cleared existing CSV file');
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🗑️ Existing CSV file cleared successfully'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ℹ️ No existing CSV file found'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error clearing CSV file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error clearing CSV file: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Selection mode methods
  void _enterSelectionMode() {
    setState(() {
      _isSelectionMode = true;
      _selectedDraftIds.clear();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📋 Selection mode activated. Tap drafts to select them.'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedDraftIds.clear();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('❌ Selection mode cancelled.'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _toggleDraftSelection(String draftId) {
    setState(() {
      if (_selectedDraftIds.contains(draftId)) {
        _selectedDraftIds.remove(draftId);
      } else {
        _selectedDraftIds.add(draftId);
      }
    });
  }

  void _postAllSelectedDrafts() async {
    if (_selectedDraftIds.isEmpty) return;

    // Get the current state to access drafts
    final bloc = context.read<OrderDraftBloc>();
    final state = bloc.state;
    
    state.maybeWhen(
      loaded: (drafts) async {
        final selectedDrafts = drafts.where((draft) => _selectedDraftIds.contains(draft.id)).toList();
        
        if (selectedDrafts.isEmpty) return;

        // Show confirmation dialog
        final shouldProceed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Post All Selected Drafts'),
            content: Text(
              'Are you sure you want to post ${selectedDrafts.length} draft(s)?\n\n'
              'This will:\n'
              '• Confirm all selected drafts for processing\n'
              '• Send all orders to the server\n'
              '• Make all drafts read-only\n\n'
              'Selected drafts:\n${selectedDrafts.map((d) => '• ${d.clientName}').join('\n')}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Post All'),
              ),
            ],
          ),
        );

        if (shouldProceed == true) {
          await _performBulkPost(selectedDrafts);
        }
      },
      orElse: () {},
    );
  }

  Future<void> _performBulkPost(List<OrderDraft> drafts) async {
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🔄 Posting ${drafts.length} drafts to server...'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );

    int successCount = 0;
    int errorCount = 0;
    List<String> errorMessages = [];

    // Process each draft
    for (int i = 0; i < drafts.length; i++) {
      final draft = drafts[i];
      
      try {
        // Show progress
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🔄 Processing ${i + 1}/${drafts.length}: ${draft.clientName}'),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 1),
          ),
        );

        // Confirm the draft if not already confirmed
        if (!draft.isConfirmedForProcessing) {
          context.read<OrderDraftBloc>().add(OrderDraftEvent.confirmDraftForProcessing(draft));
        }

        // Send to server
        await _sendOrderToServer(draft);
        successCount++;
        
        // Small delay between requests
        await Future.delayed(const Duration(milliseconds: 500));
        
      } catch (e) {
        errorCount++;
        errorMessages.add('${draft.clientName}: ${e.toString()}');
        print('Error posting draft ${draft.clientName}: $e');
      }
    }

    // Exit selection mode
    setState(() {
      _isSelectionMode = false;
      _selectedDraftIds.clear();
    });

    // Show final results
    String resultMessage = '✅ Successfully posted $successCount draft(s)';
    if (errorCount > 0) {
      resultMessage += '\n❌ Failed to post $errorCount draft(s)';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(resultMessage),
        backgroundColor: errorCount > 0 ? Colors.orange : Colors.green,
        duration: const Duration(seconds: 4),
        action: errorCount > 0 ? SnackBarAction(
          label: 'Details',
          onPressed: () => _showErrorDetails(errorMessages),
        ) : null,
      ),
    );
  }

  void _showErrorDetails(List<String> errorMessages) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Post Errors'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: errorMessages.map((error) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text('• $error', style: const TextStyle(fontSize: 12)),
            )).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Extracted server posting method for reuse
  Future<void> _sendOrderToServer(OrderDraft draft) async {
    print('==== BULK POST: Starting order posting process ====');
    print('Draft ID: ${draft.id}');
    print('Client Name: ${draft.clientName}');
    print('Client ID: ${draft.clientId}');
    print('Total Items: ${draft.items.length}');
    print('Total Amount: ${draft.totalAmount}');
    
    // Load booking man ID from SharedPreferences
    String bookingManId = '123'; // Default fallback
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedBookingManId = prefs.getString('booking_man_id');
      if (savedBookingManId != null && savedBookingManId.isNotEmpty) {
        bookingManId = savedBookingManId;
      }
      print('Loaded Booking Man ID: $bookingManId');
    } catch (e) {
      print('Error loading booking man ID: $e');
    }
    
    // Load available products for proper PRCODE/PCODE mapping
    final databaseService = OfflineDatabaseService();
    List<Product> availableProducts = [];
    try {
      availableProducts = await databaseService.getOfflineProducts();
      print('Loaded ${availableProducts.length} products for mapping');
    } catch (e) {
      print('Error loading products for mapping: $e');
    }
    
    final url = Uri.parse('http://137.59.224.222:8080/postSalOrdersCopy.php');
    final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    final data = draft.items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      
      // Generate unique 8-digit BO ID for this specific product
      final uniqueBoId = generateUniqueBoId();
      
      // Find the actual Product entity to get correct prcode and pcode
      Product? selectedProduct;
      
      // Strategy 1: Search by exact product name
      selectedProduct = availableProducts.firstWhereOrNull(
        (p) => p.pname.toLowerCase().trim() == item.productName.toLowerCase().trim(),
      );
      
      // Strategy 2: Search by product code if name search failed
      selectedProduct ??= availableProducts.firstWhereOrNull(
          (p) => p.pcode == item.productCode || p.pcode == item.prCode,
        );
      
      // Strategy 3: Search by partial name match if exact match failed
      selectedProduct ??= availableProducts.firstWhereOrNull(
          (p) => p.pname.toLowerCase().contains(item.productName.toLowerCase()) ||
                 item.productName.toLowerCase().contains(p.pname.toLowerCase()),
        );
      
      // If still not found, throw an error
      if (selectedProduct == null) {
        throw Exception('Product "${item.productName}" not found in offline database. '
            'Please sync offline data before submitting orders.');
      }
      
      final itemData = {
        'BO_ID': uniqueBoId,
        'V_DATE': dateStr,
        'BMCODE': int.tryParse(bookingManId) ?? 123,
        'CLIENTCODE': draft.clientId,
        'TCODE': null,
        'TSCODE': null,
        'CCODE': null,
        'PRCODE': selectedProduct.prcode,
        'PCODE': selectedProduct.pcode,
        'PNAME': selectedProduct.pname,
        'QNTY': item.quantity,
        'BQNTY': item.bonus ?? 0,
        'ODISC': item.discount ?? 0,
        'AMOUNT': item.totalPrice,
        'ORD_STATUS': null,
        'TPRICE': double.tryParse(selectedProduct.tprice) ?? item.unitPrice,
        'BTHNO': null,
        'EXP_DATE': dateStr,
        'RATE_ID': null,
        'ORDER_REFRENCE': 1122,
      };
      
      return itemData;
    }).toList();
    
    final body = {
      'allSOrders': jsonEncode({'data': data}),
    };
    
    final response = await http.post(url, body: body);
    
    if (response.statusCode != 200 || !response.body.toLowerCase().contains('successful')) {
      throw Exception('Server error: ${response.body}');
    }
  }

  // Export selected drafts to CSV
  void _exportSelectedDraftsToCSV() async {
    if (_selectedDraftIds.isEmpty) return;

    // Get the current state to access drafts
    final bloc = context.read<OrderDraftBloc>();
    final state = bloc.state;
    
    state.maybeWhen(
      loaded: (drafts) async {
        final selectedDrafts = drafts.where((draft) => _selectedDraftIds.contains(draft.id)).toList();
        
        if (selectedDrafts.isEmpty) return;

        // Show confirmation dialog
        final shouldProceed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Export Selected Drafts to CSV'),
            content: Text(
              'Are you sure you want to export ${selectedDrafts.length} draft(s) to CSV?\n\n'
              'This will:\n'
              '• Generate CSV file with all selected drafts\n'
              '• Include all order items and details\n'
              '• Create a downloadable file\n\n'
              'Selected drafts:\n${selectedDrafts.map((d) => '• ${d.clientName}').join('\n')}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Export to CSV'),
              ),
            ],
          ),
        );

        if (shouldProceed == true) {
          await _performBulkExport(selectedDrafts);
        }
      },
      orElse: () {},
    );
  }

  Future<void> _performBulkExport(List<OrderDraft> drafts) async {
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🔄 Exporting ${drafts.length} drafts to CSV...'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );

    try {
      // Generate export data for all selected drafts
      List<Map<String, dynamic>> allExportData = [];
      
      for (int i = 0; i < drafts.length; i++) {
        final draft = drafts[i];
        
        // Show progress
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🔄 Processing ${i + 1}/${drafts.length}: ${draft.clientName}'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 1),
          ),
        );

        // Generate export data for this draft
        final exportData = await _generateExportDataForDraft(draft);
        allExportData.addAll(exportData);
        
        // Small delay between processing
        await Future.delayed(const Duration(milliseconds: 200));
      }

      // Create CSV content
      final csvContent = _createCSVContent(allExportData);
      
      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'selected_drafts_$timestamp.csv';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsString(csvContent);
      
      // Exit selection mode
      setState(() {
        _isSelectionMode = false;
        _selectedDraftIds.clear();
      });

      // Show success message with options
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Exported ${drafts.length} drafts to CSV'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'View',
            onPressed: () => _showViewAndShareOptions(context, file.path, csvContent, allExportData.length),
          ),
        ),
      );
      
    } catch (e) {
      print('Error in bulk export: $e');
      
      // Exit selection mode
      setState(() {
        _isSelectionMode = false;
        _selectedDraftIds.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error exporting drafts: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Generate export data for a draft (reused from existing functionality)
  Future<List<Map<String, dynamic>>> _generateExportDataForDraft(OrderDraft draft) async {
    try {
      // Get booking man ID from SharedPreferences
      String bookingManId = '123'; // Default fallback
      try {
        final prefs = await SharedPreferences.getInstance();
        final savedBookingManId = prefs.getString('booking_man_id');
        if (savedBookingManId != null && savedBookingManId.isNotEmpty) {
          bookingManId = savedBookingManId;
        }
        print('Loaded Booking Man ID: $bookingManId');
      } catch (e) {
        print('Error loading booking man ID: $e');
      }
      
      List<Map<String, dynamic>> exportData = [];
      
      for (final item in draft.items) {
        // Generate unique 8-digit BO ID for each item
        final uniqueBoId = generateUniqueBoId();
        
        print('Generating export data for item: ${item.productName}');
        print('  - Unique BO_ID: $uniqueBoId (8-digit format)');
        
        exportData.add({
          'bo_id': uniqueBoId,
          'bm_code': int.tryParse(bookingManId) ?? 123,
          'client_code': draft.clientId,
          'pr_code': item.prCode,
          'pcode': item.productCode,
          'item_name': item.productName,
          'qty': item.quantity,
          'bonus': item.bonus ?? 0,
          'dis_percent': item.discount ?? 0,
          'total_amount': item.totalPrice,
        });
      }
      
      return exportData;
    } catch (e) {
      print('Error generating export data: $e');
      throw Exception('Failed to generate export data: $e');
    }
  }
}

class _InitialView extends StatelessWidget {
  const _InitialView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No drafts loaded',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Loading drafts...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please wait while we fetch your saved drafts',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<OrderDraftBloc>().add(const OrderDraftEvent.loadDrafts());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _LoadedView extends StatefulWidget {
  final List<OrderDraft> drafts;

  const _LoadedView({required this.drafts});

  @override
  State<_LoadedView> createState() => _LoadedViewState();
}

class _LoadedViewState extends State<_LoadedView> {

  @override
  Widget build(BuildContext context) {
    // Get parent state
    final parentState = context.findAncestorStateOfType<_OrderDraftsPageState>();
    final isSelectionMode = parentState?._isSelectionMode ?? false;
    final selectedDraftIds = parentState?._selectedDraftIds ?? {};
    final toggleSelection = parentState?._toggleDraftSelection ?? (String id) {};

    if (widget.drafts.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(8),
        children: [
          // --- Summary Button (always visible) ---
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const OrderSummaryPage(),
                  ),
                );
              },
              icon: const Icon(Icons.analytics, color: Colors.white),
              label: const Text(
                'View Detailed Summary',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
            ),
          ),
          // --- Empty State ---
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.note_add_outlined,
                  size: 64,
                  color: Colors.blue[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'No Order Drafts',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.blue[700],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ready for testing! Create a new order to save drafts',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: const Text(
                    '💡 Tip: Go to Order page → Fill form → Save Draft → Return here to see results',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final now = DateTime.now();
    bool isSameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;
    // Only show today's drafts
    final todayDrafts = widget.drafts.where((d) => isSameDay(d.createdAt, now)).toList();

    // --- Build summary row for today only ---
    double totalGross = 0;
    double totalNet = 0;
    double totalSubTotal = 0;
    double totalDiscount = 0;
    int orderCount = todayDrafts.length;
    List<String> orderNumbers = [];
    for (var order in todayDrafts) {
      orderNumbers.add(order.id.substring(order.id.length - 4)); // last 4 chars as order number
      double orderDiscount = 0;
      double orderSubTotal = 0;
      for (var item in order.items) {
        final dis = item.discount ?? 0;
        final itemSubTotal = (item.totalPrice / 100) * (100 - dis);
        orderSubTotal += itemSubTotal;
        orderDiscount += (item.totalPrice - itemSubTotal);
      }
      totalGross += order.totalAmount; // Gross = Total Order Amount
      totalNet += order.totalAmount - orderDiscount;
      totalSubTotal += orderSubTotal;
      totalDiscount += orderDiscount;
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        // --- Summary Button ---
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const OrderSummaryPage(),
                ),
              );
            },
            icon: const Icon(Icons.analytics, color: Colors.white),
            label: const Text(
              'View Detailed Summary',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
          ),
        ),
        // --- Only show today's summary ---
        Card(
          color: Colors.blue.shade50,
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 12,
                headingRowHeight: 32,
                dataRowHeight: 32,
                horizontalMargin: 8,
                headingRowColor: WidgetStateProperty.resolveWith<Color?>((states) => Colors.blue.shade100),
                columns: [
                  DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                  DataColumn(label: Text('Orders', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                  DataColumn(label: Text('Dis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                  DataColumn(label: Text('Gross', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                  DataColumn(label: Text('Net', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                  DataColumn(label: Text('Sub Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                ],
                rows: [
                  DataRow(
                    cells: [
                      DataCell(Text(DateFormat('MMM dd, yyyy').format(now), style: const TextStyle(fontSize: 12))),
                      DataCell(Text(orderCount.toString(), style: const TextStyle(fontSize: 12))),
                      DataCell(Text(totalDiscount.toStringAsFixed(0), style: const TextStyle(fontSize: 12))),
                      DataCell(Text(totalGross.toStringAsFixed(0), style: const TextStyle(fontSize: 12))),
                      DataCell(Text(totalNet.toStringAsFixed(0), style: const TextStyle(fontSize: 12))),
                      DataCell(Text(totalSubTotal.toStringAsFixed(0), style: const TextStyle(fontSize: 12))),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        // --- Only show today's drafts ---
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Today',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.blue[900], fontWeight: FontWeight.bold
            ),
          ),
        ),
        ...todayDrafts.map((draft) => _DraftCard(
          draft: draft, 
          onEdit: () async {
            final parentBloc = context.read<OrderDraftBloc>();
            final result = await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (modalContext) => BlocProvider.value(
                value: parentBloc,
                child: _DraftDetailsSheet(draft: draft, onEdit: () {}, parentContext: context),
              ),
            );
            if (result == 'edit') {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => MainScreen(
                    userName: 'User',
                    editDraft: draft,
                  ),
                ),
                (route) => false,
              );
            }
          },
          // Pass selection state from parent
          isSelectionMode: isSelectionMode,
          isSelected: selectedDraftIds.contains(draft.id),
          onToggleSelection: () => toggleSelection(draft.id),
        )),
      ],
    );
  }
}

class _SummaryRow {
  final DateTime date;
  final int orderCount;
  final List<String> orderNumbers;
  final double discountAmount;
  final double gross;
  final double net;
  final double subTotal;
  _SummaryRow({required this.date, required this.orderCount, required this.orderNumbers, required this.discountAmount, required this.gross, required this.net, required this.subTotal});
}

String _formatDayLabel(DateTime date, DateTime now) {
  if (date.year == now.year && date.month == now.month && date.day == now.day) {
    return 'Today';
  } else if (date.year == now.year && date.month == now.month && date.day == now.day - 1) {
    return 'Previous Day';
  } else {
    return DateFormat('MMM-d').format(date);
  }
}

String _formatDateHeader(String dateKey, DateTime now, DateTime prevDay) {
  final parts = dateKey.split('-');
  if (parts.length != 3) return dateKey;
  final y = int.parse(parts[0]);
  final m = int.parse(parts[1]);
  final d = int.parse(parts[2]);
  final date = DateTime(y, m, d);
  if (date.year == now.year && date.month == now.month && date.day == now.day) {
    return 'Today';
  } else if (date.year == prevDay.year && date.month == prevDay.month && date.day == prevDay.day) {
    return 'Previous Day';
  } else {
    return DateFormat('MMM dd, yyyy').format(date);
  }
}

class _DraftCard extends StatelessWidget {
  final OrderDraft draft;
  final VoidCallback? onEdit;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onToggleSelection;

  const _DraftCard({
    required this.draft, 
    this.onEdit,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onToggleSelection,
  });

  @override
  Widget build(BuildContext context) {
    // Determine card styling based on confirmation status
    final isConfirmed = draft.isConfirmedForProcessing;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8), // less vertical margin
      elevation: isConfirmed ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // slightly tighter corners
        side: BorderSide(
          color: isSelected 
              ? Colors.blue.shade400 
              : isConfirmed 
                  ? Colors.green.shade300 
                  : Colors.grey.shade200,
          width: isSelected ? 3 : isConfirmed ? 2 : 1,
        ),
      ),
      child: Container(
        decoration: isSelected
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.shade50,
                    Colors.white,
                  ],
                ),
              )
            : isConfirmed
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.green.shade50,
                        Colors.white,
                      ],
                    ),
                  )
                : null,
      child: InkWell(
        onTap: isSelectionMode ? onToggleSelection : () => _showDraftDetails(context),
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), // more compact padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Selection checkbox (only in selection mode)
                  if (isSelectionMode) ...[
                    Checkbox(
                      value: isSelected,
                      onChanged: (value) => onToggleSelection(),
                      activeColor: Colors.green,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Row(
                            children: [
                              Expanded(
                                flex: isSelectionMode ? 2 : 3,
                                child: Text(
                                  draft.clientName,
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isConfirmed ? Colors.green.shade800 : null,
                                    fontSize: 14, // slightly smaller
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isConfirmed) ...[
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.green.shade300),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.verified,
                                          size: 10,
                                          color: Colors.green.shade700,
                                        ),
                                        const SizedBox(width: 2),
                                        Flexible(
                                          child: Text(
                                            'R-${draft.id.substring(0, 6).toUpperCase()}',
                                            style: TextStyle(
                                              fontSize: 8,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.green.shade700,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ] else ...[
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.blue.shade100),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.edit_note,
                                          size: 8,
                                          color: Colors.blue.shade700,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          'Draft',
                                          style: TextStyle(
                                            fontSize: 8,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blue.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          // Remove extra vertical space
                          // const SizedBox(height: 4),
                        Text(
                          draft.clientCity,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                              fontSize: 11,
                          ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (!isConfirmed)
                    IconButton(
                      onPressed: () => _deleteDraft(context),
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red[400],
                      tooltip: 'Delete draft',
                      iconSize: 18, // smaller icon
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
                // const SizedBox(height: 12), // remove or shrink
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${draft.items.length} items',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                          fontSize: 11,
                      ),
                    ),
                  ),
                  Text(
                    'Total: ${draft.totalAmount.round()}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                        color: isConfirmed ? Colors.green.shade700 : Colors.blue[700],
                        fontSize: 12,
                    ),
                  ),
                ],
              ),
                // const SizedBox(height: 8), // remove or shrink
                Row(
                  children: [
                    Expanded(
                      child: Text(
                'Created: ${DateFormat('MMM dd, yyyy HH:mm').format(draft.createdAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                          fontSize: 10,
                        ),
                      ),
                    ),
                    if (isConfirmed && draft.confirmedAt != null)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Confirmed: ${DateFormat('MMM dd, yyyy HH:mm').format(draft.confirmedAt!)}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.green.shade600,
                                fontWeight: FontWeight.w500,
                                fontSize: 10,
                              ),
                            ),
                            // Show BO-IDs if available
                            if (draft.exportData != null && draft.exportData!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.green.shade200, width: 0.5),
                                ),
                                child: Text(
                                  'BO: ${draft.exportData!.first['bo_id']}',
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
            ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDraftDetails(BuildContext context) {
    final parentBloc = context.read<OrderDraftBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => BlocProvider.value(
        value: parentBloc,
        child: _DraftDetailsSheet(draft: draft, onEdit: onEdit, parentContext: context),
      ),
    );
  }

  void _deleteDraft(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Draft'),
        content: Text('Are you sure you want to delete the draft for ${draft.clientName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      context.read<OrderDraftBloc>().add(OrderDraftEvent.deleteDraft(draft.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Draft for ${draft.clientName} deleted successfully'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

class _DraftDetailsSheet extends StatefulWidget {
  final OrderDraft draft;
  final VoidCallback? onEdit;
  final BuildContext parentContext;

  const _DraftDetailsSheet({required this.draft, this.onEdit, required this.parentContext});

  @override
  State<_DraftDetailsSheet> createState() => _DraftDetailsSheetState();
}

class _DraftDetailsSheetState extends State<_DraftDetailsSheet> {
  late OrderDraft _currentDraft;
  final OfflineDatabaseService _databaseService = OfflineDatabaseService();
  List<Product> _availableProducts = [];

  @override
  void initState() {
    super.initState();
    _currentDraft = widget.draft;
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _databaseService.getOfflineProducts();
      setState(() {
        _availableProducts = products;
      });
    } catch (e) {
      print('Error loading products: $e');
    }
  }

  void _updateDraft(OrderDraft updatedDraft) {
    final totalAmount = updatedDraft.items.fold(
      0.0,
      (sum, item) => sum + item.totalPrice,
    );

    final draftWithTotal = updatedDraft.copyWith(
      totalAmount: totalAmount,
      updatedAt: DateTime.now(),
    );

    setState(() {
      _currentDraft = draftWithTotal;
    });

    // Auto-save after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _saveDraft();
      }
    });
  }

  void _saveDraft() {
    widget.parentContext.read<OrderDraftBloc>().add(
      OrderDraftEvent.saveDraft(_currentDraft),
    );
  }

  Future<void> _addProduct() async {
    final result = await Navigator.push<List<OrderItem>>(
      context,
      MaterialPageRoute(
        builder: (context) => _ProductSelectionPage(
          products: _availableProducts,
        ),
      ),
    );

    if (result != null && result.isNotEmpty) {
      final updatedItems = List<OrderItem>.from(_currentDraft.items)..addAll(result);
      final updatedDraft = _currentDraft.copyWith(
        items: updatedItems,
        updatedAt: DateTime.now(),
      );
      _updateDraft(updatedDraft);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Added ${result.length} product(s)'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _currentDraft.isConfirmedForProcessing ? Colors.green[50] : Colors.blue[50],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                    children: [
                      Text(
                            _currentDraft.isConfirmedForProcessing ? 'Confirmed Order Details' : 'Draft Details',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                              color: _currentDraft.isConfirmedForProcessing ? Colors.green[800] : Colors.blue[900],
                        ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Created: ${DateFormat('MMM dd, yyyy HH:mm').format(_currentDraft.createdAt)}',
                        style: TextStyle(color: Colors.blue[700]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ClientSection(draft: _currentDraft),
                  const SizedBox(height: 24),
                  _EditableItemsSection(
                    draft: _currentDraft,
                    onDraftUpdated: _updateDraft,
                    onAddProduct: _addProduct,
                    isReadOnly: _currentDraft.isConfirmedForProcessing,
                  ),
                  if (_currentDraft.notes != null && _currentDraft.notes!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _NotesSection(notes: _currentDraft.notes!),
                  ],
                  const SizedBox(height: 24),
                  _TotalSection(total: _currentDraft.totalAmount),
                  const SizedBox(height: 24),
                  _PostOrderSection(draft: _currentDraft, onEdit: widget.onEdit, parentContext: widget.parentContext),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClientSection extends StatelessWidget {
  final OrderDraft draft;

  const _ClientSection({required this.draft});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Client Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _InfoRow(label: 'Name', value: draft.clientName),
          ],
        ),
      ),
    );
  }
}

class _EditableItemsSection extends StatelessWidget {
  final OrderDraft draft;
  final Function(OrderDraft) onDraftUpdated;
  final VoidCallback onAddProduct;
  final bool isReadOnly;

  const _EditableItemsSection({
    required this.draft,
    required this.onDraftUpdated,
    required this.onAddProduct,
    required this.isReadOnly,
  });

  void _deleteItem(int index) {
    final updatedItems = List<OrderItem>.from(draft.items);
    updatedItems.removeAt(index);
    final updatedDraft = draft.copyWith(
      items: updatedItems,
      updatedAt: DateTime.now(),
    );
    onDraftUpdated(updatedDraft);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Order Items',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text('${draft.items.length}'),
                  backgroundColor: Colors.blue.shade50,
                  labelStyle: TextStyle(color: Colors.blue[900]),
                  visualDensity: VisualDensity.compact,
                ),
                const Spacer(),
                if (!isReadOnly)
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.green),
                    tooltip: 'Add Product',
                    onPressed: onAddProduct,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: (draft.items.length * 90.0).clamp(90.0, 350.0), // Responsive max height
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: draft.items.length,
                separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[300]),
                itemBuilder: (context, index) {
                  final item = draft.items[index];
                  return _ItemRow(
                    item: item,
                    onDelete: !isReadOnly ? () => _deleteItem(index) : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final OrderItem item;
  final VoidCallback? onDelete;

  const _ItemRow({required this.item, this.onDelete});

  double _parsePercent(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final v = double.tryParse(value);
      return v ?? 0.0;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final discount = _parsePercent(item.discount);
    final bonus = _parsePercent(item.bonus);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product name header
                Text(
                  item.productName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Data row with columns
                Row(
                  children: [
              // Qty
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Text(
                      'Qty',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.quantity}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                ),
                      textAlign: TextAlign.center,
            ),
          ],
        ),
              ),
              // Bon
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Text(
                      'Bon',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      bonus.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              // Dis%
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Text(
                      'Dis%',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      discount.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              // Price
              Expanded(
                flex: 1,
                child: Column(
              children: [
                    Text(
                      'Price',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.unitPrice.round()}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              // Total
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${item.totalPrice.round()}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade700,
                        ),
                        textAlign: TextAlign.center,
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
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: onDelete,
              tooltip: 'Delete item',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}

class _NotesSection extends StatelessWidget {
  final String notes;

  const _NotesSection({required this.notes});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(notes),
          ],
        ),
      ),
    );
  }
}

class _TotalSection extends StatelessWidget {
  final double total;

  const _TotalSection({required this.total});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(
              'Total Amount:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '${total.round()}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostOrderSection extends StatelessWidget {
  final OrderDraft draft;
  final VoidCallback? onEdit;
  final BuildContext parentContext;

  const _PostOrderSection({required this.draft, this.onEdit, required this.parentContext});

  @override
  Widget build(BuildContext context) {
    // If order is confirmed, show confirmation status instead of action buttons
    if (draft.isConfirmedForProcessing) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.verified,
                  color: Colors.green.shade700,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Order Confirmed for Processing',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'R-${draft.id.substring(0, 8).toUpperCase()}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade600,
              ),
            ),
            if (draft.confirmedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'Confirmed on: ${DateFormat('MMM dd, yyyy HH:mm').format(draft.confirmedAt!)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green.shade600,
                ),
              ),
              // Display BO-IDs if exportData is available
              if (draft.exportData != null && draft.exportData!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📊 Export BO-IDs:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      ...draft.exportData!.map((item) => Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          '• ${item['item_name']}: ${item['bo_id']}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.green.shade600,
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ],
            const SizedBox(height: 8),
            Text(
              'This order has been confirmed and is ready for server processing. No further edits are allowed.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // For non-confirmed orders, return empty since button is now at top
    return const SizedBox.shrink();
  }

  void _showPostOrderConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Post Order'),
        content: Text(
          'Are you sure you want to Post Order for ${draft.clientName}?\n\n'
          'This will:\n'
          '• Mark the order as Post Order for processing\n'
          '• Save it for later server posting\n'
          '• Make the order read-only (no more editing)\n'
          '• Keep it in drafts with Post Order status',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(), // Only close the dialog
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Close the dialog only
              // Now perform post order using the parentContext (modal context)
              _performPostOrder(context, draft); // context here is the modal's context
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Post Order'),
          ),
        ],
      ),
    );
  }

  void _showRepostOrderConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Repost Order'),
        content: Text(
          'Are you sure you want to Repost Order for ${draft.clientName}?\n\n'
          'This will:\n'
          '• Mark the order as Post Order for processing\n'
          '• Save it for later server posting\n'
          '• Make the order read-only (no more editing)\n'
          '• Keep it in drafts with Post Order status',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(), // Only close the dialog
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Close the dialog only
              // Now perform post order using the parentContext (modal context)
              _performPostOrder(context, draft); // context here is the modal's context
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Repost Order'),
          ),
        ],
      ),
    );
  }

  void _editOrderInBookOrderForm(BuildContext context) {
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🔄 Loading order data for ${draft.clientName}...'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 1),
      ),
    );

    // Navigate back to main screen and switch to order tab with draft data
    Future.delayed(const Duration(milliseconds: 500), () {
      // Find the main screen and pass the draft data
      Navigator.of(context).pop(); // Close the modal first
      
      // Navigate back to main screen and switch to order tab
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => MainScreen(
            userName: 'User', // You might want to pass the actual user name
            editDraft: draft,
          ),
        ),
        (route) => false,
      );
    });
  }

  Future<void> sendOrderToServer(OrderDraft draft) async {
    print('==== STEP 1: Starting order posting process ====');
    print('Draft ID: ${draft.id}');
    print('Client Name: ${draft.clientName}');
    print('Client ID: ${draft.clientId}');
    print('Total Items: ${draft.items.length}');
    print('Total Amount: ${draft.totalAmount}');
    
    // Load booking man ID from SharedPreferences
    String bookingManId = '123'; // Default fallback
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedBookingManId = prefs.getString('booking_man_id');
      if (savedBookingManId != null && savedBookingManId.isNotEmpty) {
        bookingManId = savedBookingManId;
      }
      print('Loaded Booking Man ID: $bookingManId');
    } catch (e) {
      print('Error loading booking man ID: $e');
    }
    
    // Generate unique 8-digit BO ID for this entire order
    final uniqueBoId = _OrderDraftsPageState.generateUniqueBoId();
    print('Generated unique BO ID: $uniqueBoId');
    
    // Load available products for proper PRCODE/PCODE mapping
    final databaseService = OfflineDatabaseService();
    List<Product> availableProducts = [];
    try {
      availableProducts = await databaseService.getOfflineProducts();
      print('Loaded ${availableProducts.length} products for mapping');
    } catch (e) {
      print('Error loading products for mapping: $e');
    }
    
    final url = Uri.parse('http://137.59.224.222:8080/postSalOrdersCopy.php');
    final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    print('==== STEP 2: Date being used ====');
    print('V_DATE and EXP_DATE: $dateStr');
    
    print('==== STEP 3: Processing each order item ====');
    final data = draft.items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      
      // Generate unique 8-digit BO ID for this specific product
      final uniqueBoId = _OrderDraftsPageState.generateUniqueBoId();
      
      print('--- Processing Item ${index + 1}: ${item.productName} ---');
      print('  Item ID: ${item.id}');
      print('  BM Code: ${item.bmCode}');
      print('  PR Code: ${item.prCode}');
      print('  Product Code: ${item.productCode}');
      print('  Product Name: ${item.productName}');
      print('  Quantity: ${item.quantity}');
      print('  Unit Price: ${item.unitPrice}');
      print('  Total Price: ${item.totalPrice}');
      print('  Bonus: ${item.bonus ?? 0}');
      print('  Discount: ${item.discount ?? 0}');
      print('  Packing: ${item.packing ?? "N/A"}');
      print('  Unique BO_ID: $uniqueBoId (8-digit format)');
      
      // Find the actual Product entity to get correct prcode and pcode
      Product? selectedProduct;
      
      // Try multiple search strategies to find the product in offline database
      print('  === SEARCHING FOR PRODUCT IN DATABASE ===');
      print('  Available products count: ${availableProducts.length}');
      print('  Searching for: "${item.productName}"');
      print('  OrderItem productCode: "${item.productCode}"');
      print('  OrderItem prCode: "${item.prCode}"');
      
      // Strategy 1: Search by exact product name
      selectedProduct = availableProducts.firstWhereOrNull(
        (p) => p.pname.toLowerCase().trim() == item.productName.toLowerCase().trim(),
      );
      if (selectedProduct != null) {
        print('  ✅ Found by product name: ${selectedProduct.pname}');
      }
      
      // Strategy 2: Search by product code if name search failed
      if (selectedProduct == null) {
        selectedProduct = availableProducts.firstWhereOrNull(
          (p) => p.pcode == item.productCode || p.pcode == item.prCode,
        );
        if (selectedProduct != null) {
          print('  ✅ Found by product code: ${selectedProduct.pcode}');
        }
      }
      
      // Strategy 3: Search by partial name match if exact match failed
      if (selectedProduct == null) {
        selectedProduct = availableProducts.firstWhereOrNull(
          (p) => p.pname.toLowerCase().contains(item.productName.toLowerCase()) ||
                 item.productName.toLowerCase().contains(p.pname.toLowerCase()),
        );
        if (selectedProduct != null) {
          print('  ✅ Found by partial name match: ${selectedProduct.pname}');
        }
      }
      
      // If still not found, this is a critical error - NO DUMMY VALUES ALLOWED
      if (selectedProduct == null) {
        print('  ❌ CRITICAL ERROR: Product not found in offline database!');
        print('  ❌ This should NEVER happen. Check offline data sync.');
        print('  ❌ Available products:');
        availableProducts.take(10).forEach((p) {
          print('    - ${p.pname} (${p.pcode}) [${p.prcode}]');
        });
        
        // Instead of dummy values, throw an error
        throw Exception('CRITICAL: Product "${item.productName}" not found in offline database. '
            'Please sync offline data before submitting orders. '
            'This prevents sending incorrect product codes to server.');
      }
      
      print('  === PRODUCT MAPPING DEBUG ===');
      print('  OrderItem prCode: ${item.prCode}');
      print('  OrderItem productCode: ${item.productCode}');
      print('  OrderItem unitPrice: ${item.unitPrice}');
      print('  Selected Product PRCODE: ${selectedProduct.prcode}');
      print('  Selected Product PCODE: ${selectedProduct.pcode}');
      print('  Selected Product TPRICE: ${selectedProduct.tprice}');
      print('  Final TPRICE value: ${double.tryParse(selectedProduct.tprice) ?? item.unitPrice}');
      print('  ==============================');
      
      final itemData = {
        'BO_ID': uniqueBoId, // Unique 8-digit ID: first 4 digits (order) + last 4 digits (product)
        'V_DATE': dateStr,
        'BMCODE': int.tryParse(bookingManId) ?? 123, // Use booking man ID from login3
        'CLIENTCODE': draft.clientId,
        'TCODE': null, // Not present in model
        'TSCODE': null, // Not present in model
        'CCODE': null, // Not present in model
        'PRCODE': selectedProduct.prcode, // Use actual Product prcode from database
        'PCODE': selectedProduct.pcode,   // Use actual Product pcode from database
        'PNAME': selectedProduct.pname,   // Use actual Product name from database
        'QNTY': item.quantity,
        'BQNTY': item.bonus ?? 0,
        'ODISC': item.discount ?? 0,
        'AMOUNT': item.totalPrice,
        'ORD_STATUS': null, // Not present in model
        'TPRICE': double.tryParse(selectedProduct.tprice) ?? item.unitPrice, // Use actual product price from database
        'BTHNO': null, // Not present in model
        'EXP_DATE': dateStr, // Use current date as fallback
        'RATE_ID': null, // Not present in model
        'ORDER_REFRENCE': 1122, // Fixed value as requested
      };
      
      print('  --- Final item data for database ---');
      itemData.forEach((key, value) {
        print('    $key: $value');
      });
      print('  --- End item data ---');
      
      return itemData;
    }).toList();
    
    final body = {
      'allSOrders': jsonEncode({'data': data}),
    };
    
    print('==== STEP 4: Complete payload being sent ====');
    print('URL: $url');
    print('Body structure:');
    print(const JsonEncoder.withIndent('  ').convert({'data': data}));
    print('==== END DEBUG ====');
    
    try {
      print('==== STEP 5: Sending HTTP POST request ====');
      final response = await http.post(url, body: body);
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      
      // Check if context is still mounted before showing snackbar
      if (parentContext.mounted) {
        if (response.statusCode == 200 && response.body.toLowerCase().contains('successful')) {
          ScaffoldMessenger.of(parentContext).showSnackBar(
            const SnackBar(
              content: Text('✅ Order posted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(parentContext).showSnackBar(
            SnackBar(
              content: Text('❌ Server error: ${response.body}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('==== ERROR: Network error occurred ====');
      print('Error details: ${e.toString()}');
      // Check if context is still mounted before showing snackbar
      if (parentContext.mounted) {
        ScaffoldMessenger.of(parentContext).showSnackBar(
          SnackBar(
            content: Text('❌ Network error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _performPostOrder(BuildContext context, OrderDraft draft) {
    print('=== PERFORMING POST ORDER ===');
    print('Draft ID: ${draft.id}');
    print('Client Name: ${draft.clientName}');
    print('Is Confirmed: ${draft.isConfirmedForProcessing}');
    
    // Show loading indicator using parentContext
    ScaffoldMessenger.of(parentContext).showSnackBar(
      const SnackBar(
        content: Text('🔄 Confirming order for processing...'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );

    try {
      // Confirm the draft for processing
      print('Adding confirm event to bloc...');
      parentContext.read<OrderDraftBloc>().add(OrderDraftEvent.confirmDraftForProcessing(draft));
      print('Confirm event added successfully');
      sendOrderToServer(draft); // Send to PHP endpoint
      
      // Show success message using parentContext
      ScaffoldMessenger.of(parentContext).showSnackBar(
        SnackBar(
          content: Text('✅ Post Order processed: ${draft.clientName}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
      print('About to close modal and return to draft screen...');
      // Now close the modal only (not the main page)
      Navigator.of(context).pop();
      print('Modal closed. Should be back on draft screen.');
    } catch (e) {
      print('Error in _performPostOrder: $e');
      ScaffoldMessenger.of(parentContext).showSnackBar(
        SnackBar(
          content: Text('❌ Error processing Post Order:'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

class _EnhancedLoadingView extends StatelessWidget {
  const _EnhancedLoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Loading drafts... Please wait.',
            style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// Helper class to track pending products
class _PendingProduct {
  final Product product;
  final double quantity;
  final double discount;
  final double bonus;

  _PendingProduct({
    required this.product,
    required this.quantity,
    required this.discount,
    required this.bonus,
  });
}

class _ProductSelectionPage extends StatefulWidget {
  final List<Product> products;

  const _ProductSelectionPage({required this.products});

  @override
  State<_ProductSelectionPage> createState() => _ProductSelectionPageState();
}

class _ProductSelectionPageState extends State<_ProductSelectionPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController(text: '1');
  final TextEditingController _discountController = TextEditingController(text: '0');
  final TextEditingController _bonusController = TextEditingController(text: '0');
  final FocusNode _qtyFocusNode = FocusNode();
  Product? _selectedProduct;
  List<Product> _filteredProducts = [];
  List<_PendingProduct> _pendingProducts = []; // Track multiple products

  @override
  void initState() {
    super.initState();
    _filteredProducts = widget.products;
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _qtyController.dispose();
    _discountController.dispose();
    _bonusController.dispose();
    _qtyFocusNode.dispose();
    super.dispose();
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = widget.products.where((product) {
        return product.pname.toLowerCase().contains(query) ||
            product.pcode.toLowerCase().contains(query) ||
            product.prcode.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _addToPendingList() {
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Please select a product'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final quantity = double.tryParse(_qtyController.text) ?? 0.0;
    if (quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Please enter a valid quantity'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final discount = double.tryParse(_discountController.text) ?? 0.0;
    final bonus = double.tryParse(_bonusController.text) ?? 0.0;

    setState(() {
      _pendingProducts.add(_PendingProduct(
        product: _selectedProduct!,
        quantity: quantity,
        discount: discount,
        bonus: bonus,
      ));
      // Clear selection for next product
      _selectedProduct = null;
      _qtyController.text = '1';
      _discountController.text = '0';
      _bonusController.text = '0';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Added to list (${_pendingProducts.length} item(s))'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _removeFromPendingList(int index) {
    setState(() {
      _pendingProducts.removeAt(index);
    });
  }

  void _confirmProduct() {
    // If there's a selected product but not added to pending list, add it first
    if (_selectedProduct != null) {
      _addToPendingList();
    }

    if (_pendingProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Please add at least one product'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Convert all pending products to OrderItems
    final List<OrderItem> orderItems = _pendingProducts.map((pending) {
      final unitPrice = double.tryParse(pending.product.tprice) ?? 0.0;
      final baseTotal = pending.quantity * unitPrice;
      final discountAmount = baseTotal * (pending.discount / 100);
      final bonusAmount = pending.bonus * unitPrice;
      final totalPrice = baseTotal - discountAmount - bonusAmount;

      return OrderItem(
        id: '${DateTime.now().millisecondsSinceEpoch}_${pending.product.pcode}',
        bmCode: 'SRC-1',
        prCode: pending.product.prcode,
        productId: pending.product.pcode,
        productName: pending.product.pname,
        productCode: pending.product.pcode,
        unitPrice: unitPrice,
        quantity: pending.quantity.toInt(),
        totalPrice: totalPrice > 0 ? totalPrice : 0,
        discount: pending.discount,
        bonus: pending.bonus,
        packing: pending.product.packing ?? 'Tab',
      );
    }).toList();

    Navigator.of(context).pop(orderItems);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or code...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_selectedProduct != null) ...[
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected: ${_selectedProduct!.pname}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _qtyController,
                              focusNode: _qtyFocusNode,
                              decoration: const InputDecoration(
                                labelText: 'Quantity',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _discountController,
                              decoration: const InputDecoration(
                                labelText: 'Discount %',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _bonusController,
                              decoration: const InputDecoration(
                                labelText: 'Bonus',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _addToPendingList,
                        icon: const Icon(Icons.add),
                        label: const Text('Add to List'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            // Show pending products list
            if (_pendingProducts.isNotEmpty) ...[
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Pending Products',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text('${_pendingProducts.length}'),
                            backgroundColor: Colors.green.shade100,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ..._pendingProducts.asMap().entries.map((entry) {
                        final index = entry.key;
                        final pending = entry.value;
                        return ListTile(
                          dense: true,
                          title: Text(pending.product.pname),
                          subtitle: Text(
                            'Qty: ${pending.quantity.toInt()} | '
                            'Dis: ${pending.discount}% | '
                            'Bon: ${pending.bonus}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeFromPendingList(index),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Expanded(
              child: _filteredProducts.isEmpty
                  ? const Center(child: Text('No products found'))
                  : ListView.builder(
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        final isSelected = _selectedProduct?.pcode == product.pcode;
                        final price = double.tryParse(product.tprice) ?? 0.0;
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color: isSelected ? Colors.blue.shade50 : null,
                          child: ListTile(
                            title: Text(product.pname),
                            subtitle: Text(
                              'Code: ${product.pcode} | Price: ${price.toStringAsFixed(0)}',
                            ),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle, color: Colors.green)
                                : const Icon(Icons.add_circle),
                            onTap: () {
                              setState(() {
                                _selectedProduct = product;
                                _qtyController.text = '1';
                                _discountController.text = '0';
                                _bonusController.text = '0';
                              });
                              // Move focus to quantity field after product selection
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _qtyFocusNode.requestFocus();
                                // Select all text for easy editing
                                _qtyController.selection = TextSelection(
                                  baseOffset: 0,
                                  extentOffset: _qtyController.text.length,
                                );
                              });
                            },
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _confirmProduct,
                  child: Text(_pendingProducts.isEmpty 
                    ? 'Add Product' 
                    : 'Add All Products (${_pendingProducts.length})'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
