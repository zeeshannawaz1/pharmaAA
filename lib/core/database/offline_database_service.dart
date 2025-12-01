import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../features/sales_order/domain/entities/product.dart';
import '../../features/sales_order/domain/entities/client.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:core'; // Added for Stopwatch

class OfflineDatabaseService {
  static Database? _database;
  static const String _databaseName = 'offline_data.db';
  static const int _databaseVersion = 2; // Increment version for new table

  // Singleton pattern
  static final OfflineDatabaseService _instance = OfflineDatabaseService._internal();
  factory OfflineDatabaseService() => _instance;
  OfflineDatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create products table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        prcode TEXT NOT NULL,
        pcode TEXT NOT NULL,
        pname TEXT NOT NULL,
        tprice REAL NOT NULL,
        pdisc REAL NOT NULL,
        last_updated INTEGER NOT NULL
      )
    ''');

    // Create clients table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS clients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        client_code TEXT NOT NULL UNIQUE,
        client_name TEXT NOT NULL,
        contact_info TEXT,
        address TEXT,
        city TEXT,
        area TEXT,
        last_updated INTEGER NOT NULL
      )
    ''');

    // Create stock table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS stock (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pcode TEXT NOT NULL,
        pname TEXT NOT NULL,
        packing TEXT,
        tprice REAL NOT NULL,
        opqty REAL NOT NULL,
        purqty REAL NOT NULL,
        sqlty REAL NOT NULL,
        clqty REAL NOT NULL,
        date TEXT NOT NULL,
        prcode TEXT NOT NULL,
        prgcode TEXT NOT NULL,
        last_updated INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add stock table for version 2
      await db.execute('''
        CREATE TABLE IF NOT EXISTS stock (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          pcode TEXT NOT NULL,
          pname TEXT NOT NULL,
          packing TEXT,
          tprice REAL NOT NULL,
          opqty REAL NOT NULL,
          purqty REAL NOT NULL,
          sqlty REAL NOT NULL,
          clqty REAL NOT NULL,
          date TEXT NOT NULL,
          prcode TEXT NOT NULL,
          prgcode TEXT NOT NULL,
          last_updated INTEGER NOT NULL
        )
      ''');
    }
    // Add area column to clients if not exists
    try {
      await db.execute("ALTER TABLE clients ADD COLUMN area TEXT;");
    } catch (e) {
      // Ignore if already exists
    }
  }

  // Add migration for city column if not exists
  Future<void> migrateAddCityColumn() async {
    final db = await database;
    await db.execute("ALTER TABLE clients ADD COLUMN city TEXT;");
  }

  // Products operations
  Future<void> saveProducts(List<Product> products) async {
    final db = await database;
    final batch = db.batch();
    final stopwatch = Stopwatch()..start();
    
    // Upsert products (replace on conflict)
    for (final product in products) {
      batch.insert(
        'products',
        {
        'prcode': product.prcode,
        'pcode': product.pcode,
        'pname': product.pname,
        'tprice': double.tryParse(product.tprice) ?? 0.0,
        'pdisc': double.tryParse(product.pdisc) ?? 0.0,
        'last_updated': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit(noResult: true, continueOnError: true);
    stopwatch.stop();
    print('saveProducts: Synced ${products.length} products in  [32m${stopwatch.elapsedMilliseconds}ms [0m');
  }

  Future<List<Product>> getOfflineProducts() async {
    try {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    
    return List.generate(maps.length, (i) {
        final map = maps[i];
      return Product(
          prcode: map['prcode']?.toString() ?? '',
          pcode: map['pcode']?.toString() ?? '',
          pname: map['pname']?.toString() ?? '',
          tprice: map['tprice']?.toString() ?? '0.0',
          pdisc: map['pdisc']?.toString() ?? '0.0',
      );
    });
    } catch (e) {
      print('Error getting offline products: $e');
      return [];
    }
  }

  Future<int> getOfflineProductsCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM products');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Clients operations
  Future<void> saveClients(List<Client> clients) async {
    final db = await database;
    final batch = db.batch();
    final stopwatch = Stopwatch()..start();
    
    // Upsert clients (replace on conflict)
    for (final client in clients) {
      batch.insert(
        'clients',
        {
        'client_code': client.code,
        'client_name': client.name,
        'contact_info': '',
        'address': client.address,
        'city': client.city,
        'area': client.area,
        'last_updated': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit(noResult: true, continueOnError: true);
    stopwatch.stop();
    print('saveClients: Synced  [32m${clients.length} [0m clients in   [32m${stopwatch.elapsedMilliseconds}ms [0m');
  }

  Future<List<Client>> getOfflineClients() async {
    try {
    final db = await database;
    // Use DISTINCT to avoid duplicates
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT DISTINCT client_code, client_name, address, city, area 
      FROM clients 
      ORDER BY client_name
    ''');
    
    return List.generate(maps.length, (i) {
        final map = maps[i];
      return Client(
          code: map['client_code']?.toString() ?? '',
          name: map['client_name']?.toString() ?? '',
          address: map['address']?.toString() ?? '',
          city: map['city']?.toString() ?? '',
          area: map['area']?.toString() ?? '',
      );
    });
    } catch (e) {
      print('Error getting offline clients: $e');
      return [];
    }
  }

  // Clear duplicate clients
  Future<void> clearDuplicateClients() async {
    try {
      final db = await database;
      // Delete duplicates keeping only the first occurrence
      await db.rawQuery('''
        DELETE FROM clients 
        WHERE id NOT IN (
          SELECT MIN(id) 
          FROM clients 
          GROUP BY client_code
        )
      ''');
      print('Cleared duplicate clients from database');
    } catch (e) {
      print('Error clearing duplicate clients: $e');
    }
  }

  Future<int> getOfflineClientsCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM clients');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Check for duplicate clients
  Future<Map<String, int>> checkDuplicateClients() async {
    try {
      final db = await database;
      final result = await db.rawQuery('''
        SELECT client_code, COUNT(*) as count 
        FROM clients 
        GROUP BY client_code 
        HAVING COUNT(*) > 1
      ''');
      
      Map<String, int> duplicates = {};
      for (var row in result) {
        duplicates[row['client_code'] as String] = row['count'] as int;
      }
      
      if (duplicates.isNotEmpty) {
        print('Found duplicate clients: $duplicates');
      }
      
      return duplicates;
    } catch (e) {
      print('Error checking duplicate clients: $e');
      return {};
    }
  }

  // Stock operations
  Future<void> saveStockData(List<Map<String, dynamic>> stockData, String date, String prcode, String prgcode) async {
    final db = await database;
    final batch = db.batch();
    final stopwatch = Stopwatch()..start();
    
    // Upsert stock data (replace on conflict)
    for (final stock in stockData) {
      batch.insert(
        'stock',
        {
        'pcode': stock['PCODE'] ?? '',
        'pname': stock['PNAME'] ?? '',
        'packing': stock['PACKING'] ?? '',
        'tprice': stock['TPRICE'] ?? 0.0,
        'opqty': stock['OPQTY'] ?? 0.0,
        'purqty': stock['PURQTY'] ?? 0.0,
        'sqlty': stock['SQLTY'] ?? 0.0,
        'clqty': stock['CLQTY'] ?? 0.0,
        'date': date,
        'prcode': prcode,
        'prgcode': prgcode,
        'last_updated': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit(noResult: true, continueOnError: true);
    stopwatch.stop();
    print('saveStockData: Synced ${stockData.length} stock items in  [32m${stopwatch.elapsedMilliseconds}ms [0m');
  }

  Future<double?> getOfflineStock(String pcode, String date, String prcode, String prgcode) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'stock',
      where: 'pcode = ? AND date = ? AND prcode = ? AND prgcode = ?',
      whereArgs: [pcode, date, prcode, prgcode],
    );
    
    if (maps.isNotEmpty) {
      return maps[0]['clqty']?.toDouble() ?? 0.0;
    }
    return null;
  }

  Future<int> getOfflineStockCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM stock');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Test method to add stock items
  Future<bool> addStockItem({
    required String productId,
    required int quantity,
    required double unitPrice,
    required double discount,
    required double bonus,
  }) async {
    try {
      final db = await database;
      final today = DateTime.now();
      final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      await db.insert('stock', {
        'pcode': productId,
        'pname': 'Test Product',
        'packing': 'Test Packing',
        'tprice': unitPrice,
        'opqty': quantity.toDouble(),
        'purqty': 0.0,
        'sqlty': 0.0,
        'clqty': quantity.toDouble(),
        'date': dateStr,
        'prcode': '0',
        'prgcode': '0',
        'last_updated': DateTime.now().millisecondsSinceEpoch,
      });
      
      return true;
    } catch (e) {
      print('Error adding stock item: $e');
      return false;
    }
  }

  // Test method to check stock API
  Future<bool> testStockAPI() async {
    try {
      print('=== STOCK API TEST ===');
      
      // Get saved configuration
      final prefs = await SharedPreferences.getInstance();
      final config = prefs.getStringList('user_config');
      final baseUrl = config != null && config.length >= 5 ? config[4] : 'http://137.59.224.222:8080';
      
      print('Testing stock API with baseUrl: $baseUrl');
      
      // Test different dates and PR codes
      final testDates = ['2024-01-01', '2024-12-01', '2024-06-01'];
      final testPrCodes = ['0', '1', '2', '3', '4', '5'];
      
      for (final date in testDates) {
        for (final prcode in testPrCodes) {
          try {
            final url = '$baseUrl/getDailySSR.php?p_date=$date&p_prcode=$prcode&p_prgcode=0';
            print('Testing URL: $url');
            
            final response = await http.get(Uri.parse(url));
            print('Response status: ${response.statusCode}');
            print('Response body: ${response.body}');
            
            if (response.statusCode == 200 && response.body.contains('"PCODE":"No Data"') == false) {
              print('Found stock data for date: $date, PR code: $prcode');
              return true;
            }
          } catch (e) {
            print('Error testing stock API: $e');
          }
        }
      }
      
      print('No stock data found for any test combination');
      return false;
    } catch (e) {
      print('Stock API test failed: $e');
      return false;
    }
  }

  // Sync status
  Future<Map<String, dynamic>> getSyncStatus() async {
    final productsCount = await getOfflineProductsCount();
    final clientsCount = await getOfflineClientsCount();
    final stockCount = await getOfflineStockCount();
    
    return {
      'products_count': productsCount,
      'clients_count': clientsCount,
      'stock_count': stockCount,
      'last_sync': DateTime.now().toIso8601String(),
    };
  }

  // Clear all offline data
  Future<void> clearAllOfflineData() async {
    final db = await database;
    await db.delete('products');
    await db.delete('clients');
    await db.delete('stock');
  }

  // Individual save methods for debug screen
  Future<void> saveClient(Client client) async {
    final db = await database;
    await db.insert(
      'clients',
      {
        'client_code': client.code,
        'client_name': client.name,
        'contact_info': '',
        'address': client.address,
        'city': client.city,
        'area': client.area,
        'last_updated': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveProduct(Product product) async {
    final db = await database;
    await db.insert(
      'products',
      {
        'prcode': product.prcode,
        'pcode': product.pcode,
        'pname': product.pname,
        'tprice': double.tryParse(product.tprice) ?? 0.0,
        'pdisc': double.tryParse(product.pdisc) ?? 0.0,
        'last_updated': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
} 
