import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/sales_order/domain/entities/client.dart';
import '../../features/sales_order/domain/entities/product.dart';
import '../../core/database/offline_database_service.dart';

class OfflineFileInfo {
  final String fileName;
  final int size;
  final int recordCount;
  final String? preview;

  OfflineFileInfo({
    required this.fileName,
    required this.size,
    required this.recordCount,
    this.preview,
  });
}

class DebugDataTable extends StatefulWidget {
  const DebugDataTable({Key? key}) : super(key: key);

  @override
  State<DebugDataTable> createState() => _DebugDataTableState();
}

class _DebugDataTableState extends State<DebugDataTable> {
  final OfflineDatabaseService _dbService = OfflineDatabaseService();
  
  // Loading states
  bool _isLoadingSummary = true;
  bool _isLoadingClients = false;
  bool _isLoadingProducts = false;
  bool _isLoadingFiles = true;
  bool _isImporting = false;
  
  // Data storage with pagination
  List<Client> _clients = [];
  List<Product> _products = [];
  List<OfflineFileInfo> _offlineFiles = [];
  
  // Pagination
  int _clientsPage = 0;
  int _productsPage = 0;
  static const int _pageSize = 5;
  
  // Summary data
  int _clientsCount = 0;
  int _productsCount = 0;
  int _stockCount = 0;
  int _citiesCount = 0;
  int _areasCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoadingSummary = true;
      _isLoadingFiles = true;
    });

    try {
      // Load summary data first (lightweight)
      await _loadSummaryData();
      
      // Load offline files info
      await _loadOfflineFilesInfo();
      
    } catch (e) {
      _showErrorSnackBar('Error loading data: $e');
    } finally {
      setState(() {
        _isLoadingSummary = false;
        _isLoadingFiles = false;
      });
    }
  }

  Future<void> _loadSummaryData() async {
    try {
      final db = await _dbService.database;
      
      // Get counts using efficient queries
      final clientsResult = await db.rawQuery('SELECT COUNT(*) as count FROM clients');
      final productsResult = await db.rawQuery('SELECT COUNT(*) as count FROM products');
      final stockResult = await db.rawQuery('SELECT COUNT(*) as count FROM stock');
      
      // Get unique cities and areas count
      final citiesResult = await db.rawQuery('SELECT COUNT(DISTINCT city) as count FROM clients WHERE city IS NOT NULL AND city != ""');
      final areasResult = await db.rawQuery('SELECT COUNT(DISTINCT area) as count FROM clients WHERE area IS NOT NULL AND area != ""');

      setState(() {
        _clientsCount = clientsResult.first['count'] as int? ?? 0;
        _productsCount = productsResult.first['count'] as int? ?? 0;
        _stockCount = stockResult.first['count'] as int? ?? 0;
        _citiesCount = citiesResult.first['count'] as int? ?? 0;
        _areasCount = areasResult.first['count'] as int? ?? 0;
      });
    } catch (e) {
      print('Error loading summary data: $e');
    }
  }

  Future<void> _loadClientsPage() async {
    if (_isLoadingClients) return;
    
    setState(() {
      _isLoadingClients = true;
    });

    try {
      final db = await _dbService.database;
      final offset = _clientsPage * _pageSize;
      
      final results = await db.query(
        'clients',
        limit: _pageSize,
        offset: offset,
        orderBy: 'client_name ASC',
      );

      final newClients = results.map((row) => Client(
        code: row['client_code'] as String? ?? '',
        name: row['client_name'] as String? ?? '',
        city: row['city'] as String? ?? '',
        area: '', // area field doesn't exist in current schema
        address: row['address'] as String? ?? '',
      )).toList();

      setState(() {
        _clients.addAll(newClients);
        _clientsPage++;
        _isLoadingClients = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingClients = false;
      });
      _showErrorSnackBar('Error loading clients: $e');
    }
  }

  Future<void> _loadProductsPage() async {
    if (_isLoadingProducts) return;
    
    setState(() {
      _isLoadingProducts = true;
    });

    try {
      final db = await _dbService.database;
      final offset = _productsPage * _pageSize;
      
      final results = await db.query(
        'products',
        limit: _pageSize,
        offset: offset,
        orderBy: 'pname ASC',
      );

      final newProducts = results.map((row) => Product(
        prcode: row['prcode'] as String? ?? '',
        pcode: row['pcode'] as String? ?? '',
        pname: row['pname'] as String? ?? '',
        tprice: (row['tprice'] as num?)?.toString() ?? '',
        pdisc: (row['pdisc'] as num?)?.toString() ?? '',
      )).toList();

      setState(() {
        _products.addAll(newProducts);
        _productsPage++;
        _isLoadingProducts = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingProducts = false;
      });
      _showErrorSnackBar('Error loading products: $e');
    }
  }

  Future<void> _loadOfflineFilesInfo() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final offlineDir = Directory('${directory.path}/offline_data');
      
      if (!await offlineDir.exists()) {
        setState(() {
          _offlineFiles = [];
        });
        return;
      }

      final files = await offlineDir.list().where((entity) => 
        entity is File && entity.path.endsWith('.json')
      ).toList();

      final fileInfos = <OfflineFileInfo>[];
      
      for (final file in files.take(10)) { // Limit to 10 files to prevent overload
        try {
          final fileEntity = file as File;
          final fileName = fileEntity.path.split('/').last;
          final size = await fileEntity.length();
          
          // Read first few lines for preview (lightweight)
          String preview = '';
          int recordCount = 0;
          
          try {
            final content = await fileEntity.readAsString();
            final jsonData = json.decode(content);
            
            if (jsonData is List) {
              recordCount = jsonData.length;
              if (jsonData.isNotEmpty && jsonData.first is Map) {
                final firstRecord = jsonData.first as Map;
                preview = firstRecord.toString().substring(0, 
                  firstRecord.toString().length > 100 ? 100 : firstRecord.toString().length
                );
              }
            } else if (jsonData is Map) {
              recordCount = 1;
              preview = jsonData.toString().substring(0, 
                jsonData.toString().length > 100 ? 100 : jsonData.toString().length
              );
            }
          } catch (e) {
            preview = 'Error reading file';
          }
          
          fileInfos.add(OfflineFileInfo(
            fileName: fileName,
            size: size,
            recordCount: recordCount,
            preview: preview,
          ));
        } catch (e) {
          print('Error processing file ${file.path}: $e');
        }
      }

      setState(() {
        _offlineFiles = fileInfos;
      });
    } catch (e) {
      print('Error loading offline files: $e');
      setState(() {
        _offlineFiles = [];
      });
    }
  }

  Future<void> _importOfflineData() async {
    if (_isImporting) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Offline Data'),
        content: const Text('This will import data from offline JSON files into SQLite. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Import'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isImporting = true;
    });

    try {
      final directory = await getApplicationDocumentsDirectory();
      final offlineDir = Directory('${directory.path}/offline_data');
      
      if (!await offlineDir.exists()) {
        _showErrorSnackBar('Offline data directory not found');
        return;
      }

      int importedCount = 0;
      
      // Import clients
      final clientsFile = File('${offlineDir.path}/getOrclClients.json');
      if (await clientsFile.exists()) {
        final content = await clientsFile.readAsString();
        final clientsData = json.decode(content) as List;
        
        for (final clientData in clientsData) {
          try {
            await _dbService.saveClient(Client(
              code: clientData['code']?.toString() ?? '',
              name: clientData['name']?.toString() ?? '',
              city: clientData['city']?.toString() ?? '',
              area: clientData['area']?.toString() ?? '',
              address: clientData['address']?.toString() ?? '',
            ));
            importedCount++;
          } catch (e) {
            print('Error importing client: $e');
          }
        }
      }

      // Import products
      final productsFile = File('${offlineDir.path}/getOrclProds.json');
      if (await productsFile.exists()) {
        final content = await productsFile.readAsString();
        final productsData = json.decode(content) as List;
        
        for (final productData in productsData) {
          try {
            await _dbService.saveProduct(Product(
              prcode: productData['prcode']?.toString() ?? '',
              pcode: productData['pcode']?.toString() ?? '',
              pname: productData['pname']?.toString() ?? '',
              tprice: productData['tprice']?.toString() ?? '',
              pdisc: productData['pdisc']?.toString() ?? '',
            ));
            importedCount++;
          } catch (e) {
            print('Error importing product: $e');
          }
        }
      }

      // Refresh data after import
      await _loadSummaryData();
      
      _showSuccessSnackBar('Successfully imported $importedCount records');
      
    } catch (e) {
      _showErrorSnackBar('Error importing data: $e');
    } finally {
      setState(() {
        _isImporting = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _kv(String key, String value) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              key,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value.length > 20 ? '${value.substring(0, 20)}...' : value,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Data'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: _isLoadingSummary
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading debug data...'),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary section
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Database Summary',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _summaryItem('Clients', _clientsCount, Colors.blue),
                                _summaryItem('Products', _productsCount, Colors.green),
                                _summaryItem('Stock', _stockCount, Colors.orange),
                              ],
                            ),
                            const SizedBox(height: 8),
                    Row(
                      children: [
                                _summaryItem('Cities', _citiesCount, Colors.purple),
                                _summaryItem('Areas', _areasCount, Colors.red),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Clients section with pagination
                    _buildDataSection(
                      title: 'Clients (SQLite)',
                      data: _clients,
                      isLoading: _isLoadingClients,
                      hasMore: _clients.length < _clientsCount,
                      onLoadMore: _loadClientsPage,
                      itemBuilder: (client) => _buildClientRow(client),
                      emptyMessage: 'No client records found.',
                    ),

                    // Products section with pagination
                    _buildDataSection(
                      title: 'Products (SQLite)',
                      data: _products,
                      isLoading: _isLoadingProducts,
                      hasMore: _products.length < _productsCount,
                      onLoadMore: _loadProductsPage,
                      itemBuilder: (product) => _buildProductRow(product),
                      emptyMessage: 'No product records found.',
                    ),

                    // Offline files section
                    if (!_isLoadingFiles) ...[
                      const SizedBox(height: 16),
                      Card(
                        color: Colors.grey.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Offline JSON Files',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: _isImporting ? null : _importOfflineData,
                                    icon: _isImporting
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        : const Icon(Icons.download),
                                    label: Text(_isImporting ? 'Importing...' : 'Import Data'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                              const SizedBox(height: 12),
                              if (_offlineFiles.isEmpty)
                                const Text(
                                  'No offline JSON files found.',
                                  style: TextStyle(color: Colors.grey),
                                )
                              else
                                ..._offlineFiles.map((file) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                    Row(
                      children: [
                        Expanded(
                                            child: Text(
                                              file.fileName,
                                              style: const TextStyle(fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                          Text(
                                            '${file.recordCount} records',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        'Size: ${(file.size / 1024).toStringAsFixed(1)} KB',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                      if (file.preview != null && file.preview!.isNotEmpty)
                                        Text(
                                          'Preview: ${file.preview}',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 11,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      const Divider(),
                                    ],
                                  ),
                                )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _summaryItem(String label, int count, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSection<T>({
    required String title,
    required List<T> data,
    required bool isLoading,
    required bool hasMore,
    required VoidCallback onLoadMore,
    required Widget Function(T item) itemBuilder,
    required String emptyMessage,
  }) {
    return Card(
      color: Colors.grey.shade50,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            if (data.isEmpty && !isLoading)
              Text(emptyMessage, style: const TextStyle(color: Colors.red))
            else ...[
              ...data.map(itemBuilder),
              if (hasMore || isLoading)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Center(
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : TextButton(
                            onPressed: onLoadMore,
                            child: const Text('Load More'),
                          ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildClientRow(Client client) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _kv('Code', client.code),
                _kv('Name', client.name),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _kv('City', client.city),
                _kv('Area', client.area),
              ],
            ),
            if (client.address.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: _kv('Address', client.address),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductRow(Product product) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _kv('PRCode', product.prcode),
                _kv('PCode', product.pcode),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _kv('Name', product.pname),
                _kv('Price', product.tprice),
                _kv('Disc', product.pdisc),
              ],
            ),
          ],
              ),
            ),
    );
  }
} 
