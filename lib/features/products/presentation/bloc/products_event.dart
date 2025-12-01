import 'package:freezed_annotation/freezed_annotation.dart';

part 'products_event.freezed.dart';
 
@freezed
class ProductsEvent with _$ProductsEvent {
  const factory ProductsEvent.loadProducts() = _LoadProducts;
} 
