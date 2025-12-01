import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../sales_order/domain/entities/product.dart';

part 'products_state.freezed.dart';

@freezed
class ProductsState with _$ProductsState {
  const factory ProductsState.initial() = _Initial;
  const factory ProductsState.loading() = _Loading;
  const factory ProductsState.loaded(List<Product> products, {String? warning}) = _Loaded;
  const factory ProductsState.error(String message) = _Error;
} 
