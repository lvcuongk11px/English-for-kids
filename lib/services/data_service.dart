import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/topic.dart';

class DataService {
  const DataService();
  Future<List<Topic>> loadTopics() async {
    final source = await rootBundle.loadString('assets/data/topics.json');
    final decoded = jsonDecode(source) as Map<String, dynamic>;
    return (decoded['topics'] as List<dynamic>)
        .map((topic) => Topic.fromJson(topic as Map<String, dynamic>))
        .toList(growable: false);
  }
}
