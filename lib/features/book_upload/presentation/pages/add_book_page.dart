import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_library/features/book_upload/presentation/bloc/book_upload_bloc.dart';
import 'package:flutter_library/features/book_upload/presentation/bloc/book_upload_event.dart';
import 'package:flutter_library/features/book_upload/presentation/bloc/book_upload_state.dart';
import 'package:flutter_library/features/book_upload/presentation/widgets/book_upload_form.dart';
import 'package:flutter_library/injection/injection_container.dart';

/// Page for adding new books to the library
class AddBookPage extends StatelessWidget {
  const AddBookPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<BookUploadBloc>()..add(const InitializeForm()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Book'),
          actions: [
            BlocBuilder<BookUploadBloc, BookUploadState>(
              builder: (context, state) {
                if (state is BookUploadLoaded && state.form.hasData) {
                  return IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      context.read<BookUploadBloc>().add(const ResetForm());
                    },
                    tooltip: 'Reset Form',
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: const BookUploadForm(),
      ),
    );
  }
}
