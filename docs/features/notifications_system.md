# Notifications System

## Overview
The notifications system provides comprehensive notification management for the Flutter Library app, including information notifications and interactive book request notifications.

## Features

### 1. **Information Notifications**
- Book due reminders
- New book announcements
- Book return confirmations
- System updates
- Overdue notifications

### 2. **Book Request Notifications**
- Rental requests
- Purchase offers
- Borrowing requests
- Interactive accept/reject functionality
- Detailed requester information
- Pickup scheduling
- Offer price display

## Architecture

The notifications feature follows clean architecture principles with clear separation of concerns:

### Domain Layer
- **Entities**: `AppNotification`, `BookRequestNotification`
- **Repositories**: `NotificationsRepository` (abstract)
- **Use Cases**: 
  - `GetNotificationsUseCase`
  - `GetUnreadCountUseCase`
  - `MarkNotificationAsReadUseCase`
  - `AcceptBookRequestUseCase`
  - `RejectBookRequestUseCase`

### Data Layer
- **Models**: `NotificationModel`, `BookRequestNotificationModel`
- **Data Sources**: 
  - `NotificationsRemoteDataSource` (API communication)
  - `NotificationsLocalDataSource` (Local caching)
- **Repository Implementation**: `NotificationsRepositoryImpl`

### Presentation Layer
- **BLoC**: `NotificationsBloc` with comprehensive state management
- **Widgets**: 
  - `NotificationCard` (Main notification widget)
  - `InfoNotificationCard` (Information notifications)
  - `BookRequestCard` (Interactive book request notifications)
- **Pages**: `NotificationsPage` with `NotificationsPageProvider`

## Notification Types

### Information Notifications
```dart
enum NotificationType {
  information,
  reminder,
  newBook,
  bookReturned,
  overdue,
  systemUpdate,
}
```

### Book Request Types
```dart
enum RequestType {
  rent,
  buy,
  borrow,
}

enum RequestStatus {
  pending,
  accepted,
  rejected,
  completed,
  cancelled,
}
```

## Usage

### 1. **View Notifications**
Users can view all notifications in a scrollable list with pull-to-refresh functionality.

### 2. **Interactive Actions**
- Mark individual notifications as read
- Mark all notifications as read
- Delete notifications
- Accept/reject book requests with optional reason

### 3. **Real-time Updates**
The system supports real-time notification updates through streams.

## Key Components

### NotificationsBloc
Manages all notification-related state and user interactions:
- Loading notifications
- Handling user actions (accept/reject/delete)
- Real-time updates
- Error handling

### BookRequestCard
Interactive widget for book request notifications featuring:
- Request type indicators (rent/buy/borrow)
- Status chips (pending/accepted/rejected)
- User information display
- Price offers for purchase requests
- Pickup date and location
- Accept/reject buttons with confirmation dialogs

### Data Management
- **Remote**: API communication for fetching and updating notifications
- **Local**: SharedPreferences caching for offline functionality
- **Sync**: Automatic cache updates on successful API operations

## Integration

The notifications feature is integrated into the main navigation through:
1. **Bottom Navigation**: Direct access to notifications page
2. **Dependency Injection**: Full DI setup in `injection_container.dart`
3. **State Management**: BLoC pattern with reactive updates

## Mock Data
During development, the system uses comprehensive mock data including:
- Various notification types
- Sample book request notifications
- Different request statuses
- Realistic user interactions

## Future Enhancements
- Push notification support
- Real-time WebSocket connections
- Advanced filtering and sorting
- Notification preferences
- Email/SMS integration
