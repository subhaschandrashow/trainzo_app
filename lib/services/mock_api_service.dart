import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class MockApiService {
  Future<Map<String, dynamic>?> loginUser(String input, String password) async {
    final data = await rootBundle.loadString('assets/demo_data/users.json');
    final users = json.decode(data)['users'] as List;

    for (var user in users) {
      if ((user['email'] == input || user['phone'] == input) &&
          user['password'] == password) {
        return user;
      }
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getGymsForUser(int userId) async {
    // simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // dummy gyms data
    List<Map<String, dynamic>> gyms = [
      {'id': 1, 'user_id': 1, 'name': 'Domjur Gym', 'location': 'Domjur, WB'},
      {'id': 2, 'user_id': 1, 'name': 'Salt Lake Gym', 'location': 'Salt Lake, WB'},
      {'id': 3, 'user_id': 2, 'name': 'Kolkata Gym', 'location': 'Kolkata, WB'},
    ];

    // return gyms linked to the user
    return gyms.where((gym) => gym['user_id'] == userId).toList();
  }
}
