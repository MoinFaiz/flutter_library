import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_library/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:flutter_library/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:flutter_library/features/notifications/presentation/pages/notifications_page.dart';
import 'package:flutter_library/injection/injection_container.dart';

class NotificationsPageProvider extends StatelessWidget {
  const NotificationsPageProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NotificationsBloc>(
      create: (context) => sl<NotificationsBloc>()..add(const LoadNotifications()),
      child: const NotificationsPage(),
    );
  }
}
