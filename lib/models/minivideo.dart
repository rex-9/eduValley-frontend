import 'dart:convert';

import 'package:edu_valley/services/api.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Minivideo {
  final int id, adId;
  final String fileName, thumbName, parent, title;

  Minivideo({
    required this.id,
    required this.adId,
    required this.fileName,
    required this.thumbName,
    required this.parent,
    required this.title,
  });

  String videoPath() {
    return "$parent/$fileName";
  }

  String? thumbPath() {
    return "$parent/$thumbName";
  }

  factory Minivideo.fromJson(Map<String, dynamic> json) {
    return Minivideo(
      id: json['id'] as int,
      adId: json['ad_id'] as int,
      fileName: json['fileName'] as String,
      thumbName: json['thumbName'] as String,
      parent: json['parent'] as String,
      title: json['title'] as String,
    );
  }
}

Future<List<Minivideo>> fetchMinivideos(
  http.Client client,
  int adId,
) async {
  final response = await client.get(
    Uri.parse(
      '${Network.url}/getMinivideos/'
      '$adId',
    ),
  );

  // Use the compute function to run parseMinivideos in a separate isolate.
  return compute(parseMinivideos, response.body);
}

// A function that converts a response body into a List<Minivideo>.
List<Minivideo> parseMinivideos(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Minivideo>((json) => Minivideo.fromJson(json)).toList();
}
