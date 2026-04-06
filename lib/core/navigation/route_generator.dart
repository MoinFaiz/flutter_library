import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_library/core/theme/app_dimensions.dart';
import 'package:flutter_library/core/navigation/app_routes.dart';
import 'package:flutter_library/core/presentation/main_navigation_scaffold.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/favorites/presentation/pages/favorites_page.dart';
import 'package:flutter_library/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:flutter_library/features/book_details/presentation/pages/book_details_page_provider.dart';
import 'package:flutter_library/features/book_details/presentation/pages/book_reviews_page.dart';
import 'package:flutter_library/features/book_details/presentation/pages/book_reviews_page_args.dart';
import 'package:flutter_library/features/book_upload/presentation/pages/add_book_page.dart';
import 'package:flutter_library/features/settings/presentation/pages/settings_page.dart';
import 'package:flutter_library/features/profile/presentation/pages/profile_page_provider.dart';
import 'package:flutter_library/features/orders/presentation/pages/orders_page.dart';
import 'package:flutter_library/features/feedback/presentation/pages/feedback_page_provider.dart';
import 'package:flutter_library/features/cart/presentation/pages/cart_page.dart';
import 'package:flutter_library/features/cart/presentation/pages/cart_notifications_page.dart';
import 'package:flutter_library/features/policies/presentation/pages/terms_conditions_page.dart';
import 'package:flutter_library/features/policies/presentation/pages/shipping_delivery_policy_page.dart';
import 'package:flutter_library/features/policies/presentation/pages/cancellation_refund_policy_page.dart';
import 'package:flutter_library/features/policies/presentation/pages/privacy_policy_page.dart';
import 'package:flutter_library/injection/injection_container.dart';

/// Route generator for the application
class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    
    switch (settings.name) {
      case AppRoutes.main:
        return _buildRoute(const MainNavigationScaffold(), settings);
        
      case AppRoutes.addBook:
        return _buildRoute(const AddBookPage(), settings);
        
      case AppRoutes.favorites:
        return _buildRoute(
          BlocProvider(
            create: (context) => sl<FavoritesBloc>(),
            child: const FavoritesPage(),
          ),
          settings,
        );
        case AppRoutes.bookDetails:
        if (args is Book) {
          return _buildRoute(
            BookDetailsPageProvider(book: args),
            settings,
          );
        }
        return _buildErrorRoute('Book data is required', settings);
        
      case AppRoutes.bookReviews:
        if (args is BookReviewsPageArgs) {
          return _buildRoute(
            BookReviewsPage(args: args),
            settings,
          );
        }
        return _buildErrorRoute('Book reviews data is required', settings);
        
      case AppRoutes.settings:
        return _buildRoute(
          const SettingsPage(),
          settings,
        );
        
      case AppRoutes.profile:
        return _buildRoute(
          const ProfilePageProvider(),
          settings,
        );

      case AppRoutes.cart:
        return _buildRoute(
          const CartPage(),
          settings,
        );

      case AppRoutes.cartNotifications:
        return _buildRoute(
          const CartNotificationsPage(),
          settings,
        );
        
      // Drawer routes
      case AppRoutes.orders:
        return _buildRoute(
          const OrdersPage(),
          settings,
        );

      case AppRoutes.feedback:
        return _buildRoute(
          const FeedbackPageProvider(),
          settings,
        );

      case AppRoutes.termsConditions:
        return _buildRoute(
          const TermsConditionsPage(),
          settings,
        );

      case AppRoutes.shippingDeliveryPolicy:
        return _buildRoute(
          const ShippingDeliveryPolicyPage(),
          settings,
        );

      case AppRoutes.cancellationRefundPolicy:
        return _buildRoute(
          const CancellationRefundPolicyPage(),
          settings,
        );

      case AppRoutes.privacyPolicy:
        return _buildRoute(
          const PrivacyPolicyPage(),
          settings,
        );
        
      default:
        return _buildErrorRoute('Route not found', settings);
    }
  }
  
  static MaterialPageRoute _buildRoute(Widget page, RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => page,
      settings: settings,
    );
  }
  
  static Route<dynamic> _buildErrorRoute(String message, RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: AppDimensions.icon3Xl + AppDimensions.spaceMd, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: AppDimensions.spaceMd),
              Text(
                message,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.spaceMd),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
      settings: settings,
    );
  }
}
