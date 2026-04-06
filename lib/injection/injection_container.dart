import 'package:flutter_library/injection/modules/book_details_injection.dart';
import 'package:flutter_library/injection/modules/book_upload_injection.dart';
import 'package:flutter_library/injection/modules/books_injection.dart';
import 'package:flutter_library/injection/modules/cart_injection.dart';
import 'package:flutter_library/injection/modules/core_injection.dart';
import 'package:flutter_library/injection/modules/favorites_injection.dart';
import 'package:flutter_library/injection/modules/library_injection.dart';
import 'package:flutter_library/injection/modules/notifications_injection.dart';
import 'package:flutter_library/injection/modules/orders_injection.dart';
import 'package:flutter_library/injection/modules/policies_injection.dart';
import 'package:flutter_library/injection/modules/profile_injection.dart';
import 'package:flutter_library/injection/modules/settings_injection.dart';

export 'package:flutter_library/injection/modules/core_injection.dart' show sl;

Future<void> initializeDependencies() async {
  // Core: external deps, networking, navigation, logging
  await initCoreDependencies();

  // Features (order does not matter — all use lazy singletons)
  initBooksDependencies();
  initFavoritesDependencies();
  initBookDetailsDependencies();
  initBookUploadDependencies();
  initLibraryDependencies();
  initPoliciesDependencies();
  initCartDependencies();
  initOrdersDependencies();
  initProfileDependencies();
  initSettingsDependencies();
  // Notifications must come after cart (PendingRequestService depends on cart)
  initNotificationsDependencies();
}
