import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/mock_data.dart';

class ConfigService with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<String> statuses = MockData.statuses;
  List<String> priorities = MockData.priorities;
  List<String> nextActions = MockData.nextActions;
  List<String> projectTypes = MockData.projectTypes;
  List<String> currencies = ['\$', '€', '£', '¥', '₨'];
  int daysHighlightThreshold = 7;

  // Singleton pattern
  static final ConfigService _instance = ConfigService._internal();
  factory ConfigService() => _instance;

  ConfigService._internal() {
    _db.collection('config').doc('appConfig').snapshots().listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        if (data['statuses'] != null) {
          statuses = List<String>.from(data['statuses']);
        }
        if (data['priorities'] != null) {
          priorities = List<String>.from(data['priorities']);
        }
        if (data['nextActions'] != null) {
          nextActions = List<String>.from(data['nextActions']);
        }
        if (data['projectTypes'] != null) {
          projectTypes = List<String>.from(data['projectTypes']);
        }
        if (data['currencies'] != null) {
          currencies = List<String>.from(data['currencies']);
        }
        if (data['daysHighlightThreshold'] != null) {
          daysHighlightThreshold = data['daysHighlightThreshold'] as int;
        }
        notifyListeners();
      }
    });
  }
}
