import 'package:dio/dio.dart';
import 'package:flutter_library/features/feedback/data/models/feedback_model.dart';
import 'package:flutter_library/features/feedback/domain/entities/feedback.dart';

/// Remote data source for feedback operations
abstract class FeedbackRemoteDataSource {
  /// Submit feedback to the server
  Future<FeedbackModel> submitFeedback({
    required FeedbackType type,
    required String message,
  });

  /// Get user's feedback history
  Future<List<FeedbackModel>> getFeedbackHistory();
}

/// Implementation of remote data source for feedback
class FeedbackRemoteDataSourceImpl implements FeedbackRemoteDataSource {
  final Dio dio;

  FeedbackRemoteDataSourceImpl({required this.dio});

  @override
  Future<FeedbackModel> submitFeedback({
    required FeedbackType type,
    required String message,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Simulate successful submission
    return FeedbackModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      message: message,
      createdAt: DateTime.now(),
      status: FeedbackStatus.pending,
    );

    // In a real implementation, replace the mock above with:
    /*
    final response = await dio.post('/feedback', data: {
      'type': type.toString().split('.').last,
      'message': message,
    });
    return FeedbackModel.fromJson(response.data as Map<String, dynamic>);
    */
  }

  @override
  Future<List<FeedbackModel>> getFeedbackHistory() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Return mock feedback history for testing
    final now = DateTime.now();
    return [
      FeedbackModel(
        id: '1',
        type: FeedbackType.bugReport,
        message: 'App crashes when uploading large files',
        createdAt: now.subtract(const Duration(days: 3)),
        status: FeedbackStatus.resolved,
      ),
      FeedbackModel(
        id: '2',
        type: FeedbackType.featureRequest,
        message: 'Please add dark mode support',
        createdAt: now.subtract(const Duration(days: 7)),
        status: FeedbackStatus.pending,
      ),
      FeedbackModel(
        id: '3',
        type: FeedbackType.general,
        message: 'Great app! Love the book search feature',
        createdAt: now.subtract(const Duration(days: 10)),
        status: FeedbackStatus.inReview,
      ),
    ];

    // In a real implementation, replace the mock above with:
    /*
    final response = await dio.get('/feedback/history');
    final List<dynamic> jsonList = response.data as List<dynamic>;
    return jsonList.map((json) => FeedbackModel.fromJson(json as Map<String, dynamic>)).toList();
    */
  }
}
