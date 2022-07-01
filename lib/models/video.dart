import 'dart:convert';

import 'package:edu_valley/services/api.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Video {
  final int id, courseId;
  final String title, fileName, parent;
  final String? thumbName;

  Video({
    required this.id,
    required this.courseId,
    required this.title,
    required this.fileName,
    this.thumbName,
    required this.parent,
  });

  String videoPath() {
    return "$parent/$fileName";
  }

  String? thumbPath() {
    return "$parent/$thumbName";
  }

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] as int,
      courseId: json['course_id'] as int,
      title: json['title'] as String,
      fileName: json['fileName'] as String,
      thumbName: json['thumbName'] as String,
      parent: json['parent'] as String,
    );
  }
}

Future<List<Video>> fetchVideos(
  http.Client client,
  int courseId,
) async {
  final response = await client.get(
    Uri.parse('${Network.url}/videos/get/$courseId'),
  );

  // Use the compute function to run parseVideos in a separate isolate.
  return compute(parseVideos, response.body);
}

// A function that converts a response body into a List<Video>.
List<Video> parseVideos(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Video>((json) => Video.fromJson(json)).toList();
}
