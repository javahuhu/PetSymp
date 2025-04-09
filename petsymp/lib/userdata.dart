import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'symptomsquestions.dart';
import 'dynamicconnections.dart'; // Import our connection config

class UserData with ChangeNotifier {
  // Basic user info
  String _userName = '';
  String _petSize = '';
  String _email = '';
  int _petAge = 0;
  String _breed = '';
  String _anotherSymptom = '';
  String? _petImage;
  String _selectedPetType = '';

  // History of past assessments (no petType filter)
  List<Map<String, dynamic>> _history = [];
  List<Map<String, dynamic>> get history => _history;

  // Symptom lists
  final List<String> _pendingSymptoms = [];
  final List<String> _finalizedSymptoms = [];
  final List<String> _newSymptoms = [];

  // Symptom-specific QA
  final Map<String, Map<String, String>> _symptomDurations = {};
  String _selectedSymptom = "";
  List<Map<String, dynamic>> _diagnosisResults = [];
  List<String> _questions = [];
  List<List<String>> _impactChoices = [];
  List<String> _questionSymptoms = [];
  Map<String, List<Map<String, dynamic>>> _symptomDetails = {};

  // Getters
  String get userName => _userName;
  String get email => _email;
  String get breed => _breed;
  String get size => _petSize;
  int get age => _petAge;
  String get anotherSymptom => _anotherSymptom;
  String? get petImage => _petImage;
  String get selectedPetType => _selectedPetType;

  List<String> get pendingSymptoms => _pendingSymptoms;
  List<String> get finalizedSymptoms => _finalizedSymptoms;
  List<String> get newSymptoms => _newSymptoms;
  Map<String, Map<String, String>> get symptomDurations => _symptomDurations;
  String get selectedSymptom => _selectedSymptom;
  List<Map<String, dynamic>> get diagnosisResults => _diagnosisResults;
  List<String> get questions => _questions;
  List<List<String>> get impactChoices => _impactChoices;
  List<String> get questionSymptoms => _questionSymptoms;
  Map<String, List<Map<String, dynamic>>> get symptomDetails => _symptomDetails;

  /// Getter used by NewSummaryScreen
  List<String> get petSymptoms => [..._finalizedSymptoms, ..._pendingSymptoms];

  // -------------------------------------------------------------
  // Firestore History Subscription (no petType filter)
  // -------------------------------------------------------------
  /// Call once you know userId
  void subscribeToHistory(String userId) {
    FirebaseFirestore.instance
      .collection('Users')
      .doc(userId)
      .collection('History')
      .orderBy('date', descending: true)
      .snapshots()
      .listen((snap) {
        _history = snap.docs.map((doc) {
          final data = doc.data();
          data['docId'] = doc.id;
          return data;
        }).toList();
        notifyListeners();
      });
  }

  /// Clears only the basic pet info fields
  void clearBasicInfo() {
    _userName = '';
    _petSize = '';
    _petAge = 0;
    _breed = '';
    _petImage = null;
    notifyListeners();
  }

  // -------------------------------------------------------------
  // Remaining setters & symptom logic unchanged
  // -------------------------------------------------------------
  void setUserName(String name) { _userName = name; notifyListeners(); }
  void setOTPemail(String email) { _email = email; notifyListeners(); }
  void setpetBreed(String breed) { _breed = breed; notifyListeners(); }
  void setpetSize(String size) { _petSize = size; notifyListeners(); }
  void setpetAge(int age) { _petAge = age; notifyListeners(); }
  void setAnotherSymptom(String symptom) {
    _anotherSymptom = symptom.trim().toLowerCase();
    notifyListeners();
  }
  void setPetImage(String imageUrl) {
    _petImage = imageUrl;
    notifyListeners();
  }
  void setSelectedPetType(String type) {
    _selectedPetType = type;
    notifyListeners();
  }

