import 'package:dio/dio.dart';
import 'package:flutter_library/core/error/exceptions.dart';
import 'package:flutter_library/features/cart/data/datasources/cart_remote_datasource.dart';
import 'package:flutter_library/features/cart/data/models/cart_item_model.dart';
import 'package:flutter_library/features/cart/data/models/cart_request_model.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_item.dart';

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final Dio dio;

  CartRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<CartItemModel>> getCartItems() async {
    try {
      final response = await dio.get('/cart/items');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] as List<dynamic>;
        return data.map((json) => CartItemModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ServerException('Failed to fetch cart items');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<CartItemModel> addToCart({
    required String bookId,
    required CartItemType type,
    int rentalPeriodInDays = 14,
  }) async {
    try {
      final response = await dio.post(
        '/cart/add',
        data: {
          'book_id': bookId,
          'type': type == CartItemType.rent ? 'rent' : 'purchase',
          'rental_period_in_days': rentalPeriodInDays,
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return CartItemModel.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        throw ServerException('Failed to add to cart');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> removeFromCart(String cartItemId) async {
    try {
      final response = await dio.delete('/cart/items/$cartItemId');
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException('Failed to remove from cart');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<CartRequestModel> sendRentalRequest({
    required String bookId,
    required int rentalPeriodInDays,
  }) async {
    try {
      final response = await dio.post(
        '/cart/requests/rent',
        data: {
          'book_id': bookId,
          'rental_period_in_days': rentalPeriodInDays,
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return CartRequestModel.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        throw ServerException('Failed to send rental request');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<CartRequestModel> sendPurchaseRequest({
    required String bookId,
  }) async {
    try {
      final response = await dio.post(
        '/cart/requests/purchase',
        data: {
          'book_id': bookId,
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return CartRequestModel.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        throw ServerException('Failed to send purchase request');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<CartRequestModel>> getMyRequests() async {
    try {
      final response = await dio.get('/cart/requests/sent');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] as List<dynamic>;
        return data.map((json) => CartRequestModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ServerException('Failed to fetch requests');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<CartRequestModel>> getReceivedRequests() async {
    try {
      final response = await dio.get('/cart/requests/received');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] as List<dynamic>;
        return data.map((json) => CartRequestModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ServerException('Failed to fetch received requests');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> acceptRequest(String requestId) async {
    try {
      final response = await dio.post('/cart/requests/$requestId/accept');
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException('Failed to accept request');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> rejectRequest(String requestId, {String? reason}) async {
    try {
      final response = await dio.post(
        '/cart/requests/$requestId/reject',
        data: reason != null ? {'reason': reason} : null,
      );
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException('Failed to reject request');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> cancelRequest(String requestId) async {
    try {
      final response = await dio.post('/cart/requests/$requestId/cancel');
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException('Failed to cancel request');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      final response = await dio.delete('/cart/clear');
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException('Failed to clear cart');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<double> getCartTotal() async {
    try {
      final response = await dio.get('/cart/total');
      
      if (response.statusCode == 200) {
        return (response.data['total'] as num).toDouble();
      } else {
        throw ServerException('Failed to fetch cart total');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
