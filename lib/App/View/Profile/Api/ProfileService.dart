import 'package:dio/dio.dart';
import 'package:dspora/Constants/BaseUrl.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileApi {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Baseurl.Url,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Content-Type': 'application/json'},
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
          debugPrint("➡️ API REQUEST");
          debugPrint("URL: ${options.baseUrl}${options.path}");
          debugPrint("METHOD: ${options.method}");
          debugPrint("HEADERS: ${options.headers}");
          debugPrint("BODY: ${options.data}");
          debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
          debugPrint("✅ API RESPONSE");
          debugPrint("URL: ${response.realUri}");
          debugPrint("STATUS: ${response.statusCode}");
          debugPrint("DATA: ${response.data}");
          debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
          handler.next(response);
        },
        onError: (DioException e, handler) {
          debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
          debugPrint("❌ API ERROR");
          debugPrint("URL: ${e.requestOptions.uri}");
          debugPrint("METHOD: ${e.requestOptions.method}");
          debugPrint("STATUS CODE: ${e.response?.statusCode}");
          debugPrint("STATUS MESSAGE: ${e.response?.statusMessage}");
          debugPrint("ERROR TYPE: ${e.type}");

          if (e.response?.data != null) {
            debugPrint("🔴 SERVER RESPONSE BODY: ${e.response?.data}");
          } else {
            debugPrint("🔴 SERVER RESPONSE BODY: No response data available");
          }

          debugPrint("ERROR MESSAGE: ${e.message}");
          debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
          handler.next(e);
        },
      ),
    );

  // ==============================
  // GET PROFILE
  // ==============================

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final userId = await _getUserId();
      if (userId == null) {
        return {
          "success": false,
          "message": "User ID not found. Please login again.",
        };
      }

      final token = await _getToken();
      if (token == null) {
        return {
          "success": false,
          "message": "Authentication required. Please login again.",
        };
      }

      final response = await _dio.get(
        'profile/$userId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": response.data['message'] ?? "Profile retrieved successfully",
          "data": {
            "user": response.data['data'],
          },
        };
      }

      return {
        "success": false,
        "message": response.data['message'] ?? 'Failed to retrieve profile',
      };
    } on DioException catch (e) {
      return {
        "success": false,
        "message": _extractErrorMessage(e),
      };
    } catch (e) {
      debugPrint("🔥 [GET PROFILE] Unexpected error: $e");
      return {
        "success": false,
        "message": "An unexpected error occurred. Please try again.",
      };
    }
  }

  // ==============================
  // UPDATE PROFILE
  // ==============================

  Future<Map<String, dynamic>> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
  }) async {
    final payload = <String, dynamic>{};

    if (firstName != null && firstName.isNotEmpty) {
      payload['firstName'] = firstName;
    }
    if (lastName != null && lastName.isNotEmpty) {
      payload['lastName'] = lastName;
    }
    if (email != null && email.isNotEmpty) {
      payload['email'] = email;
    }
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      payload['phoneNumber'] = phoneNumber;
    }

    if (payload.isEmpty) {
      return {
        "success": false,
        "message": "At least one field is required to update",
      };
    }

    try {
      final userId = await _getUserId();
      if (userId == null) {
        return {
          "success": false,
          "message": "User ID not found. Please login again.",
        };
      }

      final token = await _getToken();
      if (token == null) {
        return {
          "success": false,
          "message": "Authentication required. Please login again.",
        };
      }

      final response = await _dio.patch(
        'profile/$userId',
        data: payload,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];

        if (data != null) {
          await _updateUserSession(data);
        }

        return {
          "success": true,
          "message": response.data['message'] ?? "Profile updated successfully",
          "data": {"user": data},
        };
      }

      return {
        "success": false,
        "message": response.data['message'] ?? 'Profile update failed',
      };
    } on DioException catch (e) {
      return {
        "success": false,
        "message": _extractErrorMessage(e),
      };
    } catch (e) {
      debugPrint("🔥 [UPDATE PROFILE] Unexpected error: $e");
      return {
        "success": false,
        "message": "An unexpected error occurred. Please try again.",
      };
    }
  }

  // ==============================
  // DELETE ACCOUNT
  // ==============================

  Future<Map<String, dynamic>> deleteAccount({
    required String password,
  }) async {
    final payload = {"password": password};

    try {
      final userId = await _getUserId();
      if (userId == null) {
        return {
          "success": false,
          "message": "User ID not found. Please login again.",
        };
      }

      final token = await _getToken();
      if (token == null) {
        return {
          "success": false,
          "message": "Authentication required. Please login again.",
        };
      }

      final response = await _dio.delete(
        'account/$userId',
        data: payload,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        await _clearUserSession();

        return {
          "success": true,
          "message": response.data['message'] ?? "Account deleted successfully",
          "data": response.data['data'],
        };
      }

      return {
        "success": false,
        "message": response.data['message'] ?? 'Account deletion failed',
      };
    } on DioException catch (e) {
      return {
        "success": false,
        "message": _extractErrorMessage(e),
      };
    } catch (e) {
      debugPrint("🔥 [DELETE ACCOUNT] Unexpected error: $e");
      return {
        "success": false,
        "message": "An unexpected error occurred. Please try again.",
      };
    }
  }

  // ==============================
  // HELPER METHODS
  // ==============================

  Future<String?> _getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('userId');
    } catch (e) {
      debugPrint("❌ Error getting user ID: $e");
      return null;
    }
  }

  Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (e) {
      debugPrint("❌ Error getting token: $e");
      return null;
    }
  }

  Future<void> _updateUserSession(Map<String, dynamic> user) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (user['id'] != null) {
        await prefs.setString('userId', user['id'].toString());
      }

      if (user['firstName'] != null) {
        await prefs.setString('userName', user['firstName']);
      }

      if (user['lastName'] != null) {
        await prefs.setString('userLastName', user['lastName']);
      }

      if (user['email'] != null) {
        await prefs.setString('userEmail', user['email']);
      }

      if (user['phoneNumber'] != null) {
        await prefs.setString('userPhone', user['phoneNumber']);
      }

      await prefs.setBool('emailVerified', user['emailVerified'] ?? false);
      await prefs.setBool('phoneVerified', user['phoneVerified'] ?? false);

      debugPrint("✅ User session updated successfully");
    } catch (e) {
      debugPrint("❌ Error updating user session: $e");
    }
  }

  Future<void> _clearUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      debugPrint("✅ User session cleared successfully");
    } catch (e) {
      debugPrint("❌ Error clearing user session: $e");
    }
  }

  String _extractErrorMessage(DioException e) {
    try {
      if (e.response?.data != null) {
        final data = e.response!.data;

        if (data is Map) {
          if (data['message'] != null) {
            return data['message'].toString();
          }
          if (data['error'] != null) {
            return data['error'].toString();
          }
        }

        if (data is String) {
          return data;
        }
      }

      switch (e.response?.statusCode) {
        case 400:
          return 'Invalid request. Please check your input.';
        case 401:
          return 'Invalid credentials. Please try again.';
        case 403:
          return 'Access denied. Your account may be deactivated.';
        case 404:
          return 'User not found. Please login again.';
        case 409:
          return 'This information is already in use.';
        case 500:
          return 'Server error. Please try again later.';
        default:
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout) {
            return 'Connection timeout. Please check your internet.';
          }
          if (e.type == DioExceptionType.connectionError) {
            return 'No internet connection. Please check your network.';
          }
          return e.message ?? 'An error occurred. Please try again.';
      }
    } catch (error) {
      debugPrint("Error extracting message: $error");
      return 'An error occurred. Please try again.';
    }
  }
}
