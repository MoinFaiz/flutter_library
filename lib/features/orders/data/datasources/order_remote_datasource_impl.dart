import 'package:flutter_library/features/orders/data/datasources/order_remote_datasource.dart';
import 'package:flutter_library/features/orders/data/models/order_model.dart';
import 'package:flutter_library/features/orders/domain/entities/order.dart';

/// Implementation of remote data source for orders
class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  // In a real app, you would inject Dio here for HTTP requests
  // final Dio dio;
  // OrderRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<OrderModel>> getUserOrders() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Return mock data
    return _mockOrders;
  }

  @override
  Future<OrderModel> getOrderById(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final order = _mockOrders.firstWhere(
      (order) => order.id == orderId,
      orElse: () => throw Exception('Order not found'),
    );
    
    return order;
  }

  @override
  Future<OrderModel> createOrder({
    required String bookId,
    required String type,
    required double price,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // In a real app, this would make an API call
    throw UnimplementedError('Create order not implemented yet');
  }

  @override
  Future<OrderModel> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    // In a real app, this would make an API call
    throw UnimplementedError('Update order status not implemented yet');
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    // In a real app, this would make an API call
    throw UnimplementedError('Cancel order not implemented yet');
  }

  // Mock data for demonstration - sorted by date (newest first)
  static final List<OrderModel> _mockOrders = [
    // Most recent order first
    OrderModel(
      id: 'ORD005',
      bookId: 'book_005',
      bookTitle: 'Dart Complete Guide',
      bookImageUrl: 'https://via.placeholder.com/150x200/4CAF50/FFFFFF?text=Dart+Guide',
      bookAuthor: 'Michael Chen',
      orderDate: DateTime.now().subtract(const Duration(hours: 12)),
      status: OrderStatus.pending,
      price: 12.99,
      type: OrderType.rental,
    ),
    OrderModel(
      id: 'ORD004',
      bookId: 'book_004',
      bookTitle: 'Advanced Flutter Patterns',
      bookImageUrl: 'https://via.placeholder.com/150x200/2196F3/FFFFFF?text=Advanced+Flutter',
      bookAuthor: 'Emily Johnson',
      orderDate: DateTime.now().subtract(const Duration(days: 1)),
      status: OrderStatus.processing,
      price: 34.99,
      type: OrderType.purchase,
    ),
    // Completed orders (latest first)
    OrderModel(
      id: 'ORD001',
      bookId: 'book_001',
      bookTitle: 'Flutter in Action',
      bookImageUrl: 'https://via.placeholder.com/150x200/FF9800/FFFFFF?text=Flutter+Action',
      bookAuthor: 'Eric Windmill',
      orderDate: DateTime.now().subtract(const Duration(days: 5)),
      status: OrderStatus.delivered,
      price: 29.99,
      type: OrderType.purchase,
      deliveryDate: DateTime.now().subtract(const Duration(days: 2)),
    ),
    OrderModel(
      id: 'ORD002',
      bookId: 'book_002',
      bookTitle: 'Clean Architecture',
      bookImageUrl: 'https://via.placeholder.com/150x200/9C27B0/FFFFFF?text=Clean+Arch',
      bookAuthor: 'Robert C. Martin',
      orderDate: DateTime.now().subtract(const Duration(days: 12)),
      status: OrderStatus.returned,
      price: 5.99,
      type: OrderType.rental,
      returnDate: DateTime.now().subtract(const Duration(days: 5)),
    ),
    OrderModel(
      id: 'ORD003',
      bookId: 'book_003',
      bookTitle: 'Design Patterns',
      bookImageUrl: 'https://via.placeholder.com/150x200/607D8B/FFFFFF?text=Design+Patterns',
      bookAuthor: 'Gang of Four',
      orderDate: DateTime.now().subtract(const Duration(days: 25)),
      status: OrderStatus.completed,
      price: 39.99,
      type: OrderType.purchase,
      deliveryDate: DateTime.now().subtract(const Duration(days: 20)),
    ),
  ];
}
