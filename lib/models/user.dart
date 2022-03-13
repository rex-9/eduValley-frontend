import 'dart:convert';

import 'package:edu_valley/services/api.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class User {
  final int id;
  final String name, phone, email, role;

  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String,
    );
  }
}

Future<List<User>> fetchCommentOwner(
  http.Client client,
  int userId,
) async {
  final response = await client.get(
    Uri.parse('${Network.url}/users/search/$userId'),
  );

  // Use the compute function to run parseAudios in a separate isolate.
  return compute(parseAudios, response.body);
}

// A function that converts a response body into a List<Audio>.
List<User> parseAudios(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<User>((json) => User.fromJson(json)).toList();
}
