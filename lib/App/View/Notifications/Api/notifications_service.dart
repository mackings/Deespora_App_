import 'package:dio/dio.dart';
import 'package:dspora/App/View/Notifications/Model/notification_model.dart';
import 'package:dspora/Constants/BaseUrl.dart';

class NotificationsService {
  final Dio _dio;

  NotificationsService({Dio? dio}) : _dio = dio ?? Dio();

  Future<NotificationsFeed> fetchNotifications({
    int eventsLimit = 3,
    int placesLimit = 2,
  }) async {
    final response = await _dio.get(
      '${Baseurl.Url}notifications',
      queryParameters: {'eventsLimit': eventsLimit, 'placesLimit': placesLimit},
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return NotificationsFeed.fromJson(response.data as Map<String, dynamic>);
    }

    throw Exception('Failed to fetch notifications');
  }
}
