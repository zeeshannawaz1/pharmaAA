import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/products_bloc.dart';
import '../bloc/products_event.dart';
import '../bloc/products_state.dart';
import '../../../sales_order/domain/entities/product.dart';
import 'widgets/product_card.dart';
import 'widgets/product_details_modal.dart';
import 'widgets/advanced_filter_sheet.dart';
import 'widgets/category_chips.dart';

class EnhancedProductsPage extends StatefulWidget {
  const EnhancedProductsPage({Key? key}) : super(key: key);

  @override
  State<EnhancedProductsPage> createState() => _EnhancedProductsPageState();
}

class _EnhancedProductsPageState extends State<EnhancedProductsPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // State variables
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _sortBy = 'Name';
  bool _isGridView = true;
  bool _showFavorites = false;
  RangeValues _priceRange = const RangeValues(0, 1000);
  bool _showOnlyDiscounted = false;
  
  final TextEditingController _searchController = TextEditingController();
  final List<Product> _favorites = [];

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
    // Load products on init
    context.read<ProductsBloc>().add(const ProductsEvent.loadProducts());
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _getFilteredProducts(List<Product> allProducts) {
    var filtered = List<Product>.from(allProducts);

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

    // Price range filter
    filtered = filtered.where((product) {
      final price = double.tryParse(product.tprice) ?? 0.0;
      return price >= _priceRange.start && price <= _priceRange.end;
    }).toList();

    // Discount filter
    if (_showOnlyDiscounted) {
      filtered = filtered.where((product) {
        final discount = double.tryParse(product.pdisc) ?? 0.0;
        return discount > 0;
      }).toList();
    }

    // Favorites filter
    if (_showFavorites) {
      filtered = filtered.where((product) => _favorites.contains(product)).toList();
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
      case 'Popularity':
        // Simulate popularity based on product code
        filtered.sort((a, b) => int.parse(a.pcode.substring(1)).compareTo(int.parse(b.pcode.substring(1))));
        break;
    }

    return filtered;
  }

  void _toggleFavorite(Product product) {
    setState(() {
      if (_favorites.contains(product)) {
        _favorites.remove(product);
      } else {
        _favorites.add(product);
      }
    });
  }

  void _showProductDetails(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductDetailsModal(product: product),
    );
  }

  void _showAdvancedFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AdvancedFilterSheet(
        priceRange: _priceRange,
        showOnlyDiscounted: _showOnlyDiscounted,
        onPriceRangeChanged: (range) {
          setState(() {
            _priceRange = range;
          });
        },
        onDiscountedChanged: (value) {
          setState(() {
            _showOnlyDiscounted = value;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsBloc, ProductsState>(
      builder: (context, state) {
        return state.when(
          initial: () => const Center(child: Text('No products available.')),
          loading: () => const Center(child: CircularProgressIndicator()),
          loaded: (allProducts, [warning]) {
            final filteredProducts = _getFilteredProducts(allProducts);
            final categories = allProducts.map((p) => p.prcode).toSet().toList();
            final categoryNames = { for (var p in allProducts) p.prcode: p.prcode };

            return Scaffold(
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                title: const Text('Enhanced Products'),
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
                          'SRC-8',
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
              body: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF1E3A8A),
                      Color(0xFF3B82F6),
                      Color(0xFF60A5FA),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Search and Filter Section
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                                prefixIcon: const Icon(Icons.search, color: Color(0xFF1E3A8A)),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() {
                                            _searchQuery = '';
                                          });
                                        },
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
                                  borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
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
                            
                            // Category Chips
                            CategoryChips(
                              categories: categories,
                              categoryNames: categoryNames,
                              selectedCategory: _selectedCategory,
                              onCategorySelected: (category) {
                                setState(() {
                                  _selectedCategory = category;
                                });
                              },
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Filter Row
                            Column(
                              children: [
                                DropdownButtonFormField<String>(
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
                                    DropdownMenuItem(value: 'Popularity', child: Text('Popularity')),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _sortBy = value!;
                                    });
                                  },
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _searchQuery = '';
                                        _selectedCategory = 'All';
                                        _priceRange = const RangeValues(0, 1000);
                                        _showOnlyDiscounted = false;
                                        _showFavorites = false;
                                        _searchController.clear();
                                      });
                                    },
                                    icon: const Icon(Icons.clear_all),
                                    label: const Text('Clear All'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF1E3A8A),
                                      side: const BorderSide(color: Color(0xFF1E3A8A)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Active Filters Display
                      if (_showOnlyDiscounted || _showFavorites || _priceRange.start > 0 || _priceRange.end < 1000)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Wrap(
                            spacing: 8,
                            children: [
                              if (_showOnlyDiscounted)
                                Chip(
                                  label: const Text('Discounted Only'),
                                  onDeleted: () {
                                    setState(() {
                                      _showOnlyDiscounted = false;
                                    });
                                  },
                                ),
                              if (_showFavorites)
                                Chip(
                                  label: const Text('Favorites Only'),
                                  onDeleted: () {
                                    setState(() {
                                      _showFavorites = false;
                                    });
                                  },
                                ),
                              if (_priceRange.start > 0 || _priceRange.end < 1000)
                                Chip(
                                  label: Text('Price: ${_priceRange.start.round()}-${_priceRange.end.round()} PKR'),
                                  onDeleted: () {
                                    setState(() {
                                      _priceRange = const RangeValues(0, 1000);
                                    });
                                  },
                                ),
                            ],
                          ),
                        ),
                      
                      // Products List
                      Expanded(
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: filteredProducts.isEmpty
                              ? _buildEmptyState()
                              : Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    children: [
                                      // Results Header
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1E3A8A).withOpacity(0.1),
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(16),
                                            topRight: Radius.circular(16),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.inventory_2, color: Color(0xFF1E3A8A)),
                                            const SizedBox(width: 8),
                                            Text(
                                              '${filteredProducts.length} products found',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1E3A8A),
                                              ),
                                            ),
                                            const Spacer(),
                                            if (_favorites.isNotEmpty)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.red.shade100,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  '${_favorites.length} favorites',
                                                  style: TextStyle(
                                                    color: Colors.red.shade700,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
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
                                                  final product = filteredProducts[index];
                                                  return ProductCard(
                                                    product: product,
                                                    onTap: () => _showProductDetails(product),
                                                    isFavorite: _favorites.contains(product),
                                                    onFavoriteToggle: () => _toggleFavorite(product),
                                                  );
                                                },
                                              )
                                            : ListView.separated(
                                                padding: const EdgeInsets.all(16),
                                                itemCount: filteredProducts.length,
                                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                                itemBuilder: (context, index) {
                                                  final product = filteredProducts[index];
                                                  return ProductCard(
                                                    product: product,
                                                    onTap: () => _showProductDetails(product),
                                                    isListView: true,
                                                    isFavorite: _favorites.contains(product),
                                                    onFavoriteToggle: () => _toggleFavorite(product),
                                                  );
                                                },
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          error: (message) => Center(child: Text('Error: $message')),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
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
            Icon(
              _showFavorites ? Icons.favorite_border : Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _showFavorites
                  ? 'No favorite products found'
                  : 'No products found matching your criteria',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _selectedCategory = 'All';
                  _priceRange = const RangeValues(0, 1000);
                  _showOnlyDiscounted = false;
                  _showFavorites = false;
                  _searchController.clear();
                });
              },
              icon: const Icon(Icons.clear),
              label: const Text('Clear All Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
