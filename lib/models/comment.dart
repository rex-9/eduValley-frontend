import 'dart:convert';

import 'package:edu_valley/services/api.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Comment {
  final int id, adId, userId;
  final String content;

  Comment({
    required this.id,
    required this.adId,
    required this.userId,
    required this.content,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int,
      adId: json['ad_id'] as int,
      userId: json['user_id'] as int,
      content: json['content'] as String,
    );
  }
}

Future<List<Comment>> fetchComments(http.Client client, int adId) async {
  final response = await client.get(
    Uri.parse('${Network.url}/comments/get/ad/$adId'),
  );

  // Use the compute function to run parseAds in a separate isolate.
  return compute(parseComments, response.body);
}

// A function that converts a response body into a List<Comment>.
List<Comment> parseComments(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Comment>((json) => Comment.fromJson(json)).toList();
}
