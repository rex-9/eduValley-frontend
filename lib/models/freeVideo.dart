import 'dart:convert';

import 'package:edu_valley/services/api.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class FreeVideo {
  final int id, courseId;
  final String url, title;

  FreeVideo({
    required this.id,
    required this.courseId,
    required this.url,
    required this.title,
  });

  factory FreeVideo.fromJson(Map<String, dynamic> json) {
    return FreeVideo(
      id: json['id'] as int,
      courseId: json['course_id'] as int,
      url: json['url'] as String,
      title: json['title'] as String,
    );
  }
}

Future<List<FreeVideo>> fetchFreeVideos(
  http.Client client,
  int courseId,
) async {
  final response = await client.get(
    Uri.parse('${Network.url}/freevideos/get/$courseId'),
  );

  // Use the compute function to run parseFreeVideos in a separate isolate.
  return compute(parseFreeVideos, response.body);
}

// A function that converts a response body into a List<FreeVideo>.
List<FreeVideo> parseFreeVideos(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<FreeVideo>((json) => FreeVideo.fromJson(json)).toList();
}
