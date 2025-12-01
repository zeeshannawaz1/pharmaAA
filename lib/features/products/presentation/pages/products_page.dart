import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/products_bloc.dart';
import '../bloc/products_event.dart';
import '../bloc/products_state.dart';
import 'package:aa_app/features/sales_order/domain/entities/product.dart';
import 'widgets/product_card.dart';
import 'widgets/product_details_modal.dart';
import 'widgets/filter_section.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({Key? key}) : super(key: key);

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _sortBy = 'Name';
  bool _isGridView = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _filterProducts(List<Product> products) {
    var filtered = products;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((product) =>
        product.pname.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        product.pcode.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        product.prcode.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // Category filter
    if (_selectedCategory != 'All') {
      filtered = filtered.where((product) =>
        product.prcode == _selectedCategory
      ).toList();
    }

    // Sort
    switch (_sortBy) {
      case 'Name':
        filtered.sort((a, b) => a.pname.compareTo(b.pname));
        break;
      case 'Code':
        filtered.sort((a, b) => a.pcode.compareTo(b.pcode));
        break;
      case 'Price (High to Low)':
        filtered.sort((a, b) {
          final priceA = double.tryParse(a.tprice) ?? 0.0;
          final priceB = double.tryParse(b.tprice) ?? 0.0;
          return priceB.compareTo(priceA);
        });
        break;
      case 'Price (Low to High)':
        filtered.sort((a, b) {
          final priceA = double.tryParse(a.tprice) ?? 0.0;
          final priceB = double.tryParse(b.tprice) ?? 0.0;
          return priceA.compareTo(priceB);
        });
        break;
      case 'Discount':
        filtered.sort((a, b) {
          final discountA = double.tryParse(a.pdisc) ?? 0.0;
          final discountB = double.tryParse(b.pdisc) ?? 0.0;
          return discountB.compareTo(discountA);
        });
        break;
    }

    return filtered;
  }

  List<String> _getCategories(List<Product> products) {
    final categories = products.map((p) => p.prcode).toSet().toList();
    categories.sort();
    return ['All', ...categories];
  }

  void _showProductDetails(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductDetailsModal(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Browse Products',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            tooltip: _isGridView ? 'List View' : 'Grid View',
            color: Theme.of(context).iconTheme.color,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Theme.of(context).scaffoldBackgroundColor, Theme.of(context).colorScheme.primary.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Search and Filter Section
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
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search products by name, code, or category...',
                        prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                                color: Theme.of(context).iconTheme.color,
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Filter Row
                    Row(
                      children: [
                        Expanded(
                          child: BlocBuilder<ProductsBloc, ProductsState>(
                            builder: (context, state) {
                              final categories = state.maybeWhen(
                                loaded: (products, _) => _getCategories(products),
                                orElse: () => ['All'],
                              );
                              
                              return DropdownButtonFormField<String>(
                                value: _selectedCategory,
                                decoration: InputDecoration(
                                  labelText: 'Category',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                items: categories.map((category) {
                                  return DropdownMenuItem(
                                    value: category,
                                    child: Text(category),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCategory = value!;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _sortBy,
                            decoration: InputDecoration(
                              labelText: 'Sort By',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'Name', child: Text('Name')),
                              DropdownMenuItem(value: 'Code', child: Text('Code')),
                              DropdownMenuItem(value: 'Price (High to Low)', child: Text('Price (High to Low)')),
                              DropdownMenuItem(value: 'Price (Low to High)', child: Text('Price (Low to High)')),
                              DropdownMenuItem(value: 'Discount', child: Text('Discount')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _sortBy = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Products List
              Expanded(
                child: BlocBuilder<ProductsBloc, ProductsState>(
                  builder: (context, state) {
                    return state.when(
                      initial: () => _buildEmptyState(
                        icon: Icons.inventory_2,
                        message: 'Ready to browse products',
                        action: ElevatedButton.icon(
                          onPressed: () {
                            context.read<ProductsBloc>().add(const ProductsEvent.loadProducts());
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Load Products'),
                          style: Theme.of(context).elevatedButtonTheme.style,
                        ),
                      ),
                      loading: () => const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(height: 16),
                            Text(
                              'Loading products...',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      loaded: (products, warning) {
                        final filteredProducts = _filterProducts(products.cast<Product>());
                        List<Widget> children = [];
                        if (warning != null && warning.isNotEmpty) {
                          children.add(
                            Container(
                              width: double.infinity,
                              color: Colors.amber[700],
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Row(
                                children: [
                                  const Icon(Icons.warning, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      warning,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        if (filteredProducts.isEmpty) {
                          children.add(_buildEmptyState(
                            icon: Icons.search_off,
                            message: 'No products found matching your criteria',
                            action: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                  _selectedCategory = 'All';
                                  _searchController.clear();
                                });
                              },
                              icon: const Icon(Icons.clear),
                              label: const Text('Clear Filters'),
                              style: Theme.of(context).elevatedButtonTheme.style,
                            ),
                          ));
                        } else {
                          children.add(
                            Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              // Results Header
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.inventory_2, color: Theme.of(context).colorScheme.primary),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${filteredProducts.length} products found',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      'A&A DISTRIBUTOR',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Products Grid/List
                              Expanded(
                                child: _isGridView
                                    ? GridView.builder(
                                        padding: const EdgeInsets.all(16),
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          childAspectRatio: 0.8,
                                          crossAxisSpacing: 16,
                                          mainAxisSpacing: 16,
                                        ),
                                        itemCount: filteredProducts.length,
                                        itemBuilder: (context, index) {
                                          return ProductCard(
                                            product: filteredProducts[index],
                                            onTap: () => _showProductDetails(filteredProducts[index]),
                                          );
                                        },
                                      )
                                    : ListView.separated(
                                        padding: const EdgeInsets.all(16),
                                        itemCount: filteredProducts.length,
                                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                                        itemBuilder: (context, index) {
                                          return ProductCard(
                                            product: filteredProducts[index],
                                            onTap: () => _showProductDetails(filteredProducts[index]),
                                            isListView: true,
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
                            ),
                          );
                        }
                        return Column(
                          children: children,
                        );
                      },
                      error: (message) => _buildEmptyState(
                        icon: Icons.error_outline,
                        message: 'Error loading products: $message',
                        action: ElevatedButton.icon(
                          onPressed: () {
                            context.read<ProductsBloc>().add(const ProductsEvent.loadProducts());
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: Theme.of(context).elevatedButtonTheme.style,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    Widget? action,
  }) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              action,
            ],
          ],
        ),
      ),
    );
  }
} 
