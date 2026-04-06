import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_library/features/cart/data/models/cart_item_model.dart';

abstract class CartLocalDataSource {
  Future<List<CartItemModel>> getCachedCartItems();
  Future<void> cacheCartItems(List<CartItemModel> items);
  Future<void> clearCache();
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String cartCacheKey = 'CART_ITEMS_CACHE';

  CartLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<CartItemModel>> getCachedCartItems() async {
    final jsonString = sharedPreferences.getString(cartCacheKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => CartItemModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<void> cacheCartItems(List<CartItemModel> items) async {
    final jsonList = items.map((item) => item.toJson()).toList();
    await sharedPreferences.setString(cartCacheKey, json.encode(jsonList));
  }

  @override
  Future<void> clearCache() async {
    await sharedPreferences.remove(cartCacheKey);
  }
}
