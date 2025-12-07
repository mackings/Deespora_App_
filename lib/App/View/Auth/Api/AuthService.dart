import 'package:dio/dio.dart';
import 'package:dspora/Constants/BaseUrl.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthApi {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Baseurl.Url,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // ---------------- REGISTER ----------------

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

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Automatically send email OTP after successful registration
        try {
          await sendOtp(email: email);
        } catch (otpError) {
          debugPrint("⚠️ [REGISTER] Failed to send OTP: $otpError");
          // Continue even if OTP fails - user registered successfully
        }

        return {
          "success": true,
          "message": response.data['message'] ?? "Registration successful",
          "data": response.data['data'],
        };
      }

      return {
        "success": false,
        "message": response.data['message'] ?? 'Registration failed',
      };
    } on DioException catch (e) {
      debugPrint("❌ [REGISTER] Error: ${e.message}");
      
      return {
        "success": false,
        "message": _extractErrorMessage(e),
      };
    } catch (e) {
      debugPrint("🔥 [REGISTER] Unexpected error: $e");
      return {
        "success": false,
        "message": "An unexpected error occurred. Please try again.",
      };
    }
  }

  // ---------------- SEND OTP (Email) ----------------

  Future<Map<String, dynamic>> sendOtp({required String email}) async {
    final payload = {"email": email};
    debugPrint("➡️ [SEND OTP] POST ${Baseurl.Url}auth/send-otp");

    try {
      final response = await _dio.post('auth/send-otp', data: payload);
      debugPrint("✅ [SEND OTP] Status: ${response.statusCode}");
      
      return {
        "success": true,
        "message": response.data['message'] ?? "Verification code sent",
        "data": response.data['data'],
      };
    } on DioException catch (e) {
      debugPrint("❌ [SEND OTP] Error: ${e.message}");
      
      return {
        "success": false,
        "message": _extractErrorMessage(e),
      };
    } catch (e) {
      debugPrint("🔥 [SEND OTP] Unexpected error: $e");
      return {
        "success": false,
        "message": "Failed to send verification code. Please try again.",
      };
    }
  }

  // ---------------- VERIFY OTP (Email) ----------------

  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String code,
  }) async {
    final payload = {"email": email, "code": code};
    debugPrint("➡️ [VERIFY OTP] POST ${Baseurl.Url}auth/verify-otp");

    try {
      final response = await _dio.post('auth/verify-otp', data: payload);
      debugPrint("✅ [VERIFY OTP] Status: ${response.statusCode}");
      
      return {
        "success": true,
        "message": response.data['message'] ?? "Email verified successfully",
        "data": response.data['data'],
      };
    } on DioException catch (e) {
      debugPrint("❌ [VERIFY OTP] Error: ${e.message}");
      
      return {
        "success": false,
        "message": _extractErrorMessage(e),
      };
    } catch (e) {
      debugPrint("🔥 [VERIFY OTP] Unexpected error: $e");
      return {
        "success": false,
        "message": "Verification failed. Please try again.",
      };
    }
  }

  // ---------------- SEND PHONE OTP ----------------

  Future<Map<String, dynamic>> sendPhoneOtp({required String phoneNumber}) async {
    final payload = {"phoneNumber": phoneNumber};
    debugPrint("➡️ [SEND PHONE OTP] POST ${Baseurl.Url}auth/send-phone-otp");

    try {
      final response = await _dio.post('auth/send-phone-otp', data: payload);
      debugPrint("✅ [SEND PHONE OTP] Status: ${response.statusCode}");
      
      return {
        "success": true,
        "message": response.data['message'] ?? "Verification code sent to phone",
        "data": response.data['data'],
      };
    } on DioException catch (e) {
      debugPrint("❌ [SEND PHONE OTP] Error: ${e.message}");
      
      return {
        "success": false,
        "message": _extractErrorMessage(e),
      };
    } catch (e) {
      debugPrint("🔥 [SEND PHONE OTP] Unexpected error: $e");
      return {
        "success": false,
        "message": "Failed to send verification code. Please try again.",
      };
    }
  }

  // ---------------- VERIFY PHONE OTP ----------------

  Future<Map<String, dynamic>> verifyPhoneOtp({
    required String phoneNumber,
    required String code,
  }) async {
    final payload = {"phoneNumber": phoneNumber, "code": code};
    debugPrint("➡️ [VERIFY PHONE OTP] POST ${Baseurl.Url}auth/verify-phone-otp");

    try {
      final response = await _dio.post('auth/verify-phone-otp', data: payload);
      debugPrint("✅ [VERIFY PHONE OTP] Status: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Save user data and token from phone verification
        final data = response.data['data'];
        if (data != null && data['token'] != null) {
          await _saveUserSession(data);
        }

        return {
          "success": true,
          "message": response.data['message'] ?? "Phone verified successfully",
          "data": data,
        };
      }

      return {
        "success": false,
        "message": response.data['message'] ?? 'Verification failed',
      };
    } on DioException catch (e) {
      debugPrint("❌ [VERIFY PHONE OTP] Error: ${e.message}");
      
      return {
        "success": false,
        "message": _extractErrorMessage(e),
      };
    } catch (e) {
      debugPrint("🔥 [VERIFY PHONE OTP] Unexpected error: $e");
      return {
        "success": false,
        "message": "Verification failed. Please try again.",
      };
    }
  }

  // ---------------- LOGIN ----------------

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final payload = {"email": email, "password": password};
    debugPrint("➡️ [LOGIN] POST ${Baseurl.Url}login");

    const int maxRetries = 3;
    const Duration initialDelay = Duration(seconds: 2);
    int attempt = 0;

    while (true) {
      try {
        final response = await _dio.post('login', data: payload);
        debugPrint("✅ [LOGIN] Status: ${response.statusCode}");

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = response.data['data'];
          
          if (data != null && data['token'] != null) {
            await _saveUserSession(data);
          }

          return {
            "success": true,
            "message": response.data['message'] ?? "Login successful",
            "data": data,
          };
        }

        return {
          "success": false,
          "message": response.data['message'] ?? 'Login failed',
        };
      } on DioException catch (e) {
        attempt++;
        final statusCode = e.response?.statusCode;

        debugPrint(
          "❌ [LOGIN] Attempt $attempt failed: ${e.message} (Status: $statusCode)",
        );

        // If it's a client error (4xx) or we've hit max retries, stop retrying
        if ((statusCode != null && statusCode >= 400 && statusCode < 500) ||
            attempt >= maxRetries) {
          return {
            "success": false,
            "message": _extractErrorMessage(e),
          };
        }

        // Exponential backoff delay for server errors (5xx) or network issues
        final delay = initialDelay * attempt;
        debugPrint("🔁 Retrying in ${delay.inSeconds}s...");
        await Future.delayed(delay);
      } catch (e) {
        debugPrint("🔥 [LOGIN] Unexpected error: $e");
        return {
          "success": false,
          "message": "An unexpected error occurred. Please try again.",
        };
      }
    }
  }

  // ---------------- REQUEST PASSWORD RESET ----------------

  Future<Map<String, dynamic>> requestPasswordReset({
    required String email,
  }) async {
    final payload = {"email": email};
    debugPrint(
      "➡️ [REQUEST PASSWORD RESET] POST ${Baseurl.Url}request-password-reset",
    );

    try {
      final response = await _dio.post('request-password-reset', data: payload);
      debugPrint("✅ [REQUEST PASSWORD RESET] Status: ${response.statusCode}");

      return {
        "success": true,
        "message": response.data['message'] ?? "Reset code sent to your email",
      };
    } on DioException catch (e) {
      debugPrint("❌ [REQUEST PASSWORD RESET] Error: ${e.message}");
      
      return {
        "success": false,
        "message": _extractErrorMessage(e),
      };
    } catch (e) {
      debugPrint("🔥 [REQUEST PASSWORD RESET] Unexpected error: $e");
      return {
        "success": false,
        "message": "Failed to send reset code. Please try again.",
      };
    }
  }

  // ---------------- RESET PASSWORD ----------------

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    final payload = {
      "email": email,
      "token": token,
      "password": newPassword,
    };

    debugPrint("➡️ [RESET PASSWORD] POST ${Baseurl.Url}reset-password");

    try {
      final response = await _dio.post('reset-password', data: payload);
      debugPrint("✅ [RESET PASSWORD] Status: ${response.statusCode}");

      return {
        "success": true,
        "message": response.data['message'] ?? "Password reset successful",
      };
    } on DioException catch (e) {
      debugPrint("❌ [RESET PASSWORD] Error: ${e.message}");
      
      return {
        "success": false,
        "message": _extractErrorMessage(e),
      };
    } catch (e) {
      debugPrint("🔥 [RESET PASSWORD] Unexpected error: $e");
      return {
        "success": false,
        "message": "Password reset failed. Please try again.",
      };
    }
  }

  // ---------------- LOGOUT ----------------

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      debugPrint("✅ [LOGOUT] User session cleared");
    } catch (e) {
      debugPrint("❌ [LOGOUT] Error: $e");
    }
  }

  // ---------------- HELPER METHODS ----------------

  /// Save user session data to SharedPreferences
  Future<void> _saveUserSession(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final user = data['user'];

      if (data['token'] != null) {
        await prefs.setString('token', data['token']);
      }

      if (user != null) {
        if (user['id'] != null) {
          await prefs.setString('userId', user['id'].toString());
        }
        
        if (user['firstName'] != null) {
          await prefs.setString('userName', user['firstName']);
        } else if (user['username'] != null) {
          await prefs.setString('userName', user['username']);
        }
        
        if (user['email'] != null) {
          await prefs.setString('userEmail', user['email']);
        }
        
        if (user['phoneNumber'] != null) {
          await prefs.setString('userPhone', user['phoneNumber']);
        }
        
        if (user['role'] != null) {
          await prefs.setString('userRole', user['role']);
        }

        await prefs.setBool(
          'emailVerified',
          user['emailVerified'] ?? false,
        );
        
        await prefs.setBool(
          'phoneVerified',
          user['phoneVerified'] ?? false,
        );
      }

      debugPrint("✅ User session saved successfully");
    } catch (e) {
      debugPrint("❌ Error saving user session: $e");
    }
  }

  /// Extract meaningful error message from DioException
  String _extractErrorMessage(DioException e) {
    try {
      // Try to get message from response data
      if (e.response?.data != null) {
        final data = e.response!.data;
        
        // Handle different response formats
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

      // Fallback to status code messages
      switch (e.response?.statusCode) {
        case 400:
          return 'Invalid request. Please check your input.';
        case 401:
          return 'Invalid credentials. Please try again.';
        case 403:
          return 'Access denied. Your account may be deactivated.';
        case 404:
          return 'Service not found. Please try again later.';
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

  /// Get current user session
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) return null;

      return {
        'token': token,
        'userId': prefs.getString('userId'),
        'userName': prefs.getString('userName'),
        'userEmail': prefs.getString('userEmail'),
        'userPhone': prefs.getString('userPhone'),
        'userRole': prefs.getString('userRole'),
        'emailVerified': prefs.getBool('emailVerified') ?? false,
        'phoneVerified': prefs.getBool('phoneVerified') ?? false,
      };
    } catch (e) {
      debugPrint("❌ Error getting current user: $e");
      return null;
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token') != null;
    } catch (e) {
      return false;
    }
  }
}