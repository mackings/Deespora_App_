import 'package:dio/dio.dart';
import 'package:dspora/App/View/Constants/BaseUrl.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';



class AuthApi {


  final Dio _dio = Dio(BaseOptions(
    baseUrl: Baseurl.Url,
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 20),
    headers: {'Content-Type': 'application/json'},
  ));

  /// REGISTER USER
  Future<Map<String, dynamic>> register({
    required String firstname,
    required String lastname,
    required String email,
    required String phone,
    required String password,
  }) async {
    final payload = {
      "firstName": firstname,
      "lastName": lastname,
      "email": email,
      "phoneNumber": phone,
      "password": password,
    };

    debugPrint("➡️ [REGISTER] POST ${Baseurl.Url}register");
    debugPrint("📦 Payload: $payload");

    try {
      final response = await _dio.post('register', data: payload);

      debugPrint("✅ [REGISTER] Status: ${response.statusCode}");
      debugPrint("⬅️ Response: ${response.data}");

      // After successful registration, you may send OTP automatically
      if (response.statusCode == 200 || response.statusCode == 201) {
        await sendOtp(email: email);
      }

      return {"success": true, "data": response.data};
    } on DioException catch (e) {
      debugPrint("❌ [REGISTER] Error: ${e.message}");
      debugPrint("❗️ Response body: ${e.response?.data}");

      return {
        "success": false,
        "message": e.response?.data['message'] ?? e.message,
      };
    } catch (e) {
      debugPrint("🔥 [REGISTER] Unexpected error: $e");
      return {"success": false, "message": e.toString()};
    }
  }

  /// SEND OTP
  Future<Map<String, dynamic>> sendOtp({required String email}) async {
    final payload = {"email": email};
    debugPrint("➡️ [SEND OTP] POST ${Baseurl.Url}send-otp");
    debugPrint("📦 Payload: $payload");

    try {
      final response = await _dio.post('send-otp', data: payload);

      debugPrint("✅ [SEND OTP] Status: ${response.statusCode}");
      debugPrint("⬅️ Response: ${response.data}");

      return {"success": true, "data": response.data};
    } on DioException catch (e) {
      debugPrint("❌ [SEND OTP] Error: ${e.message}");
      debugPrint("❗️ Response body: ${e.response?.data}");

      return {
        "success": false,
        "message": e.response?.data['message'] ?? e.message,
      };
    } catch (e) {
      debugPrint("🔥 [SEND OTP] Unexpected error: $e");
      return {"success": false, "message": e.toString()};
    }
  }

  /// VERIFY OTP
  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String code,
  }) async {
    final payload = {"email": email, "code": code};
    debugPrint("➡️ [VERIFY OTP] POST ${Baseurl.Url}verify-otp");
    debugPrint("📦 Payload: $payload");

    try {
      final response = await _dio.post('verify-otp', data: payload);

      debugPrint("✅ [VERIFY OTP] Status: ${response.statusCode}");
      debugPrint("⬅️ Response: ${response.data}");

      return {"success": true, "data": response.data};
    } on DioException catch (e) {
      debugPrint("❌ [VERIFY OTP] Error: ${e.message}");
      debugPrint("❗️ Response body: ${e.response?.data}");

      return {
        "success": false,
        "message": e.response?.data['message'] ?? e.message,
      };
    } catch (e) {
      debugPrint("🔥 [VERIFY OTP] Unexpected error: $e");
      return {"success": false, "message": e.toString()};
    }
  }



    /// LOGIN USER
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final payload = {
      "email": email,
      "password": password,
    };

    debugPrint("➡️ [LOGIN] POST ${Baseurl.Url}login");
    debugPrint("📦 Payload: $payload");

    try {
      final response = await _dio.post('login', data: payload);

      debugPrint("✅ [LOGIN] Status: ${response.statusCode}");
      debugPrint("⬅️ Response: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'];
        final token = data['token'];
        final user = data['user'];

        // ✅ Save token & user to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('userId', user['id']);
        await prefs.setString('userEmail', user['email']);
        await prefs.setBool('emailVerified', user['emailVerified'] ?? false);
        await prefs.setBool('phoneVerified', user['phoneVerified'] ?? false);

        return {
          "success": true,
          "message": response.data['message'],
          "data": data,
        };
      }

      return {
        "success": false,
        "message": response.data['message'] ?? 'Login failed',
      };
    } on DioException catch (e) {
      debugPrint("❌ [LOGIN] Error: ${e.message}");
      debugPrint("❗️ Response body: ${e.response?.data}");

      return {
        "success": false,
        "message": e.response?.data['message'] ?? e.message,
      };
    } catch (e) {
      debugPrint("🔥 [LOGIN] Unexpected error: $e");
      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }

}
