import 'dart:convert';

import 'package:edu_valley/services/api.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Teacher {
  final int id;
  final String name, photo, url, role;
  const Teacher({
    required this.id,
    required this.name,
    required this.photo,
    required this.url,
    required this.role,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'] as int,
      name: json['name'] as String,
      photo: json['photo'] as String,
      url: json['url'] as String,
      role: json['role'] as String,
    );
  }
}

Future<List<Teacher>> fetchTeachers(http.Client client) async {
  final response = await client.get(
    Uri.parse(
      '${Network.url}/getTeachers',
    ),
  );

  // Use the compute function to run parseTeachers in a separate isolate.
  return compute(parseTeachers, response.body);
}

Future<List<Teacher>> searchTeachers(
  http.Client client,
  String role,
) async {
  final response = await client.get(
    Uri.parse(
      '${Network.url}/searchTeachers/'
      '$role',
    ),
  );

  // Use the compute function to run parseVideos in a separate isolate.
  return compute(parseTeachers, response.body);
}

// A function that converts a response body into a List<Teacher>.
List<Teacher> parseTeachers(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Teacher>((json) => Teacher.fromJson(json)).toList();
}

Future<Teacher> fetchTeacher(int id) async {
  final response =
      await http.get(Uri.parse('${Network.url}/getTeachers/' '$id'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Teacher.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load teacher');
  }
}
