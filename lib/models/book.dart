import 'dart:convert';

import 'package:edu_valley/services/api.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Book {
  final int id, teacherId;
  final String url;

  Book({
    required this.id,
    required this.teacherId,
    required this.url,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as int,
      teacherId: json['teacher_id'] as int,
      url: json['url'] as String,
    );
  }
}

Future<List<Book>> fetchBooks(http.Client client, int teacherId) async {
  final response = await client.get(
    Uri.parse(
      '${Network.url}/getBooks/'
      '$teacherId',
    ),
  );

  // Use the compute function to run parseBooks in a separate isolate.
  return compute(parseBooks, response.body);
}

// A function that converts a response body into a List<Book>.
List<Book> parseBooks(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Book>((json) => Book.fromJson(json)).toList();
}
