import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/client.dart';
import '../bloc/clients_cubit.dart';
import '../../data/datasources/clients_remote_data_source.dart';
import '../../data/repositories/clients_repository_impl.dart';
import '../../domain/usecases/get_clients.dart';
import '../bloc/products_cubit.dart';
import '../../data/datasources/products_remote_data_source.dart';
import '../../data/repositories/products_repository_impl.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/entities/product.dart';
import '../bloc/stock_cubit.dart';
import '../../data/datasources/stock_remote_data_source.dart';
import '../../data/repositories/stock_repository_impl.dart';
import '../../domain/usecases/get_stock.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class SalesOrderPage extends StatefulWidget {
  const SalesOrderPage({Key? key}) : super(key: key);

  @override
  State<SalesOrderPage> createState() => _SalesOrderPageState();
}

class _SalesOrderPageState extends State<SalesOrderPage> {
  final _formKey = GlobalKey<FormState>();
  String? selectedClientCode;
  String clientInput = '';
  List<_OrderLine> orderLines = [ _OrderLine() ];
  String? notes;
  final _clientFieldKey = GlobalKey<FormFieldState>();
  final TextEditingController _clientController = TextEditingController();
  final FocusNode _clientFocusNode = FocusNode();

  // City dropdown state
  List<String> _offlineCities = [];
  bool _citiesLoading = true;
  String? _citiesError;
  String? _selectedCity;

  @override
  void initState() {
    super.initState();
    _loadOfflineCities();
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
        _citiesError = 'Failed to load cities:  [31m${e.toString()} [0m';
        _citiesLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _clientController.dispose();
    _clientFocusNode.dispose();
    super.dispose();
  }

  void _addLine() {
    setState(() { orderLines.add(_OrderLine()); });
  }

