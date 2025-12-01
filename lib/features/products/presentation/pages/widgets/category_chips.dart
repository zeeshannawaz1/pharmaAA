import 'package:flutter/material.dart';

class CategoryChips extends StatelessWidget {
  final List<String> categories;
  final Map<String, String> categoryNames;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryChips({
    Key? key,
    required this.categories,
    required this.categoryNames,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final isSelected = category == selectedCategory;
          final displayName = category == 'All' 
              ? 'All Categories' 
              : categoryNames[category] ?? category;
          
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Flexible(
                child: Text(
                  displayName,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF1E3A8A),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                onCategorySelected(category);
              },
              backgroundColor: Colors.grey.shade100,
              selectedColor: const Color(0xFF1E3A8A),
              checkmarkColor: Colors.white,
              side: BorderSide(
                color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey.shade300,
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          );
        }).toList(),
      ),
    );
  }
} 
