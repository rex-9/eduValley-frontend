import 'dart:convert';

import 'package:edu_valley/services/api.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Poster {
  final int id, adId;
  final String url;

  Poster({
    required this.id,
    required this.adId,
    required this.url,
  });

  factory Poster.fromJson(Map<String, dynamic> json) {
    return Poster(
      id: json['id'] as int,
      adId: json['ad_id'] as int,
      url: json['url'] as String,
    );
  }
}

Future<Poster> fetchFirstPoster(int adId) async {
  final response =
      await http.get(Uri.parse('${Network.url}/getPosters/first/' '$adId'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Poster.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load poster');
  }
}

Future<List<Poster>> fetchPosters(
  http.Client client,
  int adId,
) async {
  final response = await client.get(
    Uri.parse(
      '${Network.url}/getPosters/'
      '$adId',
    ),
  );

  // Use the compute function to run parsePosters in a separate isolate.
  return compute(parsePosters, response.body);
}

// A function that converts a response body into a List<Poster>.
List<Poster> parsePosters(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Poster>((json) => Poster.fromJson(json)).toList();
}
