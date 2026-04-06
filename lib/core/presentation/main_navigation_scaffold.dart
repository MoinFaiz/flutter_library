import 'package:flutter/material.dart';
import 'package:flutter_library/core/navigation/app_routes.dart';
import 'package:flutter_library/core/navigation/navigation_service.dart';
import 'package:flutter_library/features/home/presentation/pages/home_page_provider.dart';
import 'package:flutter_library/features/library/presentation/pages/library_page_provider.dart';
import 'package:flutter_library/features/notifications/presentation/pages/notifications_page_provider.dart';
import 'package:flutter_library/features/notifications/domain/services/pending_request_service.dart';
import 'package:flutter_library/shared/widgets/app_drawer.dart';
import 'package:flutter_library/injection/injection_container.dart';

/// Main navigation scaffold with bottom navigation bar
class MainNavigationScaffold extends StatefulWidget {
  const MainNavigationScaffold({super.key});

  @override
  State<MainNavigationScaffold> createState() => _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends State<MainNavigationScaffold> {
  int _currentIndex = 0;
  final NavigationService _navigationService = sl<NavigationService>();
  bool _hasCheckedPendingRequests = false;

  final List<Widget> _pages = [
    const HomePageProvider(),
    const LibraryPageProvider(),
    const NotificationsPageProvider(),
  ];

  @override
  void initState() {
    super.initState();
    // Check for pending requests after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPendingRequestsOnStartup();
    });
  }

  Future<void> _checkPendingRequestsOnStartup() async {
    if (_hasCheckedPendingRequests || !mounted) return;
    
    _hasCheckedPendingRequests = true;
    
    if (!mounted || !sl.isRegistered<PendingRequestService>()) {
      return;
    }

    final pendingRequestService = sl<PendingRequestService>();
    await pendingRequestService.checkAndShowPendingRequests(context);
  }

  void _onItemTapped(int index, BuildContext context) {
    int? targetIndex;

    switch (index) {
      case 0: // Home
        targetIndex = 0;
        break;
      case 1: // Library
        targetIndex = 1;
        break;
      case 2: // Add
        _navigationService.navigateTo(AppRoutes.addBook);
        break;
      case 3: // Notifications
        targetIndex = 2;
        break;
      case 4: // Drawer
        Scaffold.of(context).openDrawer();
        break;
    }

    if (targetIndex != null && targetIndex != _currentIndex) {
      setState(() {
        _currentIndex = targetIndex!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Builder(
        builder: (context) {
          // Map page index to navigation index
          int navIndex = _currentIndex;
          if (_currentIndex == 2) { // Notifications page -> nav index 3
            navIndex = 3;
          }
          
          return BottomNavigationBar(
            currentIndex: navIndex,
            onTap: (index) => _onItemTapped(index, context),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Theme.of(context).colorScheme.surface,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
            selectedLabelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            unselectedLabelStyle: Theme.of(context).textTheme.labelSmall,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.library_books_outlined),
              activeIcon: Icon(Icons.library_books),
              label: 'Library',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_outlined),
              activeIcon: Icon(Icons.add),
              label: 'Add',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined),
              activeIcon: Icon(Icons.notifications),
              label: 'Notifications',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_outlined),
              activeIcon: Icon(Icons.menu),
              label: 'Drawer',
            ),
          ],
          );
        },
      ),
    );
  }
}
