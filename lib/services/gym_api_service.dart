import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class GymApiService {
  Future<List<Map<String, dynamic>>> getGyms(int userId) async {
      final response = await http.post(
        Uri.parse('${Constants.gymListUrl}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'method': 'list', 'user_id': userId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("HTTP response: ${data}");
        if (data['status'] == 'success') {
          return List<Map<String, dynamic>>.from(data['gyms']);
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('Failed to fetch gyms');
      }
    
  }
}
