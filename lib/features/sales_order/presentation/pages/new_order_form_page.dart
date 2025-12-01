import 'package:flutter/material.dart';
import 'dart:math';
import 'package:aa_app/core/database/offline_database_service.dart';
import '../../domain/entities/client.dart';
import '../../domain/entities/product.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/clients_cubit.dart';
import '../../data/repositories/clients_repository_impl.dart';
import '../../data/datasources/clients_remote_data_source.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class NewOrderFormPage extends StatefulWidget {
  const NewOrderFormPage({Key? key}) : super(key: key);

  @override
  State<NewOrderFormPage> createState() => _NewOrderFormPageState();
}

class _NewOrderFormPageState extends State<NewOrderFormPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String orderNo = 'ORD-${1000 + Random().nextInt(9000)}';
  String bookingMan = 'John Doe'; // Dummy, replace with login user
  String? selectedClient;
  String? clientAddress;
  String? clientMobile;
  String? selectedCity;
  String? selectedArea;
  DateTime selectedDate = DateTime.now();
  List<_OrderLine> orderLines = [ _OrderLine() ];
  late AnimationController _controller;
  late Animation<double> _animation;
  // Removed _citiesCubit and _areasCubit

  // Offline clients
  List<Client> _offlineClients = [];
  bool _clientsLoading = true;
  String? _clientsError;

  // Offline products
  List<Product> _offlineProducts = [];
  bool _productsLoading = true;
  String? _productsError;

  // Offline cities
  List<String> _offlineCities = [];
  bool _citiesLoading = true;
  String? _citiesError;

  final List<Map<String, String>> _dummyClients = [
    {'name': 'Alpha Traders', 'address': '123 Main St', 'mobile': '03001234567'},
    {'name': 'Beta Distributors', 'address': '456 Market Rd', 'mobile': '03111234567'},
    {'name': 'Gamma Retailers', 'address': '789 Plaza Ave', 'mobile': '03221234567'},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
    _loadOfflineClients();
    _loadOfflineProducts();
    _loadOfflineCities();
    // Removed _citiesCubit and _areasCubit initialization (GetCities/GetAreas do not exist)
  }

  Future<void> _loadOfflineClients() async {
    setState(() {
      _clientsLoading = true;
      _clientsError = null;
    });
    try {
      final clients = await OfflineDatabaseService().getOfflineClients();
      setState(() {
        _offlineClients = clients;
        _clientsLoading = false;
      });
    } catch (e) {
      setState(() {
        _clientsError = 'Failed to load clients: ${e.toString()}';
        _clientsLoading = false;
      });
    }
  }

  Future<void> _loadOfflineProducts() async {
    setState(() {
      _productsLoading = true;
      _productsError = null;
    });
    try {
      final products = await OfflineDatabaseService().getOfflineProducts();
      setState(() {
        _offlineProducts = products;
        _productsLoading = false;
      });
      print('=== SR-10 PRODUCTS DEBUG ===');
      print('Loaded ${_offlineProducts.length} offline products');
      for (int i = 0; i < _offlineProducts.length; i++) {
        final product = _offlineProducts[i];
        print('  ${i + 1}. ${product.pname} (${product.pcode}) - Rate: ${product.tprice}');
      }
      print('=== END PRODUCTS DEBUG ===');
    } catch (e) {
      setState(() {
        _productsError = 'Failed to load products: ${e.toString()}';
        _productsLoading = false;
      });
    }
  }

  Future<void> _loadOfflineCities() async {
    setState(() {
      _citiesLoading = true;
      _citiesError = null;
    });
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final file = File('${appDocDir.path}/offline_data/getclientcity.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> data = json.decode(content);
        final cities = data.map((e) => e['CITYNAME']?.toString() ?? '').where((c) => c.isNotEmpty).toSet().toList();
        setState(() {
          _offlineCities = cities;
          _citiesLoading = false;
        });
      } else {
        setState(() {
          _citiesError = 'Offline city data not found.';
          _citiesLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _citiesError = 'Failed to load cities: ${e.toString()}';
        _citiesLoading = false;
      });
    }
  }

  Future<int> _getStockForProduct(String pcode) async {
    try {
      final today = DateTime.now();
      final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final stock = await OfflineDatabaseService().getOfflineStock(pcode, dateStr, '0', '0');
      return stock?.toInt() ?? 0;
    } catch (e) {
      print('=== STOCK DEBUG ===');
      print('Failed to get stock for product $pcode: ${e.toString()}');
      print('=== END STOCK DEBUG ===');
      return 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    // Removed _citiesCubit.close() and _areasCubit.close()
    super.dispose();
  }

  void _addLine() {
    setState(() { orderLines.add(_OrderLine()); });
  }

  void _removeLine(int index) {
    setState(() { orderLines.removeAt(index); });
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() { selectedDate = picked; });
    }
  }

  void _showAddClientDialog() async {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final mobileController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Client'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: mobileController,
                decoration: const InputDecoration(labelText: 'Mobile'),
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(context, {
                  'name': nameController.text,
                  'address': addressController.text,
                  'mobile': mobileController.text,
                });
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (result != null) {
      setState(() {
        _dummyClients.add(result);
        selectedClient = result['name'];
        clientAddress = result['address'];
        clientMobile = result['mobile'];
      });
    }
  }

  double get subtotal => orderLines.fold(0, (sum, line) => sum + (line.totalAmount ?? 0));

  @override
  Widget build(BuildContext context) {
    // Build cityField as a local variable
    Widget cityField;
    if (_citiesLoading) {
      cityField = const Center(child: CircularProgressIndicator());
    } else if (_citiesError != null) {
      cityField = Text(_citiesError!, style: const TextStyle(color: Colors.red));
    } else {
      cityField = DropdownButtonFormField<String>(
        value: selectedCity,
        decoration: const InputDecoration(
          labelText: 'Select City (Offline)',
          icon: Icon(Icons.location_city),
        ),
        items: _offlineCities.map((city) {
          return DropdownMenuItem<String>(
            value: city,
            child: Text(city),
          );
        }).toList(),
        onChanged: (val) {
          setState(() {
            selectedCity = val;
          });
        },
      );
    }

    // Build areaField as a local variable
    List<String> areaOptions = [];
    if (selectedCity != null && selectedCity!.isNotEmpty) {
      final normalizedSelectedCity = selectedCity!.trim().toLowerCase();
      areaOptions = _offlineClients
        .where((c) => c.city.trim().toLowerCase() == normalizedSelectedCity)
        .map((c) => c.area)
        .where((a) => a.isNotEmpty)
        .toSet()
        .toList()
        ..sort();
    }
    Widget areaField = DropdownButtonFormField<String>(
      value: selectedArea,
      decoration: const InputDecoration(
        labelText: 'Select Area (Offline)',
        icon: Icon(Icons.map),
      ),
      items: areaOptions.map((area) {
        return DropdownMenuItem<String>(
          value: area,
          child: Text(area),
        );
      }).toList(),
      onChanged: (val) {
        setState(() {
          selectedArea = val;
        });
      },
    );

    // Build clientDropdown as a local variable
    final normalizedSelectedCity = (selectedCity ?? '').trim().toLowerCase();
    final normalizedSelectedArea = (selectedArea ?? '').trim().toLowerCase();
    final filteredClients = _offlineClients.where((c) {
      final cityMatch = normalizedSelectedCity.isEmpty || c.city.trim().toLowerCase() == normalizedSelectedCity;
      final areaMatch = normalizedSelectedArea.isEmpty || c.area.trim().toLowerCase() == normalizedSelectedArea;
      return cityMatch && areaMatch;
    }).toList();
    Widget clientDropdown;
    if (_clientsLoading) {
      clientDropdown = const Center(child: CircularProgressIndicator());
    } else if (_clientsError != null) {
      clientDropdown = Text(_clientsError!, style: const TextStyle(color: Colors.red));
    } else if (filteredClients.isEmpty) {
      clientDropdown = const Text('No offline clients found.', style: TextStyle(color: Colors.orange));
    } else {
      clientDropdown = DropdownButtonFormField<String>(
        value: selectedClient,
        decoration: const InputDecoration(
          labelText: 'Select Client',
          icon: Icon(Icons.person),
        ),
        items: filteredClients.map((client) {
          return DropdownMenuItem<String>(
            value: client.code,
            child: Text(client.name),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedClient = value;
            final client = filteredClients.firstWhere((c) => c.code == value, orElse: () => Client(code: '', name: '', address: '', city: '', area: ''));
            clientAddress = client.address;
          });
        },
        validator: (v) => v == null || v.isEmpty ? 'Client required' : null,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Order (old)'),
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
                  'SRC-2',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Opacity(
            opacity: _animation.value,
            child: Transform.translate(
              offset: Offset(0, 40 * (1 - _animation.value)),
              child: child,
            ),
          );
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Order Info Section ---
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: _infoField('Order No.', orderNo)),
                            const SizedBox(width: 16),
                            Expanded(child: _infoField('Booking Man', bookingMan)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Replace the client dropdown with offline clients
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Add screen name label
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'SRC-1',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            // SRC City dropdown
                            cityField,
                            const SizedBox(height: 8),
                            // Area dropdown
                            if (areaOptions.isNotEmpty) areaField,
                            const SizedBox(height: 8),
                            // Debug info panel
                            Builder(
                              builder: (context) {
                                final normalizedSelectedCity = (selectedCity ?? '').trim().toLowerCase();
                                final uniqueClientCities = _offlineClients.map((c) => c.city.trim().toLowerCase()).toSet();
                                final filteredClients = (normalizedSelectedCity.isEmpty)
                                    ? _offlineClients
                                    : _offlineClients.where((c) => c.city.trim().toLowerCase() == normalizedSelectedCity).toList();
                                return Card(
                                  color: Colors.blue.shade50,
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Debug Info:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[900])),
                                        Text('Selected city: "${selectedCity ?? ''}"'),
                                        Text('Unique client cities: ${uniqueClientCities.join(", ")}'),
                                        Text('Filtered clients: ${filteredClients.length}'),
                                        Text('Total clients: ${_offlineClients.length}'),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            // Clients dropdown
                            clientDropdown,
                          ],
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: _pickDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Order Date & Time',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text('${selectedDate.day}-${selectedDate.month}-${selectedDate.year}  ${selectedDate.hour}:${selectedDate.minute.toString().padLeft(2, '0')}'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // --- Order Items Section ---
                const Text('Order Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: orderLines.length,
                  itemBuilder: (context, idx) {
                    final line = orderLines[idx];
                    // Ensure controllers are initialized and updated
                    line.rateController ??= TextEditingController();
                    line.totalController ??= TextEditingController();
                    line.rateController!.text = (line.rate?.toString() ?? '');
                    line.totalController!.text = (line.totalAmount?.toStringAsFixed(2) ?? '');
                    final isEven = idx % 2 == 0;
                    return Card(
                      color: isEven ? Colors.blue.shade50 : Colors.grey.shade50,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: isEven ? Colors.blue.shade100 : Colors.grey.shade200, width: 1.5),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                      Expanded(child: Text('Sr# ${idx + 1}', style: const TextStyle(fontWeight: FontWeight.bold))),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: orderLines.length > 1 ? () => _removeLine(idx) : null,
                                ),
                              ],
                            ),
                            _productsLoading 
                              ? const Center(child: CircularProgressIndicator())
                              : _productsError != null
                                ? Text(_productsError!, style: const TextStyle(color: Colors.red))
                                : _offlineProducts.isEmpty
                                  ? const Text('No offline products found.', style: TextStyle(color: Colors.orange))
                                  : Autocomplete<String>(
                              optionsBuilder: (TextEditingValue textEditingValue) {
                                if (textEditingValue.text.isEmpty) {
                                          return _offlineProducts.map((p) => p.pname);
                                }
                                final input = textEditingValue.text.toLowerCase();
                                        return _offlineProducts.where((p) => 
                                          p.pname.toLowerCase().contains(input) ||
                                          p.pcode.toLowerCase().contains(input)
                                        ).map((p) => p.pname);
                              },
                              onSelected: (val) {
                                        final prod = _offlineProducts.firstWhere((p) => p.pname == val);
                                setState(() {
                                  line.product = val;
                                          line.rate = double.tryParse(prod.tprice) ?? 0.0;
                                          // Get stock for this product
                                          _getStockForProduct(prod.pcode).then((stock) {
                                            setState(() {
                                              line.stock = stock;
                                            });
                                          });
                                  // recalculate total if qty is already set
                                  if (line.qty != null) {
                                    line.totalAmount = (line.qty ?? 0) * (line.rate ?? 0);
                                  }
                                });
                              },
                              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                                controller.text = line.product ?? '';
                                return TextFormField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  decoration: const InputDecoration(
                                    labelText: 'Product Name',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (val) => val == null || val.isEmpty ? 'Select product' : null,
                                );
                              },
                              optionsViewBuilder: (context, onSelected, options) {
                                if (options.isEmpty) {
                                  return ListTile(
                                    title: const Text('No product found'),
                                  );
                                }
                                return Material(
                                  elevation: 4,
                                  child: ListView(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    children: options.map((name) {
                                              final prod = _offlineProducts.firstWhere((p) => p.pname == name);
                                      return ListTile(
                                        title: Text(name),
                                        subtitle: Row(
                                          children: [
                                                  Flexible(child: Text('Code: ${prod.pcode}')),
                                                    const SizedBox(width: 12),
                                                  Flexible(child: Text('Price: ${prod.tprice}')),
                                          ],
                                        ),
                                        onTap: () => onSelected(name),
                                      );
                                    }).toList(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: line.qty?.toString(),
                                    decoration: const InputDecoration(
                                      labelText: 'Order Qty',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (val) {
                                      setState(() {
                                        line.qty = int.tryParse(val);
                                        line.totalAmount = (line.qty ?? 0) * (line.rate ?? 0);
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    initialValue: line.bonus?.toString(),
                                    decoration: const InputDecoration(
                                      labelText: 'Bonus',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (val) => line.bonus = int.tryParse(val),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: line.disc?.toString(),
                                    decoration: const InputDecoration(
                                      labelText: 'Disc %',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (val) => line.disc = double.tryParse(val),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    controller: line.rateController,
                                    decoration: InputDecoration(
                                      labelText: 'Rate',
                                      border: const OutlineInputBorder(),
                                      filled: true,
                                      fillColor: Colors.grey.shade200,
                                      prefixIcon: const Icon(Icons.lock_outline, color: Colors.blueGrey),
                                    ),
                                    style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w600),
                                    readOnly: true,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    controller: line.totalController,
                                    decoration: InputDecoration(
                                      labelText: 'Total Amount',
                                      border: const OutlineInputBorder(),
                                      filled: true,
                                      fillColor: Colors.grey.shade200,
                                      prefixIcon: const Icon(Icons.info_outline, color: Colors.blueGrey),
                                    ),
                                    style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w600),
                                    readOnly: true,
                                    enableInteractiveSelection: false,
                                  ),
                                ),
                              ],
                            ),
                            if (line.stock != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  'Available Stock: ${line.stock}',
                                  style: TextStyle(
                                    color: (line.stock == 0) ? Colors.red : Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Product'),
                    onPressed: _addLine,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('Subtotal:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Text(
                        subtotal.toStringAsFixed(2),
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        _formKey.currentState?.save();
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Order Saved'),
                            content: const Text('Order has been saved successfully.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Save Order'),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoField(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 2),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    ],
  );
}

class _OrderLine {
  String? product;
  int? qty;
  int? bonus;
  double? disc;
  double? rate;
  double? totalAmount;
  int? stock;
  TextEditingController? rateController;
  TextEditingController? totalController;
} 
