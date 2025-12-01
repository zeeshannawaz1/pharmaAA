import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/products/presentation/pages/products_layout_selector.dart';
import 'features/products/presentation/bloc/products_bloc.dart';
import 'features/products/presentation/bloc/products_event.dart';
import 'features/products/data/datasources/products_remote_data_source.dart';
import 'features/products/data/repositories/products_repository_impl.dart';
import 'features/products/domain/usecases/get_products.dart';
import 'features/reports/presentation/pages/enhanced_reports_page.dart';
import 'features/reports/presentation/pages/reports_page.dart';

import 'features/sales_order/presentation/pages/order_drafts_page.dart';
import 'features/sales_order/presentation/bloc/order_draft_bloc.dart';
import 'core/widgets/main_app_widget.dart';
import 'core/services/offline_sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/utils/constants.dart';
import 'package:aa_app/core/database/offline_database_service.dart';
import 'features/sales_order/domain/entities/client.dart';
import 'features/sales_order/domain/entities/product.dart';
import 'features/sales_order/domain/entities/order_draft.dart';
import 'features/sales_order/presentation/bloc/order_draft_bloc.dart';
import 'injection_container.dart';
import 'package:uuid/uuid.dart';
import 'core/services/auth_service.dart';
import 'features/auth/presentation/pages/user_configuration_page.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'features/sales_order/presentation/pages/new_order_form_page.dart';

import 'core/services/town_area_service.dart';
import 'package:collection/collection.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:aa_app/main.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'features/reports/porder_page.dart';
import 'features/sales_order/presentation/pages/confirmed_orders_page.dart';
import 'core/services/auth_service.dart';
import 'features/insights/presentation/pages/insights_page.dart';
import 'core/widgets/location_tracker_widget.dart';

class MainScreen extends StatefulWidget {
  final String userName;
  final OrderDraft? editDraft;

