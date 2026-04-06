import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_library/features/library/presentation/bloc/library_bloc.dart';
import 'package:flutter_library/features/library/presentation/pages/library_page.dart';
import 'package:flutter_library/injection/injection_container.dart';

/// Provider wrapper for LibraryPage with LibraryBloc
class LibraryPageProvider extends StatelessWidget {
  const LibraryPageProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<LibraryBloc>(),
      child: const LibraryPage(),
    );
  }
}
