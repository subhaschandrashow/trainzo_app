import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ApiService {
  Future<Map<String, dynamic>?> loginUser(String emailOrPhone, String password) async {
    try {
      final response = await http.post(
        Uri.parse(Constants.loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email_or_phone': emailOrPhone,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          return data; // return full data (token + user)
        } else {
          print("Login failed: ${data['message']}");
        }
      } else {
        print("HTTP error: ${response.statusCode}");
      }
    } catch (e) {
      print("Login exception: $e");
    }

    return null;
  }

}