  void addPendingSymptom(String symptom) {
    final normalized = symptom.trim().toLowerCase();
    if (!_pendingSymptoms.contains(normalized)) {
      _pendingSymptoms.add(normalized);
      notifyListeners();
    }
  }
  void finalizeSymptom(String symptom) {
    final normalized = symptom.trim().toLowerCase();
    _pendingSymptoms.remove(normalized);
    if (!_finalizedSymptoms.contains(normalized)) {
      _finalizedSymptoms.add(normalized);
    }
    notifyListeners();
  }
  void removePendingSymptom(String symptom) {
    final normalized = symptom.trim().toLowerCase();
    _pendingSymptoms.remove(normalized);
    _symptomDurations.remove(normalized);
    notifyListeners();
  }
  void addNewSymptom(String symptom) {
    final normalized = symptom.trim().toLowerCase();
    if (!_newSymptoms.contains(normalized)) {
      _newSymptoms.add(normalized);
    }
    notifyListeners();
  }
  void clearNewSymptoms() {
    _newSymptoms.clear();
    notifyListeners();
  }
  void addNewPetSymptom(String symptom) {
    final normalized = symptom.trim().toLowerCase();
    if (!_finalizedSymptoms.contains(normalized) &&
        !_pendingSymptoms.contains(normalized)) {
      _pendingSymptoms.add(normalized);
    }
    notifyListeners();
  }
  void setSelectedSymptom(String symptom) {
    _selectedSymptom = symptom.trim().toLowerCase();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateQuestions();
      notifyListeners();
    });
  }
  void setSymptomDuration(String symptom, String duration) {
    final key = symptom.trim().toLowerCase();
    if (!_symptomDurations.containsKey(key)) {
      _symptomDurations[key] = {};
    }
    _symptomDurations[key]!['duration'] = duration;
    notifyListeners();
  }
  void addSymptomAnswer(String symptom, String question, String answer) {
    final key = symptom.trim().toLowerCase();
    if (!_symptomDurations.containsKey(key)) {
      _symptomDurations[key] = {};
    }
    _symptomDurations[key]![question] = answer;
    notifyListeners();
  }
  void setDiagnosisResults(List<Map<String, dynamic>> results) {
    _diagnosisResults = results;
    notifyListeners();
  }

  final Map<String, dynamic> _symptomQuestions = symptomQuestions;
  List<String> getPredefinedSymptoms() => _symptomQuestions.keys.toList();
  void setSymptomDetails(Map<String, List<Map<String, dynamic>>> details) {
    _symptomDetails = details;
    notifyListeners();
  }

  void updateQuestions() {
    final key = _selectedSymptom.toLowerCase();
    if (key.isNotEmpty && _symptomQuestions.containsKey(key)) {
      final newQuestions = List<String>.from(_symptomQuestions[key]["questions"]);
      _questions.clear();
      _impactChoices.clear();
      _questionSymptoms.clear();
      _questions.addAll(newQuestions);
      _questionSymptoms.addAll(List.filled(newQuestions.length, key));
      List<String> impactDaysChoices = [];
      List<String> impactSymptomChoices = [];
      if (_symptomQuestions[key].containsKey("impactDays")) {
        var v = _symptomQuestions[key]["impactDays"];
        impactDaysChoices = v is List
          ? List<String>.from(v)
          : List<String>.from((v as Map).keys);
      }
      if (_symptomQuestions[key].containsKey("impactSymptom")) {
        var v = _symptomQuestions[key]["impactSymptom"];
        impactSymptomChoices = v is List
          ? List<String>.from(v)
          : List<String>.from((v as Map).keys);
      }
      for (int i = 0; i < newQuestions.length; i++) {
        _impactChoices.add(i == 0 ? impactDaysChoices : impactSymptomChoices);
      }
      notifyListeners();
    }
  }

  Future<void> fetchDiagnosis() async {
    final Uri url = Uri.parse(AppConfig.diagnoseURL);
    final uniqueSymptoms = _finalizedSymptoms.toSet().toList();
    final requestData = {
      "owner": _userName,
      "symptoms": uniqueSymptoms,
      "pet_info": {
        "age": _petAge.toString(),
        "breed": _breed,
        "size": _petSize,
      },
      "user_answers": _symptomDurations,
    };
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestData),
      ).timeout(const Duration(minutes: 2));
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final illnesses = List<Map<String, dynamic>>.from(jsonResponse["diagnoses"]);
        setDiagnosisResults(illnesses);
      }
    } catch (_) {}
  }

  void clearData() {
    _userName = '';
    _petSize = '';
    _email = '';
    _petAge = 0;
    _breed = '';
    _anotherSymptom = '';
    _petImage = null;
    _selectedPetType = '';
    _pendingSymptoms.clear();
    _finalizedSymptoms.clear();
    _newSymptoms.clear();
    _symptomDurations.clear();
    _selectedSymptom = '';
    _diagnosisResults.clear();
    _questions.clear();
    _symptomDetails.clear();
    _impactChoices = [];
    _questionSymptoms = [];
    notifyListeners();
  }
}