  const MainScreen({Key? key, required this.userName, this.editDraft}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _isAdmin1 = false;

  // Global state for order form
  List<Client> _orderClients = [];
  List<Product> _orderProducts = [];
  bool _orderLoading = true;
  String? _selectedClientCode;
  Client? _selectedClient;
  String _clientSearch = '';
  List<_OrderLine> _orderLines = [ _OrderLine()..bonus = 0 ];
  final TextEditingController _clientController = TextEditingController();
  final FocusNode _clientFocusNode = FocusNode();
  final _uuid = const Uuid();
  OrderDraft? _lastSavedDraft;

  static const String _lastSyncKey = 'lastSyncTimestamp';

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
    // _loadOrderData(); // Removed for optimization
    // If editing a draft, switch to order tab and load the draft
    if (widget.editDraft != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _selectedIndex = 1; // Switch to order tab
        });
        // Ensure data is loaded before loading draft
        if (_orderClients.isEmpty || _orderProducts.isEmpty) {
          _loadOrderData().then((_) {
        _loadDraftIntoForm(widget.editDraft!);
          });
        } else {
          _loadDraftIntoForm(widget.editDraft!);
        }
      });
    }
    // Removed: WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _extractCities();
    // });
  }

  Future<void> _checkAdminStatus() async {
    final currentUserName = await AuthService.getCurrentUserName();
    setState(() {
      _isAdmin1 = currentUserName == 'Admin1';
    });
    print('Admin status checked: $_isAdmin1 (User: $currentUserName)');
  }

  Future<void> _loadOrderData() async {
    try {
    setState(() => _orderLoading = true);
      
      print('Loading order data...');
    final clients = await OfflineDatabaseService().getOfflineClients();
      print('Loaded ${clients.length} clients');
      
    final products = await OfflineDatabaseService().getOfflineProducts();
      print('Loaded ${products.length} products');
      
    setState(() {
      _orderClients = clients;
      _orderProducts = products;
      _orderLoading = false;
    });
      
      print('Order data loading completed successfully');
    } catch (e) {
      print('Error loading order data: $e');
      setState(() {
        _orderLoading = false;
        _orderClients = [];
        _orderProducts = [];
      });
      
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _addOrderLine() {
    setState(() { _orderLines.add(_OrderLine()..bonus = 0); });
  }

  void _removeOrderLine(int index) {
    if (_orderLines.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot remove the last item. Add another item first.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Item'),
          content: Text('Are you sure you want to remove this item?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() { 
                  _orderLines.removeAt(index); 
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Item removed'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  double _calculateTotalWithDiscount(_OrderLine line) {
    double baseAmount = line.quantity * line.price;
    double discountAmount = baseAmount * ((line.discount ?? 0.0) / 100.0);
    double finalTotal = baseAmount - discountAmount;
    return finalTotal;
  }

  double get _orderSubtotal => _orderLines.fold(0, (sum, line) => sum + _calculateTotalWithDiscount(line));

  double _calcProductTotal(_OrderLine line) {
    final qty = line.qty ?? 0;
    final rate = line.rate ?? 0.0;
    final dis = line.discount ?? 0.0;
    final total = qty * rate;
    return total - ((total * dis) / 100);
  }

  void _refreshOrderForm() {
    setState(() {
      // Reset form to initial state
      _selectedClientCode = null;
      _selectedClient = null;
      _clientSearch = '';
      _orderLines = [_OrderLine()..bonus = 0]; // Reset to single empty line
      _clientController.clear();
      _lastSavedDraft = null; // Clear the last saved draft card
    });
  }

  void _loadDraftIntoForm(OrderDraft draft) {
    print('=== LOADING DRAFT INTO FORM ===');
    print('Draft ID: ${draft.id}');
    print('Client ID: ${draft.clientId}');
    print('Client Name: ${draft.clientName}');
    print('Number of items: ${draft.items.length}');
    // Try to extract area from the first item if available
    String draftArea = '';
    if (draft.items.isNotEmpty) {
      draftArea = draft.items.first.packing ?? '';
    }
    // Find the exact client instance from _orderClients
    final matchingClient = _orderClients.firstWhere(
      (c) => c.code == draft.clientId,
      orElse: () => Client(
        code: draft.clientId,
        name: draft.clientName,
        address: '',
        city: draft.clientCity,
        area: draftArea,
      ),
      );
    setState(() {
      _selectedClient = matchingClient;
      _selectedClientCode = draft.clientId;
      _clientController.text = draft.clientName;
      _orderLines = draft.items.map((item) {
        print('Processing item: ${item.productName} (${item.productCode})');
        
        // Search in offline database for the product - NO DUMMY VALUES ALLOWED
        print('  === SEARCHING FOR PRODUCT IN _orderProducts ===');
        print('  Available products count: ${_orderProducts.length}');
        print('  Searching for: "${item.productName}"');
        print('  Item productCode: "${item.productCode}"');
        print('  Item productId: "${item.productId}"');
        
        Product? foundProduct = _orderProducts.firstWhereOrNull(
          (p) => p.pname.toLowerCase().trim() == item.productName.toLowerCase().trim() ||
                 p.pcode == item.productCode ||
                 p.pcode == item.productId,
        );
        
        if (foundProduct == null) {
          print('  ❌ CRITICAL ERROR: Product not found in _orderProducts!');
          print('  ❌ Available products:');
          _orderProducts.take(10).forEach((p) {
            print('    - ${p.pname} (${p.pcode}) [${p.prcode}]');
          });
          
          // Instead of dummy values, throw an error
          throw Exception('CRITICAL: Product "${item.productName}" not found in offline database. '
              'Please sync offline data before loading draft. '
              'This prevents using incorrect product codes.');
        }
        
        print('  ✅ Found product: ${foundProduct.pname} (${foundProduct.pcode}) [${foundProduct.prcode}]');
        
        final orderLine = _OrderLine()
          ..productCode = item.productCode
          ..productName = item.productName
          ..packing = item.packing
          ..quantity = item.quantity.toDouble()
          ..price = item.unitPrice
          ..discount = item.discount ?? 0
          ..bonus = item.bonus ?? 0
          ..totalAmount = item.totalPrice
          ..product = foundProduct; // Store the actual Product entity
        print('Created order line: ${orderLine.productName} (${orderLine.productCode})');
        return orderLine;
      }).toList();
      _orderLines.add(_OrderLine()..bonus = 0);
      _lastSavedDraft = draft;
      print('Final order lines count: ${_orderLines.length}');
    });
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Loaded draft for ${draft.clientName} - You can now add more items'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showDraftDetails(BuildContext context, OrderDraft draft) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DraftDetailsSheet(draft: draft),
    );
  }

  // Method to ensure all order lines have valid Product entities
  void _ensureAllLinesHaveProducts() {
    print('=== ENSURING ALL LINES HAVE PRODUCTS ===');
    for (int i = 0; i < _orderLines.length; i++) {
      final line = _orderLines[i];
      if (line.productName.isNotEmpty && line.product == null) {
        print('Line $i missing Product entity for "${line.productName}". Searching...');
        
        // Try to find the product in _orderProducts
        Product? foundProduct = _orderProducts.firstWhereOrNull(
          (p) => p.pname.toLowerCase().trim() == line.productName.toLowerCase().trim() ||
                 p.pcode == line.productCode,
        );
        
        if (foundProduct != null) {
          line.product = foundProduct;
          print('✅ Fixed line $i: Set Product entity for "${foundProduct.pname}"');
        } else {
          print('❌ Could not find Product entity for line $i: "${line.productName}"');
        }
      }
    }
    print('=== PRODUCT ENTITY CHECK COMPLETE ===');
  }

  void _saveOrderDraft(BuildContext context) {
    if (_selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a client first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Ensure all lines have Product entities before saving
    _ensureAllLinesHaveProducts();

    final bookingManCode = 'SRC-1'; // TODO: Replace with actual user code
    final orderItems = _orderLines
        .where((line) => line.productCode.isNotEmpty && line.quantity > 0)
        .map((line) {
          // Use the Product entity stored in the line - NO DUMMY VALUES ALLOWED
          if (line.product == null) {
            // Show more helpful error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ Product "${line.productName}" missing from database. Please sync offline data and try again.'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'SYNC DATA',
                  textColor: Colors.white,
                  onPressed: () {
                    _syncOfflineData();
                  },
                ),
              ),
            );
            throw Exception('CRITICAL: Product "${line.productName}" not found in offline database. '
                'Please sync offline data before saving orders. '
                'Product entity missing for line.');
          }
          
          final actualProduct = line.product!;
          
          print('=== MAIN SCREEN ORDER ITEM DEBUG ===');
          print('Line Product Code: ${line.productCode}');
          print('Line Product Name: ${line.productName}');
          print('Actual Product PRCODE: ${actualProduct.prcode}');
          print('Actual Product PCODE: ${actualProduct.pcode}');
          print('Actual Product TPRICE: ${actualProduct.tprice}');
          print('=====================================');
          
          return OrderItem(
            id: _uuid.v4(),
            bmCode: bookingManCode,
            prCode: actualProduct.prcode, // Use actual prcode from Product entity
            productId: actualProduct.pcode, // Use actual pcode as productId
            productName: actualProduct.pname,
            productCode: actualProduct.pcode, // Use actual pcode from Product entity
            unitPrice: line.price,
            quantity: line.quantity.toInt(),
            totalPrice: line.quantity * line.price,
            discount: line.discount ?? 0,
            bonus: line.bonus ?? 0,
            packing: line.packing,
          );
        })
        .toList();

    if (orderItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one product to save as draft'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final draft = OrderDraft(
      id: _lastSavedDraft?.id ?? _uuid.v4(), // Use existing ID if editing
      clientId: _selectedClient!.code,
      clientName: _selectedClient!.name,
      clientCity: _selectedClient!.city,
      items: orderItems,
      totalAmount: orderItems.fold(0.0, (sum, item) => sum + item.totalPrice),
      createdAt: _lastSavedDraft?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    context.read<OrderDraftBloc>().add(OrderDraftEvent.saveDraft(draft));

    setState(() {
      _lastSavedDraft = draft;
    });

    // Show success message with view draft and refresh options
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Order draft saved successfully'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 6),
        action: SnackBarAction(
          label: 'View Draft',
          textColor: Colors.white,
          onPressed: () {
            _showDraftDetails(context, draft);
          },
        ),
      ),
    );
    
    // Show additional action buttons
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _DraftActionSheet(
          draft: draft,
          onViewDraft: () => _showDraftDetails(context, draft),
          onNewOrder: () {
            Navigator.of(context).pop();
            _refreshOrderForm();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Form refreshed for new order'),
                backgroundColor: Colors.blue,
                duration: Duration(seconds: 2),
              ),
            );
          },
      ),
    );
    });

    // Automatically refresh the order entry form for new data entry
    _refreshOrderForm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
        body: _buildCurrentPage(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          print('[DEBUG] BottomNav tapped: ' + index.toString());
          // Run async logic after UI update
          Future.microtask(() async {
            await maybeShowInterstitialAd();
            // If switching to order tab and data is not loaded, load it
            if (index == 1 && (_orderClients.isEmpty || _orderProducts.isEmpty) && !_orderLoading) {
              _loadOrderData();
            }
          });
          },
          type: BottomNavigationBarType.fixed,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Order',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.note_add),
              label: 'Drafts',
            ),
            // Only show POrder for admin1 users
            if (_isAdmin1)
              const BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in),
            label: 'POrder',
          ),
          ],
        ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildFloatingActionButton() {
    // Hide floating action button for all tabs
    return const SizedBox.shrink();
  }

  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return _DashboardContent(userName: widget.userName, onSync: () => _showSyncDialog(context));
      case 1:
        return BlocProvider(
          create: (context) => sl<OrderDraftBloc>()..add(const OrderDraftEvent.loadDrafts()),
          child: Column(
            children: [
              Expanded(
                child: OrderPage(
          clients: _orderClients,
          products: _orderProducts,
          loading: _orderLoading,
          selectedClientCode: _selectedClientCode,
          selectedClient: _selectedClient,
          clientSearch: _clientSearch,
          orderLines: _orderLines,
          clientController: _clientController,
          clientFocusNode: _clientFocusNode,
          lastSavedDraft: _lastSavedDraft,
          onClientSearchChanged: (value) => setState(() => _clientSearch = value),
          onClientSelected: (client) => setState(() {
            _selectedClientCode = client.code;
            _selectedClient = client;
            _clientController.text = client.name;
          }),
          onOrderLineChanged: (index, line) => setState(() {
            _orderLines[index] = line;
          }),
          onAddLine: _addOrderLine,
          onRemoveLine: _removeOrderLine,
          onSaveDraft: _saveOrderDraft,
          onLoadDraft: _loadDraftIntoForm,
          onRefreshData: _loadOrderData,
          calcProductTotal: _calcProductTotal,
          subtotal: _orderSubtotal,
                  initialSelectedCity: _selectedClient?.city ?? '',
                  initialSelectedArea: _selectedClient?.area ?? '',
                  initialSelectedClient: _selectedClient,
                ),
              ),
              FutureBuilder<bool>(
                future: fetchShowAdsFlag(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox.shrink();
                  }
                  if (snapshot.data == true) {
                    return const BannerAdWidget();
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ),
            ],
          ),
        );
      case 2:
        return Column(
          children: [
            const Expanded(child: OrderDraftsPage()),
            FutureBuilder<bool>(
              future: fetchShowAdsFlag(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox.shrink();
                }
                if (snapshot.data == true) {
                  return const BannerAdWidget();
                } else {
                  return SizedBox.shrink();
                }
              },
            ),
          ],
        );
      case 3:
        // POrder tab - only available for admin1 users
        if (_isAdmin1) {
          return const ConfirmedOrdersPage();
                } else {
          // If non-admin1 user somehow reaches this index, redirect to dashboard
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _selectedIndex = 0;
            });
          });
          return _DashboardContent(userName: widget.userName, onSync: () => _showSyncDialog(context));
        }
      default:
        return _DashboardContent(userName: widget.userName, onSync: () => _showSyncDialog(context));
    }
  }

  void _showSyncDialog(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    // Remove sync throttle: allow sync at any time
    // final lastSyncMillis = prefs.getInt(_lastSyncKey);
    // DateTime? lastSyncTime = lastSyncMillis != null ? DateTime.fromMillisecondsSinceEpoch(lastSyncMillis) : null;
    // final now = DateTime.now();
    // final canSync = lastSyncTime == null || now.difference(lastSyncTime) > Duration(minutes: 15);
    // if (!canSync) {
    //   final minsAgo = now.difference(lastSyncTime!).inMinutes;
    //   showDialog(
    //     context: context,
    //     builder: (context) => AlertDialog(
    //       title: const Text('Sync Not Needed'),
    //       content: Text('Data was already synced $minsAgo minutes ago. Please wait before syncing again.'),
    //       actions: [
    //         TextButton(
    //           onPressed: () => Navigator.of(context).pop(),
    //           child: const Text('OK'),
    //         ),
    //       ],
    //     ),
    //   );
    //   return;
    // }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        String progressMessage = 'Preparing...';
        bool isError = false;
        bool isSyncing = true;
        Map<String, dynamic>? syncResult;
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> _startSync() async {
              final syncService = OfflineSyncService();
              setState(() {
                progressMessage = 'Starting sync...';
                isSyncing = true;
                syncResult = null;
              });
              final result = await syncService.syncOfflineData(
                baseUrl: 'http://137.59.224.222:8080',
                onProgress: (msg, {error, progress, total}) {
                  setState(() {
                    isError = error == true;
                    progressMessage = msg;
                  });
                },
              );
              if (result['success'] == true) {
                await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
              }
              setState(() {
                progressMessage = result['success'] == true
                  ? 'Sync complete!\n' + (result['message'] ?? '')
                  : 'Sync failed!\n' + (result['message'] ?? '');
                isError = result['success'] != true;
                isSyncing = false;
                syncResult = result;
              });
              if (result['success'] == false && result['message'] != null &&
                  (result['message'].contains('No route to host') ||
                   result['message'].contains('Failed host lookup') ||
                   result['message'].contains('No internet'))
              ) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Server is not available. Please check your connection or try again later.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            }
            // Start sync only once
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (progressMessage == 'Preparing...') _startSync();
            });
            return AlertDialog(
              title: Text('Offline Data Sync'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isSyncing) ...[
                    const LinearProgressIndicator(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(progressMessage)),
                      ],
                    ),
                  ] else ...[
                    Text(progressMessage),
                    if (syncResult != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: syncResult!['success'] 
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              syncResult!['success'] ? 'Sync Completed' : 'Sync Failed',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: syncResult!['success'] ? Colors.green : Colors.red,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Products synced: ${syncResult!['products_synced']}'),
                            Text('Clients synced: ${syncResult!['clients_synced']}'),
                            Text('Stock items synced: ${syncResult!['stock_synced'] ?? 0}'),
                              if (syncResult!.containsKey('client_area_count'))
                                Text('Client areas: ${syncResult!['client_area_count']}'),
                              if (syncResult!.containsKey('client_city_count'))
                                Text('Client cities: ${syncResult!['client_city_count']}'),
                          ],
                        ),
                      ),
                    ],
                  ],
                ],
              ),
              actions: [
                if (!isSyncing) ...[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                  if (syncResult != null && !syncResult!['success'])
                    TextButton(
                      onPressed: () {
                        setState(() {
                          syncResult = null;
                          isSyncing = true;
                        });
                        _startSync();
                      },
                      child: const Text('Retry'),
                    ),
                ],
              ],
            );
          },
        );
      },
    );
  }

  // Method to trigger offline data sync from error handlers
  Future<void> _syncOfflineData() async {
    try {
      final syncService = OfflineSyncService();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔄 Starting offline data sync...'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
      
      final result = await syncService.syncOfflineData(
        baseUrl: 'http://137.59.224.222:8080',
        onProgress: (msg, {error, progress, total}) {
          print('Sync progress: $msg');
        },
      );
      
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Sync completed! Synced ${result['products_synced']} products'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        // Reload order data after successful sync
        _loadOrderData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Sync failed: ${result['message']}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Sync error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

class OrderPage extends StatelessWidget {
  final List<Client> clients;
  final List<Product> products;
  final bool loading;
  final String? selectedClientCode;
  final Client? selectedClient;
  final String clientSearch;
  final List<_OrderLine> orderLines;
  final TextEditingController clientController;
  final FocusNode clientFocusNode;
  final OrderDraft? lastSavedDraft;
  final Function(String) onClientSearchChanged;
  final Function(Client) onClientSelected;
  final Function(int, _OrderLine) onOrderLineChanged;
  final VoidCallback onAddLine;
  final Function(int) onRemoveLine;
  final Function(BuildContext) onSaveDraft;
  final Function(OrderDraft) onLoadDraft;
  final VoidCallback onRefreshData;
  final double Function(_OrderLine) calcProductTotal;
  final double subtotal;
  final String? initialSelectedCity;
  final String? initialSelectedArea;
  final Client? initialSelectedClient;

  static const String _cityPrefsKey = 'src_cities';

  const OrderPage({
    Key? key,
    required this.clients,
    required this.products,
    required this.loading,
    required this.selectedClientCode,
    required this.selectedClient,
    required this.clientSearch,
    required this.orderLines,
    required this.clientController,
    required this.clientFocusNode,
    required this.lastSavedDraft,
    required this.onClientSearchChanged,
    required this.onClientSelected,
    required this.onOrderLineChanged,
    required this.onAddLine,
    required this.onRemoveLine,
    required this.onSaveDraft,
    required this.onLoadDraft,
    required this.onRefreshData,
    required this.calcProductTotal,
    required this.subtotal,
    this.initialSelectedCity,
    this.initialSelectedArea,
    this.initialSelectedClient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _OrderPageContent(
      // pass all required fields
      clients: clients,
      products: products,
      loading: loading,
      selectedClientCode: selectedClientCode,
      selectedClient: selectedClient,
      clientSearch: clientSearch,
      orderLines: orderLines,
      clientController: clientController,
      clientFocusNode: clientFocusNode,
      lastSavedDraft: lastSavedDraft,
      onClientSearchChanged: onClientSearchChanged,
      onClientSelected: onClientSelected,
      onOrderLineChanged: onOrderLineChanged,
      onAddLine: onAddLine,
      onRemoveLine: onRemoveLine,
      onSaveDraft: onSaveDraft,
      onLoadDraft: onLoadDraft,
      onRefreshData: onRefreshData,
      calcProductTotal: calcProductTotal,
      subtotal: subtotal,
      initialSelectedCity: initialSelectedCity,
      initialSelectedArea: initialSelectedArea,
      initialSelectedClient: initialSelectedClient,
    );
  }
}

class _OrderPageContent extends StatefulWidget {
  final List<Client> clients;
  final List<Product> products;
  final bool loading;
  final String? selectedClientCode;
  final Client? selectedClient;
  final String clientSearch;
  final List<_OrderLine> orderLines;
  final TextEditingController clientController;
  final FocusNode clientFocusNode;
  final OrderDraft? lastSavedDraft;
  final Function(String) onClientSearchChanged;
  final Function(Client) onClientSelected;
  final Function(int, _OrderLine) onOrderLineChanged;
  final VoidCallback onAddLine;
  final Function(int) onRemoveLine;
  final Function(BuildContext) onSaveDraft;
  final Function(OrderDraft) onLoadDraft;
  final VoidCallback onRefreshData;
  final double Function(_OrderLine) calcProductTotal;
  final double subtotal;
  final String? initialSelectedCity;
  final String? initialSelectedArea;
  final Client? initialSelectedClient;

  const _OrderPageContent({
    Key? key,
    required this.clients,
    required this.products,
    required this.loading,
    required this.selectedClientCode,
    required this.selectedClient,
    required this.clientSearch,
    required this.orderLines,
    required this.clientController,
    required this.clientFocusNode,
    required this.lastSavedDraft,
    required this.onClientSearchChanged,
    required this.onClientSelected,
    required this.onOrderLineChanged,
    required this.onAddLine,
    required this.onRemoveLine,
    required this.onSaveDraft,
    required this.onLoadDraft,
    required this.onRefreshData,
    required this.calcProductTotal,
    required this.subtotal,
    this.initialSelectedCity,
    this.initialSelectedArea,
    this.initialSelectedClient,
  }) : super(key: key);

  @override
  State<_OrderPageContent> createState() => _OrderPageContentState();
}

class _OrderPageContentState extends State<_OrderPageContent> {
  // Calculate total with discount for a given order line
  double _calculateTotalWithDiscount(_OrderLine line) {
    double baseAmount = line.quantity * line.price;
    double discountAmount = baseAmount * ((line.discount ?? 0.0) / 100.0);
    double finalTotal = baseAmount - discountAmount;
    return finalTotal;
  }

  List<Client> _clients = [];
  List<Product> _products = [];
  List<Client> _filteredClients = [];
  List<Product> _filteredProducts = [];
  bool _isDraftExpanded = false;

  // Hierarchical selection state
  String? _selectedCity;
  String? _selectedArea;
  Client? _selectedClient;
  List<String> _cities = [];
  List<String> _areas = [];
  List<String> _filteredAreas = []; // For area search
  bool _loadingCities = false;
  String? _citiesError;
  List<Map<String, String>> _allAreas = [];
  List<Map<String, String>> _allClients = [];
  
  // Controllers for search fields
  final TextEditingController _areaSearchController = TextEditingController();
  final FocusNode _areaFocusNode = FocusNode();

  Future<void> _loadAreas() async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final file = File('${appDocDir.path}/offline_data/getclientarea.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> data = json.decode(content);
        _allAreas = data.map((e) => {
          'AREACODE': e['AREACODE']?.toString() ?? '',
          'AREANAME': e['AREANAME']?.toString() ?? '',
        }).toList();
        print('DEBUG: Loaded all areas: count =  {_allAreas.length}');
      } else {
        _allAreas = [];
        print('DEBUG: getclientarea.json not found');
      }
    } catch (e) {
      _allAreas = [];
      print('DEBUG: Failed to load areas:  {e.toString()}');
    }
  }

  Future<void> _loadClients() async {
    try {
      // Load clients from SQLite instead of JSON
      final clients = await OfflineDatabaseService().getOfflineClients();
      print('[DEBUG] Clients from SQLite: [36m${clients.length}[0m');
      
      // Check for duplicates
      final duplicates = await OfflineDatabaseService().checkDuplicateClients();
      if (duplicates.isNotEmpty) {
        print('[DEBUG][WARNING] Found duplicate clients: $duplicates');
      }
      
      for (var c in clients.take(5)) {
        print('  code: [36m${c.code}[0m, name: [36m${c.name}[0m');
      }
      
      // Use Set to ensure unique clients by code
      final uniqueClients = <String, Map<String, String>>{};
      for (var c in clients) {
        uniqueClients[c.code] = {
          'CLIENTCODE': c.code,
          'CLIENTNAME': c.name,
          'CLIENTADD': c.address,
        };
      }
      
      _allClients = uniqueClients.values.toList();
      print('[DEBUG] Loaded unique clients from SQLite: count = [36m${_allClients.length}[0m');
    } catch (e) {
      _allClients = [];
      print('[DEBUG] Failed to load clients from SQLite: [31m${e.toString()}[0m');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadCities();
      await _loadAreas();
      await _loadClients();
      // Now set initial values and trigger filtering
      if (widget.initialSelectedCity != null && widget.initialSelectedCity!.isNotEmpty) {
        setState(() {
          _selectedCity = widget.initialSelectedCity;
        });
        _onCitySelected(widget.initialSelectedCity);
      }
      if (widget.initialSelectedArea != null && widget.initialSelectedArea!.isNotEmpty) {
        setState(() {
          _selectedArea = widget.initialSelectedArea;
        });
        _onAreaSelected(widget.initialSelectedArea);
      }
      if (widget.initialSelectedClient != null) {
        setState(() {
          _selectedClient = widget.initialSelectedClient;
        });
      }
    });
    // Removed: _loadOrderData();
  }

  Future<void> _loadCities() async {
    setState(() {
      _loadingCities = true;
      _citiesError = null;
    });
    // Try to extract from clients first
    final clientCities = widget.clients.map((c) => c.city).where((c) => c.isNotEmpty).toSet().toList();
    if (clientCities.isNotEmpty) {
      setState(() {
        _cities = clientCities..sort();
        _loadingCities = false;
      });
      print('DEBUG: Loaded cities from clients:  {_cities}');
      return;
    }
    // Fallback: load from offline_data/getclientcity.json
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final file = File('${appDocDir.path}/offline_data/getclientcity.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> data = json.decode(content);
        final cities = data.map((e) => e['CITYNAME']?.toString() ?? '').where((c) => c.isNotEmpty).toSet().toList();
        setState(() {
          _cities = cities..sort();
          _loadingCities = false;
        });
        print('DEBUG: Loaded cities from getclientcity.json:  {_cities}');
      } else {
        setState(() {
          _citiesError = 'No city data found.';
          _loadingCities = false;
        });
      }
    } catch (e) {
      setState(() {
        _citiesError = 'Failed to load cities:  {e.toString()}';
        _loadingCities = false;
      });
    }
  }

  void _extractCities() {
    setState(() {
      _cities = widget.clients.map((c) => c.city).where((c) => c.isNotEmpty).toSet().toList()..sort();
      print('DEBUG: Extracted cities:  {_cities}');
      print('DEBUG: widget.clients sample:');
      for (var i = 0; i < (widget.clients.length < 5 ? widget.clients.length : 5); i++) {
        final c = widget.clients[i];
        print('   {i+1}. code:  {c.code}, name:  {c.name}, city:  {c.city}, area:  {c.area}');
      }
    });
  }

  void _onCitySelected(String? city) async {
    setState(() {
      _selectedCity = city;
      _selectedArea = null;
      _selectedClient = null;
      _filteredClients = [];
    });
    // Find the selected city's code
    String? selectedCityCode;
    if (_cities.isNotEmpty && city != null) {
      // Try to get code from getclientcity.json
      try {
        final appDocDir = await getApplicationDocumentsDirectory();
        final file = File('${appDocDir.path}/offline_data/getclientcity.json');
        if (await file.exists()) {
          final content = await file.readAsString();
          final List<dynamic> data = json.decode(content);
          final cityObj = data.firstWhere((e) => e['CITYNAME'] == city, orElse: () => null);
          if (cityObj != null) {
            selectedCityCode = cityObj['AREACODE']?.toString();
          }
        }
      } catch (_) {}
    }
    // Filter areas by city code
    List<String> filteredAreas = [];
    if (selectedCityCode != null && _allAreas.isNotEmpty) {
      filteredAreas = _allAreas
        .where((area) => area['AREACODE'] != null && area['AREACODE']!.startsWith(selectedCityCode!))
        .map((area) => area['AREANAME'] ?? '')
            .where((a) => a.isNotEmpty)
            .toSet()
        .toList();
      print('DEBUG: Selected city:  {city}, code:  {selectedCityCode}');
      print('DEBUG: Filtered areas for city:  {filteredAreas}');
    }
    setState(() {
      _areas = filteredAreas;
      _filteredAreas = filteredAreas; // Initialize filtered areas for search
    });
  }



  void _filterAreas(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        _filteredAreas = _areas;
      } else {
        _filteredAreas = _areas
            .where((area) => area.toLowerCase().contains(searchText.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _areaSearchController.dispose();
    _areaFocusNode.dispose();
    super.dispose();
  }

  void _onAreaSelected(String? area) {
    setState(() {
      _selectedArea = area;
      _selectedClient = null;
    });
    // Debug: Print selected city and area
    print('[DEBUG] Selected city: $_selectedCity, area: $_selectedArea');
    // Debug: Print sample client names
    print('[DEBUG] Sample client names:');
    for (var c in _allClients.take(5)) {
      print('  ${c['CLIENTNAME']}');
    }
    // Filter clients by selected city and area using substring match in CLIENTNAME
    List<Map<String, String>> filteredClients = [];
    if (_selectedCity != null && _selectedArea != null && _allClients.isNotEmpty) {
      final city = _selectedCity!.toLowerCase();
      final areaStr = _selectedArea!.toLowerCase();
      filteredClients = _allClients.where((client) {
        final name = client['CLIENTNAME']?.toLowerCase() ?? '';
        return name.contains(city) && name.contains(areaStr);
      }).toList();
      print('[DEBUG] Filtered clients for city/area (substring match): count = ${filteredClients.length}');
      for (var i = 0; i < (filteredClients.length < 5 ? filteredClients.length : 5); i++) {
        final c = filteredClients[i];
        print('  ${i+1}. code: ${c['CLIENTCODE']}, name: ${c['CLIENTNAME']}');
      }
    }
    setState(() {
      _filteredClients = filteredClients.map((c) => Client(
        code: c['CLIENTCODE'] ?? '',
        name: c['CLIENTNAME'] ?? '',
        address: c['CLIENTADD'] ?? '',
        city: _selectedCity ?? '',
        area: _selectedArea ?? '',
      )).toList();
      // Robust: If the current selected client is not in the filtered list, clear it
      if (_selectedClient == null ||
          !_filteredClients.any((c) => c.code == _selectedClient!.code)) {
        _selectedClient = null;
      } else {
        // Ensure it's the exact instance from the filtered list
        final match = _filteredClients.firstWhere((c) => c.code == _selectedClient!.code);
        _selectedClient = match;
      }
    });
    // Auto-focus the client search field to open dropdown
    FocusScope.of(context).requestFocus(widget.clientFocusNode);
  }

  void _onClientSelected(Client? client) {
      setState(() {
      _selectedClient = client;
    });
    if (client != null) {
      widget.onClientSelected(client);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.lastSavedDraft != null;
    final clientName = widget.selectedClient?.name ?? '';
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
              child: Container(
                decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white.withOpacity(0.12),
                    child: Icon(Icons.shopping_cart, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isEditing ? 'Edit Order' : 'Order',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                  ),
                ),
                       
                      ],
              ),
            ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
          IconButton(
                        icon: const Icon(Icons.save_alt, color: Colors.white),
            tooltip: 'Save Draft',
            onPressed: () => widget.onSaveDraft(context),
          ),
          IconButton(
                        icon: const Icon(Icons.summarize, color: Colors.white),
            tooltip: 'View Summary',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order summary (not yet implemented).')));
            },
          ),
          IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh Data',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Refreshing order data...'),
                  backgroundColor: Colors.blue,
                ),
              );
              widget.onRefreshData();
            },
          ),
          IconButton(
                        icon: const Icon(Icons.cloud_upload, color: Colors.white),
            tooltip: 'Post Order',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order posted (not yet implemented).')));
            },
          ),
        ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: widget.loading
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text(
                  'Loading order data...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please wait while we load clients and products',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Retrying data load...'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    widget.onRefreshData();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HIERARCHICAL DATA SELECTION SECTION
                Card(
                  elevation: Theme.of(context).cardTheme.elevation,
                  shape: Theme.of(context).cardTheme.shape,
                  color: Theme.of(context).cardTheme.color,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        // CITY DROPDOWN
                        if (_loadingCities)
                          const Center(child: CircularProgressIndicator())
                        else if (_citiesError != null)
                          Text(_citiesError!, style: const TextStyle(color: Colors.red))
                        else
                        DropdownButtonFormField<String>(
                          value: _selectedCity,
                          items: _cities.map((city) => DropdownMenuItem(value: city, child: Text(city))).toList(),
                          onChanged: _onCitySelected,
                          decoration: const InputDecoration(labelText: 'Select City', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 16),
                        // AREA SEARCH FIELD
                        if (_selectedCity != null)
                        RawAutocomplete<String>(
                          textEditingController: _areaSearchController,
                          focusNode: _areaFocusNode,
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            final input = textEditingValue.text.toLowerCase();
                            if (input.isEmpty) return _filteredAreas;
                            return _filteredAreas.where((area) =>
                              area.toLowerCase().contains(input)
                            ).toList();
                          },
                          displayStringForOption: (String area) => area,
                          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                            return TextFormField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: const InputDecoration(
                                labelText: 'Search Area',
                                hintText: 'Type to search areas...',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.search),
                                isDense: true,
                              ),
                              onChanged: (value) {
                                _filterAreas(value);
                              },
                            );
                          },
                          optionsViewBuilder: (context, onSelected, options) {
                            if (options.isEmpty) {
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text('No area found'),
                              );
                            }
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4,
                                child: SizedBox(
                                  width: 350,
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: options.length,
                                    itemBuilder: (context, index) {
                                      final area = options.elementAt(index);
                                      return ListTile(
                                        leading: const Icon(Icons.location_on, size: 20),
                                        title: Text(
                                          area,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        onTap: () {
                                          setState(() {
                                            _selectedArea = area;
                                            _areaSearchController.text = area;
                                          });
                                          _onAreaSelected(area);
                                          // Unfocus to close the dropdown
                                          _areaFocusNode.unfocus();
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        // CLIENT DROPDOWN
                        if (_selectedCity != null && _selectedArea != null)
                        RawAutocomplete<Client>(
                          textEditingController: widget.clientController,
                          focusNode: widget.clientFocusNode,
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            final input = textEditingValue.text.toLowerCase();
                            if (input.isEmpty) return _filteredClients;
                            return _filteredClients.where((c) =>
                              c.name.toLowerCase().contains(input) ||
                              c.code.toLowerCase().contains(input)
                            ).toList();
                          },
                          displayStringForOption: (Client c) => c.name,
                          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                            return TextFormField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: const InputDecoration(
                                labelText: 'Search Client',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            );
                          },
                          optionsViewBuilder: (context, onSelected, options) {
                            if (options.isEmpty) {
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text('No client found'),
                              );
                            }
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4,
                                child: SizedBox(
                                  width: 350,
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: options.length,
                                    itemBuilder: (context, index) {
                                      final client = options.elementAt(index);
                                      return ListTile(
                                        title: Text(
                                          client.name,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        subtitle: Text(client.code, style: const TextStyle(fontSize: 12)),
                                        onTap: () {
                                          setState(() {
                                            _selectedClient = client;
                                            widget.clientController.text = client.name;
                                          });
                                          widget.onClientSelected(client);
                                          // Unfocus to close the dropdown
                                          widget.clientFocusNode.unfocus();
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                                  ),
                                ],
                              ),
                  ),
                ),
                const SizedBox(height: 16),
                

                const SizedBox(height: 16),
                
                // ORDER ITEMS SECTION
                const Text(
                  'Order Items',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Table Header (matching the image)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Text('Item', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center)),
                    //  Expanded(child: Text('Pak', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center)),
                      Expanded(child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center)),
                      Expanded(child: Text('Bon', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center)),
                      Expanded(child: Text('PR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center)),
                      Expanded(child: Text('Dis%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                
                // Order Lines (matching the image layout)
                ...widget.orderLines.asMap().entries.map((entry) {
                  final index = entry.key;
                  final line = entry.value;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      children: [
                                                // Item Row
                        Row(
                          children: [
                                                        // Product Button (under "Item" title)
                            Expanded(
                              flex: 2,
                              child: Container(
                              height: 30,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Show product selection dialog
                                  _showProductSelectionDialog(index, line);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade300,
                                  foregroundColor: Colors.black,
                                  padding: EdgeInsets.zero,
                                ),
                                child: Text(
                                    line.productName.isNotEmpty ? line.productName : 'Item',
                                  style: TextStyle(fontSize: 10),
                                  overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                            //const SizedBox(width: 4),
                                                                                    // Packing Field (under "Pak" title)
                            // Expanded(
                            //   child: SizedBox(
                            //   height: 30,
                            //     child: TextFormField(
                            //       initialValue: line.packing?.isNotEmpty == true ? line.packing : 'Tab',
                            //       decoration: InputDecoration(
                            //         contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                            //         border: OutlineInputBorder(),
                            //         hintText: 'Pak',
                            //       ),
                            //       style: TextStyle(fontSize: 10),
                            //       onChanged: (val) {
                            //         final updatedLine = line.copyWith(packing: val);
                            //         widget.onOrderLineChanged(index, updatedLine);
                            //       },
                            //     ),
                            //   ),
                            // ),
                            const SizedBox(width: 4),
                            // Quantity Field (under "Qty" title)
                            Expanded(
                              child: SizedBox(
                              height: 30,
                              child: TextFormField(
                                  initialValue: line.quantity > 0 ? line.quantity.toInt().toString() : '',
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                                  border: OutlineInputBorder(),
                                    hintText: 'Enter Qty',
                                ),
                                style: TextStyle(fontSize: 10),
                                keyboardType: TextInputType.number,
                                onChanged: (val) {
                                    final quantity = val.isNotEmpty ? (double.tryParse(val) ?? 0.0) : 0.0;
                                    final updatedLine = line.copyWith(quantity: quantity);
                                  widget.onOrderLineChanged(index, updatedLine);
                                },
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            // Bonus Field (under "Bon" title)
                            Expanded(
                              child: SizedBox(
                              height: 30,
                              child: TextFormField(
                                  initialValue: (line.bonus ?? 0.0) > 0 ? (line.bonus ?? 0.0).toInt().toString() : '0',
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                                  border: OutlineInputBorder(),
                                    hintText: '0',
                                ),
                                style: TextStyle(fontSize: 10),
                                keyboardType: TextInputType.number,
                                onChanged: (val) {
                                    final bonus = double.tryParse(val) ?? 0.0;
                                  final updatedLine = line.copyWith(bonus: bonus);
                                  widget.onOrderLineChanged(index, updatedLine);
                                },
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                                                        // Price Field (under "PR" title)
                            Expanded(
                              child: Container(
                                height: 30,
                                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  border: Border.all(color: Colors.green.shade200),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Center(
                                  child: Text(
                                    line.price.toInt().toString(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.green.shade700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                                                        // Discount Field (under "Dis%" title)
                            Expanded(
                              child: SizedBox(
                              height: 30,
                              child: TextFormField(
                                  initialValue: (line.discount ?? 0.0) > 0 ? (line.discount ?? 0.0).toInt().toString() : '0',
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                                  border: OutlineInputBorder(),
                                    hintText: '0',
                                ),
                                style: TextStyle(fontSize: 10),
                                keyboardType: TextInputType.number,
                                onChanged: (val) {
                                    final discount = double.tryParse(val) ?? 0.0;
                                  final updatedLine = line.copyWith(discount: discount);
                                  widget.onOrderLineChanged(index, updatedLine);
                                },
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),

                            // Delete Button (only show if more than one item)
                            if (widget.orderLines.length > 1)
                              Container(
                                width: 30,
                                height: 30,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Remove this order line
                                    widget.onRemoveLine(index);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade100,
                                    foregroundColor: Colors.red.shade700,
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: Icon(
                                    Icons.delete,
                                    size: 16,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                                                // Product Details Row
                        if (line.productName.isNotEmpty)
                          Container(
                            margin: EdgeInsets.only(top: 4),
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                            child: Row(
                              children: [
                                SizedBox(width: 60), // Align with Item column
                                Expanded(
                                child: Text(
                                    '${line.productName} (${line.productCode})',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.green.shade300),
                                  ),
                                  child: Text(
                                    'Total: ${_calculateTotalWithDiscount(line).toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                ),
                              ),
                            ),
                          ],
                            ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                
                // ADD ITEM BUTTON (matching the image)
                Container(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: widget.onAddLine,
                    icon: Icon(Icons.add, color: Colors.green.shade700),
                    label: Text(
                      'Add Item',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade50,
                      side: BorderSide(color: Colors.green.shade300),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // AMOUNT SUMMARY SECTION
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    children: [
                      // Header
                      Row(
                        children: [
                          Icon(Icons.calculate, color: Colors.blue.shade700, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Order Summary',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Gross Amount
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Gross Amount',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _calculateGrossAmount().toStringAsFixed(0),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Discount Amount
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Discount Amount',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _calculateDiscountTotal().toStringAsFixed(0),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Net Amount
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.blue.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                              'Net Amount',
                        style: TextStyle(
                                fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                              _calculateNetAmount().toStringAsFixed(0),
                        style: TextStyle(
                                fontSize: 15,
                          fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ],
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

  double _calculateGrossAmount() {
    double grossAmount = 0;
    for (var line in widget.orderLines) {
      grossAmount += line.quantity * line.price;
    }
    return grossAmount;
  }

  double _calculateDiscountTotal() {
    double totalDiscount = 0;
    for (var line in widget.orderLines) {
      double baseAmount = line.quantity * line.price;
      double discountAmount = baseAmount * ((line.discount ?? 0.0) / 100.0);
      totalDiscount += discountAmount;
    }
    return totalDiscount;
  }

  double _calculateNetAmount() {
    return _calculateGrossAmount() - _calculateDiscountTotal();
  }

  // Method to show product selection dialog with proper Product entity assignment
  void _showProductSelectionDialog(int index, _OrderLine line) {
    String searchQuery = '';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Filter products based on search query
          final filteredProducts = widget.products.where((product) {
            if (searchQuery.isEmpty) return true;
            final query = searchQuery.toLowerCase();
            return product.pname.toLowerCase().contains(query) ||
                   product.pcode.toLowerCase().contains(query) ||
                   product.prcode.toLowerCase().contains(query);
          }).toList();
          
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.search, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                const Text('Select Product'),
              ],
            ),
            content: Container(
              width: double.maxFinite,
              height: 500, // Increased height for better viewing
              child: Column(
                children: [
                  // Enhanced Search field with clear functionality
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade300),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Search by Product Name, Code, or Category...',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        prefixIcon: Icon(Icons.search, color: Colors.blue.shade700),
                        suffixIcon: searchQuery.isNotEmpty 
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setDialogState(() {
                                  searchQuery = '';
                                });
                              },
                            )
                          : null,
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Results count
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${filteredProducts.length} products found',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Professional Product list with enhanced PRCODE display
                  Expanded(
                    child: filteredProducts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
                                const SizedBox(height: 16),
                                Text(
                                  searchQuery.isEmpty 
                                    ? 'No products available.\nPlease sync data first.'
                                    : 'No products match your search.\nTry different keywords.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, productIndex) {
                              final product = filteredProducts[productIndex];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.white,
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(12),
                                  title: Text(
                                    product.pname,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 6),
                                      // Professional PRCODE display - Most prominent
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: Colors.blue.shade200),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.category, size: 14, color: Colors.blue.shade700),
                                            const SizedBox(width: 4),
                                            Text(
                                              'PRCODE: ${product.prcode}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue.shade800,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      // Product details in organized rows
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Icon(Icons.qr_code, size: 12, color: Colors.grey.shade600),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Code: ${product.pcode}',
                                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Icon(Icons.attach_money, size: 12, color: Colors.green.shade600),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Price: ${product.tprice}',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.green.shade700,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: Icon(
                                    Icons.add_circle,
                                    color: Colors.green.shade600,
                                    size: 24,
                                  ),
                                  onTap: () {
                                    // Set all product details AND the Product entity
                                    final updatedLine = line.copyWith(
                                      productName: product.pname,
                                      productCode: product.pcode,
                                      price: double.tryParse(product.tprice) ?? 0.0,
                                      product: product, // ✅ CRITICAL: Set the Product entity
                                    );
                                    
                                    // Update the order line using the callback
                                    widget.onOrderLineChanged(index, updatedLine);
                                    
                                    print('=== PRODUCT SELECTED PROFESSIONALLY ===');
                                    print('Selected: ${product.pname}');
                                    print('PRCODE: ${product.prcode} ✅');
                                    print('PCODE: ${product.pcode}');
                                    print('TPRICE: ${product.tprice}');
                                    print('Line.product entity set: ${updatedLine.product != null}');
                                    print('=======================================');
                                    
                                    // Show confirmation feedback
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('✅ Selected: ${product.pname} (PRCODE: ${product.prcode})'),
                                        backgroundColor: Colors.green,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                    
                                    Navigator.of(context).pop();
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                ),
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OrderLine {
  Product? product;
  String? packing;
  int? qty;
  double? rate;
  double? discount;
  double? bonus;
  double? totalAmount;
  
  // Additional properties needed for the hierarchical form
  String productCode = '';
  String productName = '';
  double price = 0.0;
  double quantity = 0.0;
  
  _OrderLine copyWith({
    Product? product,
    String? packing,
    int? qty,
    double? rate,
    double? discount,
    double? bonus,
    double? totalAmount,
    String? productCode,
    String? productName,
    double? price,
    double? quantity,
  }) {
    return _OrderLine()
      ..product = product ?? this.product
      ..packing = packing ?? this.packing
      ..qty = qty ?? this.qty
      ..rate = rate ?? this.rate
      ..discount = discount ?? this.discount
      ..bonus = bonus ?? this.bonus
      ..totalAmount = totalAmount ?? this.totalAmount
      ..productCode = productCode ?? this.productCode
      ..productName = productName ?? this.productName
      ..price = price ?? this.price
      ..quantity = quantity ?? this.quantity;
  }
}

class _ProductAutocomplete extends StatelessWidget {
  final List<Product> products;
  final void Function(Product) onSelected;
  const _ProductAutocomplete({Key? key, required this.products, required this.onSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Autocomplete<Product>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<Product>.empty();
        }
        final input = textEditingValue.text.toLowerCase();
        return products.where((p) => p.pname.toLowerCase().contains(input) || p.pcode.toLowerCase().contains(input));
      },
      displayStringForOption: (Product p) => p.pname,
      onSelected: onSelected,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: 'Product',
            hintText: 'Search and select product',
            border: OutlineInputBorder(),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Material(
          elevation: 4,
          child: ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: options.map((p) => ListTile(
              title: Text(p.pname),
              subtitle: Text('Code: ${p.pcode} | Price: ${p.tprice}'),
              onTap: () => onSelected(p),
            )).toList(),
          ),
        );
      },
    );
  }
}

class ReportPage extends StatelessWidget {
  const ReportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: const Center(child: Text('Reports page coming soon...')),
    );
  }
}

class _DashboardContent extends StatefulWidget {
  final String userName;
  final VoidCallback onSync;
  const _DashboardContent({Key? key, required this.userName, required this.onSync}) : super(key: key);

  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent> {
  String? _bookingManId;

  @override
  void initState() {
    super.initState();
    _loadBookingManId();
  }

  Future<void> _loadBookingManId() async {
    // Load the booking man ID from shared preferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookingManId = prefs.getString('booking_man_id');
      setState(() {
        _bookingManId = bookingManId ?? 'Not Set';
      });
    } catch (e) {
      setState(() {
        _bookingManId = 'Not Set';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    return Container(
                decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [bg, primary.withOpacity(0.05)],
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 0, 
            vertical: MediaQuery.of(context).size.height * 0.02, // Responsive vertical padding
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.02), // Responsive top spacing
              // Header Card
              Padding(
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04), // Reduced responsive padding
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  elevation: 4,
                  color: Theme.of(context).cardTheme.color,
                  child: Padding(
                    padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05), // Reduced responsive padding
                child: Row(
                  children: [
                        CircleAvatar(
                          radius: MediaQuery.of(context).size.width * 0.06, // Reduced responsive radius
                          backgroundColor: primary.withOpacity(0.12),
                          child: Icon(Icons.home, size: MediaQuery.of(context).size.width * 0.07, color: primary), // Reduced responsive icon size
                    ),
                        SizedBox(width: MediaQuery.of(context).size.width * 0.04), // Reduced responsive spacing
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                                'Hello, ${widget.userName}!',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                                  fontSize: MediaQuery.of(context).size.width * 0.045, // Reduced responsive font size
                                  color: primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                          ),
                              SizedBox(height: MediaQuery.of(context).size.width * 0.012), // Reduced responsive spacing
                              Text(
                                'Welcome to AA App',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: primary.withOpacity(0.7),
                                  fontSize: MediaQuery.of(context).size.width * 0.03, // Reduced responsive font size
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                          ),
                              SizedBox(height: MediaQuery.of(context).size.width * 0.008), // Small spacing
                              if (_bookingManId != null)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: MediaQuery.of(context).size.width * 0.02,
                                    vertical: MediaQuery.of(context).size.width * 0.008,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.blue.shade200),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.badge,
                                        size: MediaQuery.of(context).size.width * 0.025,
                                        color: Colors.blue.shade700,
                                      ),
                                      SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                                      Text(
                                        'Booking Man ID: $_bookingManId',
                                        style: TextStyle(
                                          fontSize: MediaQuery.of(context).size.width * 0.025,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue.shade700,
                                        ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
                  ],
                ),
              ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.width * 0.06), // Reduced responsive spacing
              Padding(
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.06), // Reduced responsive padding
                child: Text(
                'Quick Actions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: MediaQuery.of(context).size.width * 0.04, // Reduced responsive font size
                ),
              ),
              ),
              SizedBox(height: MediaQuery.of(context).size.width * 0.03), // Reduced responsive spacing
              Padding(
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.06), // Reduced responsive padding
                child: GridView.count(
                crossAxisCount: 2,
                  mainAxisSpacing: MediaQuery.of(context).size.width * 0.05, // Responsive spacing
                  crossAxisSpacing: MediaQuery.of(context).size.width * 0.05, // Responsive spacing
                shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                children: [
                  _MainActionCardSmartTheme(
                    action: _MainAction(
                      icon: Icons.bar_chart,
                      label: 'Daily Report',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const EnhancedReportsPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  _MainActionCardSmartTheme(
                    action: _MainAction(
                      icon: Icons.analytics,
                      label: 'Insights',
                      onTap: () {},
                    ),
                  ),
                  _MainActionCardSmartTheme(
                    action: _MainAction(
                      icon: Icons.cloud_download,
                      label: 'Sync Offline Data',
                      onTap: widget.onSync,
                    ),
                  ),
                  if (widget.userName == 'Admin1')
                  _MainActionCardSmartTheme(
                    action: _MainAction(
                      icon: Icons.settings,
                      label: 'User Config',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const UserConfigurationPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  _MainActionCardSmartTheme(
                    action: _MainAction(
                      icon: Icons.logout,
                      label: 'Logout',
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Logout'),
                              content: const Text('Are you sure you want to logout?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    await AuthService.logout();
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (_) => const MainAppWidget(),
                                      ),
                                      (route) => false,
                                    );
                                  },
                                  child: const Text('Logout'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            FutureBuilder<bool>(
              future: fetchShowAdsFlag(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                }
                if (snapshot.data == true) {
                  return const BannerAdWidget();
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
            ],
          ),
        ),
      ),
      );
  }
}

// Smart Home Theme Main Action Card
class _MainActionCardSmartTheme extends StatelessWidget {
  final _MainAction action;
  const _MainActionCardSmartTheme({Key? key, required this.action}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 4,
      color: Theme.of(context).cardTheme.color,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: action.onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.width * 0.05, // Reduced responsive padding
            horizontal: MediaQuery.of(context).size.width * 0.015, // Reduced responsive padding
          ),
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
                    children: [
              CircleAvatar(
                radius: MediaQuery.of(context).size.width * 0.05, // Reduced responsive radius
                backgroundColor: primary.withOpacity(0.12),
                child: Icon(
                  action.icon, 
                  size: MediaQuery.of(context).size.width * 0.06, // Reduced responsive icon size
                  color: primary
              ),
              ),
              SizedBox(height: MediaQuery.of(context).size.width * 0.035), // Reduced responsive spacing
              Text(
                action.label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: MediaQuery.of(context).size.width * 0.03, // Reduced responsive font size
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
          ),
        ],
      ),
        ),
      ),
    );
  }
}

class _OfflineSyncDialog extends StatefulWidget {
  @override
  _OfflineSyncDialogState createState() => _OfflineSyncDialogState();
}

class _OfflineSyncDialogState extends State<_OfflineSyncDialog> {
  final OfflineSyncService _syncService = OfflineSyncService();
  bool _isSyncing = false;
  String _statusMessage = 'Preparing to sync...';
  Map<String, dynamic>? _syncResult;

  @override
  void initState() {
    super.initState();
    _startSync();
  }

  Future<void> _startSync() async {
    setState(() {
      _isSyncing = true;
      _statusMessage = 'Checking connectivity...';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final config = prefs.getStringList(Constants.configKey);
      final baseUrl = config != null && config.length >= 5 ? config[4] : '';
      final normalizedBaseUrl = baseUrl.startsWith('http://') || baseUrl.startsWith('https://')
          ? baseUrl
          : 'http://$baseUrl';
      if (baseUrl.isEmpty) {
        setState(() {
          _isSyncing = false;
          _statusMessage = 'No remote server location configured. Please set it in the user configuration page.';
        });
        return;
      }
      final result = await _syncService.syncOfflineData(baseUrl: normalizedBaseUrl);
      setState(() {
        _isSyncing = false;
        _syncResult = result;
        _statusMessage = result['message'];
      });
    } catch (e) {
      setState(() {
        _isSyncing = false;
        _statusMessage = 'Sync failed: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _isSyncing ? Icons.sync : Icons.cloud_download,
            color: const Color(0xFF1E3A8A),
          ),
          const SizedBox(width: 8),
          const Text('Offline Data Sync'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isSyncing) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: 16),
            Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(_statusMessage)),
              ],
            ),
          ] else ...[
            Text(_statusMessage),
            if (_syncResult != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _syncResult!['success'] 
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _syncResult!['success'] ? 'Sync Completed' : 'Sync Failed',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _syncResult!['success'] ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Products synced: ${_syncResult!['products_synced']}'),
                    Text('Clients synced: ${_syncResult!['clients_synced']}'),
                    Text('Stock items synced: ${_syncResult!['stock_synced'] ?? 0}'),
                      if (_syncResult!.containsKey('client_area_count'))
                        Text('Client areas: ${_syncResult!['client_area_count']}'),
                      if (_syncResult!.containsKey('client_city_count'))
                        Text('Client cities: ${_syncResult!['client_city_count']}'),
                  ],
                ),
              ),
            ],
          ],
        ],
        ),
      ),
      actions: [
        if (!_isSyncing) ...[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (_syncResult != null && !_syncResult!['success'])
            TextButton(
              onPressed: () {
                setState(() {
                  _syncResult = null;
                  _isSyncing = true;
                });
                _startSync();
              },
              child: const Text('Retry'),
            ),
        ],
      ],
    );
  }
}

class _MainAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  _MainAction({required this.icon, required this.label, required this.onTap});
}

class _MainActionCard extends StatelessWidget {
  final _MainAction action;

  const _MainActionCard({Key? key, required this.action}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: Theme.of(context).cardTheme.elevation,
      shape: Theme.of(context).cardTheme.shape,
      color: Theme.of(context).cardTheme.color,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: action.onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                const Color(0xFF1E3A8A).withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1E3A8A).withOpacity(0.1),
                ),
                child: Icon(
                  action.icon,
                  size: 30,
                  color: const Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                action.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



// Professional Draft Action Sheet
class _DraftActionSheet extends StatelessWidget {
  final OrderDraft draft;
  final VoidCallback onViewDraft;
  final VoidCallback onNewOrder;

  const _DraftActionSheet({
    required this.draft,
    required this.onViewDraft,
    required this.onNewOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              
              // Success message
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green.shade600,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Draft Saved Successfully!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                        Text(
                          'Client: ${draft.clientName}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
            ],
          ),
        ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Action buttons
              Row(
          children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onViewDraft,
                      icon: const Icon(Icons.visibility, color: Colors.white),
                      label: const Text(
                        'View Draft Report',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onNewOrder,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'New Order',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Close button
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Close',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Professional Draft Details Sheet
class _DraftDetailsSheet extends StatelessWidget {
  final OrderDraft draft;

  const _DraftDetailsSheet({required this.draft});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.description,
                      color: Colors.blue.shade600,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Draft Report',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        Text(
                          'ID: ${draft.id.substring(0, 8)}...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Client Info
                    _ClientInfoCard(draft: draft),
                    const SizedBox(height: 16),
                    
                    // Order Items
                    _OrderItemsCard(draft: draft),
                    const SizedBox(height: 16),
                    
                    // Total
                    _TotalCard(total: draft.totalAmount),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Client Info Card
class _ClientInfoCard extends StatelessWidget {
  final OrderDraft draft;

  const _ClientInfoCard({required this.draft});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: Theme.of(context).cardTheme.elevation,
      shape: Theme.of(context).cardTheme.shape,
      color: Theme.of(context).cardTheme.color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Theme.of(context).iconTheme.color, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Client Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoRow(label: 'Name', value: draft.clientName),
          ],
        ),
      ),
    );
  }
}

// Order Items Card
class _OrderItemsCard extends StatelessWidget {
  final OrderDraft draft;

  const _OrderItemsCard({required this.draft});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: Theme.of(context).cardTheme.elevation,
      shape: Theme.of(context).cardTheme.shape,
      color: Theme.of(context).cardTheme.color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_cart, color: Theme.of(context).iconTheme.color, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Order Items',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${draft.items.length} items',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...draft.items.map((item) => _ItemRow(item: item)).toList(),
          ],
        ),
      ),
    );
  }
}

// Item Row for Draft Details
class _ItemRow extends StatelessWidget {
  final OrderItem item;

  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.productName,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _ItemData(label: 'Qty', value: '${item.quantity}', color: Colors.grey),
              _ItemData(label: 'Bon', value: '${(item.bonus ?? 0).toStringAsFixed(1)}', color: Colors.green),
              _ItemData(label: 'Price', value: '${item.unitPrice.round()}', color: Colors.blue),
              _ItemData(label: 'Dis%', value: '${(item.discount ?? 0).toStringAsFixed(1)}', color: Colors.orange),
              _ItemData(label: 'Total', value: '${item.totalPrice.round()}', color: Colors.green, isTotal: true),
            ],
          ),
        ],
      ),
    );
  }
}

// Item Data Widget
class _ItemData extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isTotal;

  const _ItemData({
    required this.label,
    required this.value,
    required this.color,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
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
              color: isTotal ? color.withOpacity(0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// Total Card
class _TotalCard extends StatelessWidget {
  final double total;

  const _TotalCard({required this.total});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: Theme.of(context).cardTheme.elevation,
      shape: Theme.of(context).cardTheme.shape,
      color: Theme.of(context).cardTheme.color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.calculate, color: Theme.of(context).iconTheme.color, size: 24),
            const SizedBox(width: 12),
            Text(
              'Total Amount:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const Spacer(),
            Text(
              '${total.round()}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Info Row Widget
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
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Order TextField with Auto-Selection and Focus Management
class _OrderTextField extends StatefulWidget {
  final String value;
  final String label;
  final String hint;
  final Color labelColor;
  final TextInputType? keyboardType;
  final Function(String) onChanged;

  const _OrderTextField({
    required this.value,
    required this.label,
    required this.hint,
    required this.labelColor,
    this.keyboardType,
    required this.onChanged,
  });

  @override
  State<_OrderTextField> createState() => _OrderTextFieldState();
}

class _OrderTextFieldState extends State<_OrderTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
    
    // Listen to focus changes
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _controller.text.isNotEmpty && !_hasInitialized) {
        // Auto-select all text when focused and there's existing data
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _controller.text.length,
          );
          _hasInitialized = true;
        });
      } else if (!_focusNode.hasFocus) {
        _hasInitialized = false;
      }
    });
  }

  @override
  void didUpdateWidget(_OrderTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value;
      _hasInitialized = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: widget.keyboardType,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        hintStyle: TextStyle(
          fontSize: 11,
          color: Colors.grey.shade600,
        ),
        labelStyle: TextStyle(
          fontSize: 11,
          color: widget.labelColor,
          fontWeight: FontWeight.w600,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: widget.labelColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      ),
      onChanged: widget.onChanged,
      onTap: () {
        // Auto-select all text when tapped if there's existing data
        if (_controller.text.isNotEmpty) {
          _controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _controller.text.length,
          );
        }
      },
    );
  }
} 

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({Key? key}) : super(key: key);

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-8528144115156854/9848769890', // Production Banner ID
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isLoaded = true),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          setState(() => _isLoaded = false);
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) return const SizedBox.shrink();
    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}

