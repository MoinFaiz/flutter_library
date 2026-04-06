import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_library/features/feedback/data/datasources/feedback_remote_data_source.dart';
import 'package:flutter_library/features/feedback/data/repositories/feedback_repository_impl.dart';
import 'package:flutter_library/features/feedback/domain/usecases/get_feedback_history_usecase.dart';
import 'package:flutter_library/features/feedback/domain/usecases/submit_feedback_usecase.dart';
import 'package:flutter_library/features/feedback/presentation/bloc/feedback_bloc.dart';
import 'package:flutter_library/features/feedback/presentation/pages/feedback_page.dart';
import 'package:flutter_library/injection/injection_container.dart' as di;

/// Provider for the feedback page with BLoC
class FeedbackPageProvider extends StatelessWidget {
  const FeedbackPageProvider({super.key});

  @override
  Widget build(BuildContext context) {
    final remoteDataSource = FeedbackRemoteDataSourceImpl(dio: di.sl<Dio>());
    final repository = FeedbackRepositoryImpl(
      remoteDataSource: remoteDataSource,
      networkInfo: di.sl(),
    );
    return BlocProvider(
      create: (context) => FeedbackBloc(
        submitFeedbackUseCase: SubmitFeedbackUseCase(repository: repository),
        getFeedbackHistoryUseCase: GetFeedbackHistoryUseCase(repository: repository),
      ),
      child: const FeedbackPage(),
    );
  }
}
