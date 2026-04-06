import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/book_details/presentation/pages/book_details_page.dart';
import 'package:flutter_library/features/book_details/presentation/bloc/book_details_bloc.dart';
import 'package:flutter_library/features/book_details/presentation/bloc/reviews_bloc.dart';
import 'package:flutter_library/features/book_details/presentation/bloc/rental_status_bloc.dart';
import 'package:flutter_library/injection/injection_container.dart';

/// Provider wrapper for Book Details page with independent state management
class BookDetailsPageProvider extends StatelessWidget {
  final Book book;

  const BookDetailsPageProvider({
    super.key,
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<BookDetailsBloc>(
          create: (context) => sl<BookDetailsBloc>(),
        ),
        BlocProvider<ReviewsBloc>(
          create: (context) => sl<ReviewsBloc>(),
        ),
        BlocProvider<RentalStatusBloc>(
          create: (context) => sl<RentalStatusBloc>(),
        ),
      ],
      child: BookDetailsPage(book: book),
    );
  }
}