Future<bool> fetchShowAdsFlag() async {
  try {
    final ref = FirebaseDatabase.instance.refFromURL('https://nailart-a9fb4-default-rtdb.firebaseio.com/show_ads');
    final snapshot = await ref.get();
    if (snapshot.exists && (snapshot.value is bool || snapshot.value is int)) {
      // Accept both bool and int (1/0) for flexibility
      if (snapshot.value is bool) return snapshot.value as bool;
      if (snapshot.value is int) return (snapshot.value as int) == 1;
    }
  } catch (e) {
    // Optionally log error
  }
  return true; // Default to true if not found or error
}

Future<bool> fetchShowInterstitialFlag() async {
  try {
    final ref = FirebaseDatabase.instance.refFromURL('https://nailart-a9fb4-default-rtdb.firebaseio.com/show_interstitial');
    final snapshot = await ref.get();
    if (snapshot.exists && (snapshot.value is bool || snapshot.value is int)) {
      if (snapshot.value is bool) return snapshot.value as bool;
      if (snapshot.value is int) return (snapshot.value as int) == 1;
    }
  } catch (e) {}
  return false; // Default to false if not found or error
}

Future<void> maybeShowInterstitialAd() async {
  final shouldShow = await fetchShowInterstitialFlag();
  if (!shouldShow) return;
  InterstitialAd? interstitialAd;
  final completer = Completer<void>();
  InterstitialAd.load(
    adUnitId: 'ca-app-pub-8528144115156854/4589059570', // Production Interstitial ID
    request: const AdRequest(),
    adLoadCallback: InterstitialAdLoadCallback(
      onAdLoaded: (ad) {
        interstitialAd = ad;
        ad.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
            completer.complete();
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            ad.dispose();
            completer.complete();
          },
        );
        ad.show();
      },
      onAdFailedToLoad: (error) {
        completer.complete();
      },
    ),
  );
  await completer.future;
} 
