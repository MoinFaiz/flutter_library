import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_library/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter_library/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter_library/injection/injection_container.dart';

/// Provider wrapper for Profile page with BLoC setup
class ProfilePageProvider extends StatelessWidget {
  const ProfilePageProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ProfileBloc>(),
      child: const ProfilePage(),
    );
  }
}
