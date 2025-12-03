import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'products_page.dart';
import 'enhanced_products_page.dart';
import '../../data/datasources/products_remote_data_source.dart';
import '../../data/repositories/products_repository_impl.dart';
import '../../domain/usecases/get_products.dart';
import '../../presentation/bloc/products_bloc.dart';
import '../../presentation/bloc/products_event.dart';

class ProductsLayoutSelector extends StatelessWidget {
  const ProductsLayoutSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Browse Products',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
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
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1E3A8A).withOpacity(0.1),
                        ),
                        child: const Icon(
                          Icons.inventory_2,
                          size: 30,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Choose Product Layout',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Select your preferred way to browse products',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Layout Options
                Column(
                  children: [
                    // New Layout Option
                    _LayoutOptionCard(
                      title: 'Enhanced Layout',
                      subtitle: 'New Professional Design',
                      description: 'Advanced filtering, search, favorites, grid/list view, and modern UI with dummy data',
                      icon: Icons.grid_view,
                      color: const Color(0xFF10B981),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const EnhancedProductsPage(),
                          ),
                        );
                      },
                      features: [
                        'Advanced Search & Filtering',
                        'Category-based Filtering',
                        'Price Range Slider',
                        'Favorites System',
                        'Grid/List View Toggle',
                        'Modern Professional UI',
                        'Dummy Data for Testing',
                        'Real-time Filtering',
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Old Layout Option
                    _LayoutOptionCard(
                      title: 'Classic Layout',
                      subtitle: 'Original Working Design',
                      description: 'Simple and functional layout with real API integration',
                      icon: Icons.list_alt,
                      color: const Color(0xFF3B82F6),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BlocProvider(
                              create: (_) => ProductsBloc(
                                getProducts: GetProducts(
                                  ProductsRepositoryImpl(
                                    remoteDataSource: ProductsRemoteDataSourceImpl(
                                      baseUrl: 'http://137.59.224.222:8080',
                                    ),
                                  ),
                                ),
                              )..add(const ProductsEvent.loadProducts()),
                              child: const ProductsPage(),
                            ),
                          ),
                        );
                      },
                      features: [
                        'Real API Integration',
                        'Simple List View',
                        'Basic Search',
                        'Product Details',
                        'Working Backend',
                        'Live Data',
                        'Stable Performance',
                        'Original Design',
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Footer
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Enhanced Layout uses dummy data for demonstration. Classic Layout connects to real API.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
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
    );
  }
}

class _LayoutOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final List<String> features;

  const _LayoutOptionCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
                  child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  color.withOpacity(0.05),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withOpacity(0.1),
                      ),
                      child: Icon(
                        icon,
                        size: 24,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: color,
                      size: 18,
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Description
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    height: 1.3,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Features
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: features.map((feature) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        feature,
                        style: TextStyle(
                          fontSize: 10,
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
      ),
    );
  }
} 