  void _removeLine(int index) {
    setState(() { orderLines.removeAt(index); });
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      // TODO: Submit order via Bloc
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order submitted (mock)!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ClientsCubit(
            getClients: GetClients(
              ClientsRepositoryImpl(
                remoteDataSource: ClientsRemoteDataSource(baseUrl: 'http://137.59.224.222:8080'),
              ),
            ),
          ),
        ),
        BlocProvider(
          create: (_) => ProductsCubit(
            getProducts: GetProducts(
              ProductsRepositoryImpl(
                remoteDataSource: ProductsRemoteDataSource(baseUrl: 'http://137.59.224.222:8080'),
              ),
            ),
          ),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('New Sales Order'),
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
                    'SRC-3',
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
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Replace City TextFormField with dropdown
                    if (_citiesLoading) ...[
                      const Center(child: CircularProgressIndicator()),
                    ] else if (_citiesError != null) ...[
                      Text(_citiesError!, style: const TextStyle(color: Colors.red)),
                    ] else ...[
                      DropdownButtonFormField<String>(
                        value: _selectedCity,
                        decoration: const InputDecoration(
                          labelText: 'City (Offline)',
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
                            _selectedCity = val;
                          });
                        },
                      ),
                    ],
                    const SizedBox(height: 12),
                    BlocBuilder<ClientsCubit, ClientsState>(
                      builder: (context, state) {
                        if (state.loading) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (state.error != null) {
                          return Center(child: Text('Failed to load clients: ${state.error}'));
                        }
                        return RawAutocomplete<Client>(
                          textEditingController: _clientController,
                          focusNode: _clientFocusNode,
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            final input = textEditingValue.text.toLowerCase();
                            // Filter clients by selected city
                            List<Client> cityFilteredClients = state.clients;
                            if (_selectedCity != null && _selectedCity!.trim().isNotEmpty) {
                              final normalizedCity = _selectedCity!.trim().toLowerCase();
                              cityFilteredClients = state.clients.where((c) => (c.city.trim().toLowerCase() == normalizedCity)).toList();
                            }
                            if (input.isEmpty) {
                              return cityFilteredClients;
                            }
                            final matches = cityFilteredClients.where((c) => c.name.toLowerCase().contains(input)).toList();
                            return matches;
                          },
                          displayStringForOption: (Client c) => c.name,
                          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                            return TextFormField(
                              key: _clientFieldKey,
                              controller: _clientController,
                              focusNode: _clientFocusNode,
                              decoration: const InputDecoration(
                                labelText: 'Client',
                                border: OutlineInputBorder(),
                              ),
                              validator: (val) {
                                if (selectedClientCode == null || val == null || val.isEmpty) {
                                  return 'Please select a client';
                                }
                                final exists = state.clients.any((c) => c.code == selectedClientCode);
                                if (!exists) {
                                  return 'Please select a valid client';
                                }
                                return null;
                              },
                              onChanged: (val) {
                                setState(() {
                                  clientInput = val;
                                  selectedClientCode = null;
                                });
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
                                            clientInput = client.name;
                                            selectedClientCode = client.code;
                                            _clientController.text = client.name;
                                          });
                                          onSelected(client);
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Products', style: TextStyle(fontWeight: FontWeight.bold)),
                ...orderLines.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final line = entry.value;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: BlocBuilder<ProductsCubit, ProductsState>(
                                  builder: (context, state) {
                                    if (state.loading) {
                                      return const Center(child: CircularProgressIndicator());
                                    } else if (state.error != null) {
                                      return Center(child: Text('Failed to load products: ${state.error}'));
                                    }
                                    return RawAutocomplete<Product>(
                                      textEditingController: line._controller ??= TextEditingController(text: line.product?.pname ?? ''),
                                      focusNode: line._focusNode ??= FocusNode(),
                                      optionsBuilder: (TextEditingValue textEditingValue) {
                                        final input = textEditingValue.text.toLowerCase();
                                        if (input.isEmpty) {
                                          return state.products;
                                        }
                                        return state.products.where((p) =>
                                          p.pname.toLowerCase().contains(input) ||
                                          p.pcode.toLowerCase().contains(input)
                                        );
                                      },
                                      displayStringForOption: (Product p) => p.pname,
                                      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                                        return TextFormField(
                                          controller: controller,
                                          focusNode: focusNode,
                                          decoration: const InputDecoration(
                                            labelText: 'Product',
                                            border: OutlineInputBorder(),
                                          ),
                                          validator: (val) => line.product == null ? 'Select product' : null,
                                          onChanged: (val) {
                                            setState(() {
                                              line.product = null;
                                            });
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
                                            child: const Text('No product found'),
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
                                                  final product = options.elementAt(index);
                                                  return ListTile(
                                                    title: Text(
                                                      '${product.pname} (${product.pcode})',
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                    subtitle: Text('Price: ${product.tprice}', style: const TextStyle(fontSize: 12)),
                                                    onTap: () {
                                                      setState(() {
                                                        line.product = product;
                                                        line._controller?.text = product.pname;
                                                        // Fetch stock for today and this product
                                                        line.stockCubit ??= StockCubit(
                                                          getStock: GetStock(
                                                            StockRepositoryImpl(
                                                              remoteDataSource: StockRemoteDataSource(baseUrl: 'http://137.59.224.222:8080'),
                                                            ),
                                                          ),
                                                        );
                                                        final today = DateTime.now();
                                                        final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
                                                        line.lastStockDate = today;
                                                        
                                                        // Debug logging
                                                        print('=== SRC-10 STOCK DEBUG ===');
                                                        print('Product: ${product.pname} (${product.pcode})');
                                                        print('Date: $dateStr');
                                                        print('PR Code: 0');
                                                        print('PRG Code: 0');
                                                        print('Fetching stock...');
                                                        
                                                        line.stockCubit!.loadStock(date: dateStr, pcode: product.pcode);
                                                      });
                                                      onSelected(product);
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  initialValue: line.qty?.toString(),
                                  decoration: const InputDecoration(
                                    labelText: 'Qty',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (val) => (val == null || int.tryParse(val) == null || int.parse(val) <= 0)
                                    ? 'Enter qty' : null,
                                  onSaved: (val) => line.qty = int.tryParse(val ?? ''),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  controller: line.descController ??= TextEditingController(text: line.desc ?? ''),
                                  decoration: const InputDecoration(
                                    labelText: 'Description (optional)',
                                    border: OutlineInputBorder(),
                                  ),
                                  maxLines: 1,
                                  onChanged: (val) => line.desc = val,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle, color: Colors.red),
                                onPressed: orderLines.length > 1 ? () => _removeLine(idx) : null,
                              ),
                            ],
                          ),
                          if (line.product != null)
                            BlocBuilder<StockCubit, StockState>(
                              bloc: line.stockCubit,
                              builder: (context, stockState) {
                                if (stockState.loading) {
                                  return const Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Text('Loading stock...', style: TextStyle(fontSize: 14, color: Colors.blueGrey)),
                                  );
                                } else if (stockState.error != null) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text('Stock error: ${stockState.error}', style: const TextStyle(fontSize: 14, color: Colors.red)),
                                  );
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    'Price: ${line.product!.tprice}    Stock: ${line.lastStock ?? 0}',
                                    style: const TextStyle(fontSize: 14, color: Colors.blueGrey),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                }),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Product'),
                    onPressed: _addLine,
                  ),
                ),
                const SizedBox(height: 24),
                // Notes
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  onSaved: (val) => notes = val,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Submit Order'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderLine {
  Product? product;
  int? qty;
  String? desc;
  TextEditingController? _controller;
  FocusNode? _focusNode;
  StockCubit? stockCubit;
  double? lastStock;
  DateTime? lastStockDate;
  TextEditingController? descController;
} 
