import 'dart:convert';

import 'package:edu_valley/services/api.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Ad {
  final int id, serial;
  final String name;
  final String? site;

  Ad({
    required this.id,
    required this.serial,
    required this.name,
    this.site,
  });

  factory Ad.fromJson(Map<String, dynamic> json) {
    return Ad(
      id: json['id'] as int,
      serial: json['serial'] as int,
      name: json['name'] as String,
      site: json['site'] as String?,
    );
  }
}

Future<List<Ad>> fetchAds(http.Client client) async {
  final response = await client.get(
    Uri.parse('${Network.url}/getAds'),
  );

  // Use the compute function to run parseAds in a separate isolate.
  return compute(parseAds, response.body);
}

Future<List<Ad>> searchAds(
  http.Client client,
  String category,
) async {
  final response = await client.get(
    Uri.parse(
      '${Network.url}/getAds/'
      '$category',
    ),
  );

  // Use the compute function to run parseVideos in a separate isolate.
  return compute(parseAds, response.body);
}

// A function that converts a response body into a List<Ad>.
List<Ad> parseAds(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Ad>((json) => Ad.fromJson(json)).toList();
}
