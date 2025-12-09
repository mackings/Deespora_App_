// import 'package:dspora/App/View/Auth/Api/AuthService.dart';
// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:http/http.dart' as dio;
// import 'package:shared_preferences/shared_preferences.dart';

// class GoogleAuthService {
//   final GoogleSignIn _googleSignIn = GoogleSignIn(
//     scopes: ['email', 'profile'],
//   );

//   /// Sign in with Google
//   Future<Map<String, dynamic>> signInWithGoogle() async {
//     try {
//       // Trigger the Google Sign-In flow
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

//       if (googleUser == null) {
//         // User canceled the sign-in
//         return {
//           'success': false,
//           'message': 'Sign-in canceled',
//         };
//       }

//       // Obtain the auth details from the request
//       final GoogleSignInAuthentication googleAuth = 
//           await googleUser.authentication;

//       debugPrint('✅ Google Sign-In successful');
//       debugPrint('📧 Email: ${googleUser.email}');
//       debugPrint('👤 Name: ${googleUser.displayName}');

//       // Send to backend
//       final AuthApi authApi = AuthApi();
//       final result = await authApi.googleSignIn(
//         googleId: googleUser.id,
//         email: googleUser.email,
//         displayName: googleUser.displayName ?? '',
//         photoUrl: googleUser.photoUrl ?? '',
//         idToken: googleAuth.idToken ?? '',
//       );

//       if (result['success']) {
//         // Save user data locally
//         await _saveUserData(result['data']);

//         return {
//           'success': true,
//           'message': result['message'],
//           'user': result['data']['user'],
//         };
//       } else {
//         // Sign out if backend authentication fails
//         await _googleSignIn.signOut();
//         return result;
//       }
//     } catch (e) {
//       debugPrint('🔥 Google Sign-In Error: $e');
//       return {
//         'success': false,
//         'message': 'An error occurred: ${e.toString()}',
//       };
//     }
//   }

//   /// Save user data locally
//   Future<void> _saveUserData(Map<String, dynamic> data) async {
//     final prefs = await SharedPreferences.getInstance();
    
//     final user = data['user'];
//     final token = data['token'];
    
//     // Save token
//     if (token != null) {
//       await prefs.setString('token', token);
//     }
    
//     // Save user data
//     if (user != null) {
//       await prefs.setString('userId', user['id'].toString());
//       await prefs.setString('userName', '${user['firstName']} ${user['lastName']}'.trim());
//       await prefs.setString('firstName', user['firstName'] ?? '');
//       await prefs.setString('lastName', user['lastName'] ?? '');
//       await prefs.setString('userEmail', user['email'] ?? '');
//       await prefs.setBool('emailVerified', user['emailVerified'] ?? true);
//       await prefs.setBool('phoneVerified', user['phoneVerified'] ?? false);
      
//       if (user['phoneNumber'] != null) {
//         await prefs.setString('phoneNumber', user['phoneNumber']);
//       }
      
//       if (user['photoUrl'] != null && user['photoUrl'].toString().isNotEmpty) {
//         await prefs.setString('photoUrl', user['photoUrl']);
//       }
//     }
    
//     debugPrint('✅ User data saved locally');
//   }

//   /// Sign out
//   Future<void> signOut() async {
//     await _googleSignIn.signOut();
    
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.clear();
    
//     debugPrint('✅ User signed out');
//   }

//   /// Check if user is signed in
//   Future<bool> isSignedIn() async {
//     return await _googleSignIn.isSignedIn();
//   }

//   /// Get current user
//   Future<GoogleSignInAccount?> getCurrentUser() async {
//     return _googleSignIn.currentUser;
//   }
// }

// // Extension to add Google Sign-In method to your AuthApi class
// extension AuthApiGoogle on AuthApi {
//   Future<Map<String, dynamic>> googleSignIn({
//     required String googleId,
//     required String email,
//     required String displayName,
//     required String photoUrl,
//     required String idToken,
//   }) async {
//     try {
//       final response = await dio.post(
//         '/auth/google-signin',
//         data: {
//           'googleId': googleId,
//           'email': email,
//           'displayName': displayName,
//           'photoUrl': photoUrl,
//           'idToken': idToken,
//         },
//       );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return {
//           'success': true,
//           'message': response.data['message'] ?? 'Sign-in successful',
//           'data': response.data['data'],
//         };
//       }

//       return {
//         'success': false,
//         'message': response.data['message'] ?? 'Authentication failed',
//       };
//     } catch (e) {
//       debugPrint('🔥 API Error: $e');
      
//       // Handle DioException for better error messages
//       if (e.toString().contains('DioException')) {
//         return {
//           'success': false,
//           'message': 'Network error. Please check your connection.',
//         };
//       }
      
//       return {
//         'success': false,
//         'message': 'An error occurred: ${e.toString()}',
//       };
//     }
//   }
// }