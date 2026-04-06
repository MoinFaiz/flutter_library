import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_library/features/cart/data/datasources/cart_notification_local_datasource.dart';
import 'package:flutter_library/features/cart/data/models/cart_notification_model.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_notification.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_item.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late CartNotificationLocalDataSourceImpl dataSource;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = CartNotificationLocalDataSourceImpl(sharedPreferences: mockSharedPreferences);
  });

  group('CartNotificationLocalDataSourceImpl', () {
    final testNotification = CartNotificationModel(
      id: 'notif1',
      requestId: 'req1',
      bookId: 'book1',
      bookTitle: 'Test Book',
      bookAuthor: 'Test Author',
      bookImageUrl: 'https://example.com/image.jpg',
      type: NotificationType.requestReceived,
      requestType: CartItemType.rent,
      message: 'You have a new rental request',
      isRead: false,
      createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
    );

    final testNotification2 = CartNotificationModel(
      id: 'notif2',
      requestId: 'req2',
      bookId: 'book2',
      bookTitle: 'Test Book 2',
      bookAuthor: 'Test Author 2',
      bookImageUrl: 'https://example.com/image2.jpg',
      type: NotificationType.requestAccepted,
      requestType: CartItemType.purchase,
      message: 'Your request was accepted',
      isRead: true,
      createdAt: DateTime.parse('2024-01-02T00:00:00.000Z'),
    );

    group('getCachedNotifications', () {
      test('should return list of notifications when cache exists', () async {
        // Arrange
        final items = [testNotification];
        final jsonString = json.encode(items.map((e) => e.toJson()).toList());
        when(() => mockSharedPreferences.getString(CartNotificationLocalDataSourceImpl.notificationsCacheKey))
            .thenReturn(jsonString);

        // Act
        final result = await dataSource.getCachedNotifications();

        // Assert
        expect(result, isA<List<CartNotificationModel>>());
        expect(result.length, equals(1));
        expect(result.first.id, equals('notif1'));
        verify(() => mockSharedPreferences.getString(CartNotificationLocalDataSourceImpl.notificationsCacheKey)).called(1);
      });

      test('should return empty list when cache is null', () async {
        // Arrange
        when(() => mockSharedPreferences.getString(CartNotificationLocalDataSourceImpl.notificationsCacheKey))
            .thenReturn(null);

        // Act
        final result = await dataSource.getCachedNotifications();

        // Assert
        expect(result, isEmpty);
      });

      test('should handle multiple notifications', () async {
        // Arrange
        final items = [testNotification, testNotification2];
        final jsonString = json.encode(items.map((e) => e.toJson()).toList());
        when(() => mockSharedPreferences.getString(CartNotificationLocalDataSourceImpl.notificationsCacheKey))
            .thenReturn(jsonString);

        // Act
        final result = await dataSource.getCachedNotifications();

        // Assert
        expect(result.length, equals(2));
        expect(result[0].isRead, isFalse);
        expect(result[1].isRead, isTrue);
      });
    });

    group('cacheNotifications', () {
      test('should cache notifications successfully', () async {
        // Arrange
        final items = [testNotification, testNotification2];
        when(() => mockSharedPreferences.setString(any(), any()))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.cacheNotifications(items);

        // Assert
        verify(() => mockSharedPreferences.setString(
          CartNotificationLocalDataSourceImpl.notificationsCacheKey,
          any(),
        )).called(1);
      });

      test('should cache empty list', () async {
        // Arrange
        when(() => mockSharedPreferences.setString(any(), any()))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.cacheNotifications([]);

        // Assert
        verify(() => mockSharedPreferences.setString(
          CartNotificationLocalDataSourceImpl.notificationsCacheKey,
          '[]',
        )).called(1);
      });
    });

    group('getCachedUnreadCount', () {
      test('should return unread count when cached', () async {
        // Arrange
        when(() => mockSharedPreferences.getInt(CartNotificationLocalDataSourceImpl.unreadCountCacheKey))
            .thenReturn(5);

        // Act
        final result = await dataSource.getCachedUnreadCount();

        // Assert
        expect(result, equals(5));
        verify(() => mockSharedPreferences.getInt(CartNotificationLocalDataSourceImpl.unreadCountCacheKey)).called(1);
      });

      test('should return 0 when no cache exists', () async {
        // Arrange
        when(() => mockSharedPreferences.getInt(CartNotificationLocalDataSourceImpl.unreadCountCacheKey))
            .thenReturn(null);

        // Act
        final result = await dataSource.getCachedUnreadCount();

        // Assert
        expect(result, equals(0));
      });
    });

    group('cacheUnreadCount', () {
      test('should cache unread count', () async {
        // Arrange
        when(() => mockSharedPreferences.setInt(any(), any()))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.cacheUnreadCount(10);

        // Assert
        verify(() => mockSharedPreferences.setInt(
          CartNotificationLocalDataSourceImpl.unreadCountCacheKey,
          10,
        )).called(1);
      });

      test('should cache zero count', () async {
        // Arrange
        when(() => mockSharedPreferences.setInt(any(), any()))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.cacheUnreadCount(0);

        // Assert
        verify(() => mockSharedPreferences.setInt(
          CartNotificationLocalDataSourceImpl.unreadCountCacheKey,
          0,
        )).called(1);
      });
    });

    group('clearCache', () {
      test('should clear both caches', () async {
        // Arrange
        when(() => mockSharedPreferences.remove(any()))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.clearCache();

        // Assert
        verify(() => mockSharedPreferences.remove(CartNotificationLocalDataSourceImpl.notificationsCacheKey)).called(1);
        verify(() => mockSharedPreferences.remove(CartNotificationLocalDataSourceImpl.unreadCountCacheKey)).called(1);
      });
    });
  });
}
