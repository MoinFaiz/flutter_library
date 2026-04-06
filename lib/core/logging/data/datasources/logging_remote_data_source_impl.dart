import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/audit_event_model.dart';
import '../models/log_config_model.dart';
import '../models/log_entry_model.dart';
import 'logging_remote_data_source.dart';

class LoggingRemoteDataSourceImpl implements LoggingRemoteDataSource {
  final Dio dio;

  LoggingRemoteDataSourceImpl({required this.dio});

  @override
  Future<LogConfigModel> fetchConfig() async {
    try {
      final response = await dio.get('/logging/config');
      return LogConfigModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException('Failed to fetch logging config: ${e.message}');
    }
  }

  @override
  Future<void> sendLogs(List<LogEntryModel> entries) async {
    try {
      await dio.post('/logging/logs', data: {
        'logs': entries.map((e) => e.toJson()).toList(),
      });
    } on DioException catch (e) {
      throw ServerException('Failed to send logs: ${e.message}');
    }
  }

  @override
  Future<void> sendAuditEvents(List<AuditEventModel> events) async {
    try {
      await dio.post('/logging/audit', data: {
        'events': events.map((e) => e.toJson()).toList(),
      });
    } on DioException catch (e) {
      throw ServerException('Failed to send audit events: ${e.message}');
    }
  }
}
