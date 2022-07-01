import 'dart:convert';

import 'package:edu_valley/services/api.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Audio {
  final int id, courseId;
  final String url, title;

  Audio({
    required this.id,
    required this.courseId,
    required this.url,
    required this.title,
  });

  factory Audio.fromJson(Map<String, dynamic> json) {
    return Audio(
      id: json['id'] as int,
      courseId: json['course_id'] as int,
      url: json['url'] as String,
      title: json['title'] as String,
    );
  }
}

Future<List<Audio>> fetchAudios(
  http.Client client,
  int courseId,
) async {
  final response = await client.get(
    Uri.parse('${Network.url}/audio/get/$courseId'),
  );

  // Use the compute function to run parseAudios in a separate isolate.
  return compute(parseAudios, response.body);
}

// A function that converts a response body into a List<Audio>.
List<Audio> parseAudios(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Audio>((json) => Audio.fromJson(json)).toList();
}
