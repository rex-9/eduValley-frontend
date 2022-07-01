import 'dart:convert';

import 'package:edu_valley/services/api.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Course {
  final int id, teacherId;
  int price, students, ongoing;
  final String name, grade, subject, image, token, genre;
  String? zip;

  Course({
    required this.id,
    required this.teacherId,
    required this.name,
    required this.grade,
    required this.subject,
    required this.image,
    required this.token,
    this.zip,
    required this.price,
    required this.students,
    required this.genre,
    required this.ongoing,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as int,
      teacherId: json['teacher_id'] as int,
      name: json['name'] as String,
      grade: json['grade'] as String,
      subject: json['subject'] as String,
      image: json['image'] as String,
      token: json['token'] as String,
      zip: json['zip'] as String?,
      price: json['price'] as int,
      students: json['students'] as int,
      genre: json['genre'] as String,
      ongoing: json['ongoing'] as int,
    );
  }
}

Future<List<Course>> fetchCourses(http.Client client) async {
  final response = await client.get(
    Uri.parse('${Network.url}/courses/get/'),
  );

  // Use the compute function to run parseCourses in a separate isolate.
  return compute(parseCourses, response.body);
}

Future<List<Course>> searchCourses(
  http.Client client,
  String search,
) async {
  final response = await client.get(
    Uri.parse('${Network.url}/courses/get/$search'),
  );

  // Use the compute function to run parseVideos in a separate isolate.
  return compute(parseCourses, response.body);
}

// A function that converts a response body into a List<Course>.
List<Course> parseCourses(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Course>((json) => Course.fromJson(json)).toList();
}
