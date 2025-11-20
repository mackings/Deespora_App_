import 'package:dio/dio.dart';
import 'package:dspora/App/View/Events/Model/AdsModel.dart';
import 'package:flutter/material.dart';

class AdvertApiService {
  final Dio _dio;
  AdvertApiService({Dio? dio}) : _dio = dio ?? Dio();

  static const String _baseUrl = "https://deesporabackend.vercel.app";

  /// ✅ Fetch all listings/adverts with retries
  Future<List<Advert>> fetchAllAdverts({
    int page = 1,
    int limit = 10,
  }) async {
    const int maxRetries = 3;
    const Duration retryDelay = Duration(seconds: 2);

    int attempt = 0;
    DioError? lastError;

    while (attempt < maxRetries) {
      attempt++;
      try {
        debugPrint('🔄 Fetch adverts attempt $attempt...');

        final response = await _dio.get(
          "$_baseUrl/listings",
          queryParameters: {
            'page': page,
            'limit': limit,
          },
        );

        if (response.statusCode == 200) {
          final data = response.data['data']['listings'] as List<dynamic>;
          debugPrint('✅ Adverts fetched successfully on attempt $attempt');
          return data.map((e) => Advert.fromJson(e)).toList();
        } else {
          throw DioError(
            requestOptions: response.requestOptions,
            response: response,
            error: 'Status code: ${response.statusCode}',
            type: DioErrorType.badResponse,
          );
        }
      } on DioError catch (e) {
        lastError = e;
        debugPrint('⚠️ Fetch adverts failed (attempt $attempt): ${e.message}');

        if (attempt < maxRetries &&
            (e.response?.statusCode != null &&
                e.response!.statusCode! >= 500 ||
                e.type == DioErrorType.connectionTimeout ||
                e.type == DioErrorType.receiveTimeout ||
                e.type == DioErrorType.badResponse)) {
          debugPrint('⏳ Retrying in ${retryDelay.inSeconds}s...');
          await Future.delayed(retryDelay);
          continue;
        } else {
          break;
        }
      } catch (e) {
        debugPrint('❌ Unexpected error fetching adverts: $e');
        rethrow;
      }
    }

    throw Exception(
        'Failed to fetch adverts after $maxRetries attempts: ${lastError?.message}');
  }

  /// 🔥 Fetch only promoted adverts
  Future<List<Advert>> fetchPromotedAdverts() async {
    try {
      final allAdverts = await fetchAllAdverts(limit: 50);
      return allAdverts.where((advert) => advert.promoted).toList();
    } catch (e) {
      debugPrint('❌ Error fetching promoted adverts: $e');
      rethrow;
    }
  }

  /// 📍 Fetch adverts by location
  Future<List<Advert>> fetchAdvertsByLocation(String location) async {
    try {
      final allAdverts = await fetchAllAdverts(limit: 50);
      return allAdverts
          .where((advert) =>
              advert.location.toLowerCase().contains(location.toLowerCase()))
          .toList();
    } catch (e) {
      debugPrint('❌ Error fetching adverts by location: $e');
      rethrow;
    }
  }

  /// 📄 Fetch single advert by ID
  Future<Advert?> fetchAdvertById(String id) async {
    try {
      final allAdverts = await fetchAllAdverts(limit: 100);
      return allAdverts.firstWhere(
        (advert) => advert.id == id,
        orElse: () => throw Exception('Advert not found'),
      );
    } catch (e) {
      debugPrint('❌ Error fetching advert by ID: $e');
      return null;
    }
  }
}