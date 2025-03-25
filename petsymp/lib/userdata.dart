import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'symptomsquestions.dart';
import 'symptomsdescriptions.dart';
class UserData with ChangeNotifier {
  // Basic user info
  String _userName = '';
  String _petSize = '';
  String _email = '';
  int _petAge = 0;
  String _breed = '';
  String _anotherSymptom = '';

  // Symptom lists
  final List<String> _pendingSymptoms = [];
  final List<String> _finalizedSymptoms = [];
  final List<String> _newSymptoms = [];

  // Symptom-specific QA
  Map<String, String> _symptomDurations = {};
  String _selectedSymptom = "";
  List<Map<String, dynamic>> _diagnosisResults = [];
  List<String> _questions = [];
  List<List<String>> _impactChoices = [];
  List<String> _questionSymptoms = [];

  // Getters
  String get userName => _userName;
  String get email => _email;
  String get breed => _breed;
  String get size => _petSize;
  int get age => _petAge;
  String get anotherSymptom => _anotherSymptom;

  List<String> get pendingSymptoms => _pendingSymptoms;
  List<String> get finalizedSymptoms => _finalizedSymptoms;
  List<String> get newSymptoms => _newSymptoms;
  Map<String, String> get symptomDurations => _symptomDurations;
  String get selectedSymptom => _selectedSymptom;
  List<Map<String, dynamic>> get diagnosisResults => _diagnosisResults;
  List<String> get questions => _questions;
  List<List<String>> get impactChoices => _impactChoices;
  List<String> get questionSymptoms => _questionSymptoms;

  /// ✅ Getter used by NewSummaryScreen
  List<String> get petSymptoms {
    return [..._finalizedSymptoms, ..._pendingSymptoms];
  }

  // Basic setters
  void setUserName(String name) {
    _userName = name;
    notifyListeners();
  }

  void setOTPemail(String email) {
    _email = email;
    notifyListeners();
  }

  void setpetBreed(String breed) {
    _breed = breed;
    notifyListeners();
  }

  void setpetSize(String size) {
    _petSize = size;
    notifyListeners();
  }

  void setpetAge(int age) {
    _petAge = age;
    notifyListeners();
  }

  void setAnotherSymptom(String symptom) {
    _anotherSymptom = symptom.trim().toLowerCase();
    notifyListeners();
  }

  // Add/remove symptoms
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
    if (!_finalizedSymptoms.contains(normalized) && !_pendingSymptoms.contains(normalized)) {
      _pendingSymptoms.add(normalized);
    }
    notifyListeners();
  }

  // Q&A logic
  void setSelectedSymptom(String symptom) {
    _selectedSymptom = symptom.trim().toLowerCase();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateQuestions();
      notifyListeners();
    });
  }

  void setSymptomDuration(String symptom, String duration) {
    _symptomDurations[symptom.trim().toLowerCase()] = duration;
    notifyListeners();
  }

  void addSymptomAnswer(String symptom, String answer) {
    _symptomDurations[symptom.trim().toLowerCase()] = answer;
    notifyListeners();
  }

  Map<String, String> getSymptomDurations() {
    return _symptomDurations;
  }

  void setDiagnosisResults(List<Map<String, dynamic>> results) {
    _diagnosisResults = results;
    notifyListeners();
  }

  // Symptom-question mapping
   // Mapping for symptom questions and impact values.
  final Map<String, dynamic> _symptomQuestions = symptomQuestions;

  List<String> getPredefinedSymptoms() {
    return _symptomQuestions.keys.toList();
  }

  void updateQuestions() {
    final key = _selectedSymptom.toLowerCase();
    if (key.isNotEmpty && _symptomQuestions.containsKey(key)) {
      _questions = List<String>.from(_symptomQuestions[key]["questions"]);
      _questionSymptoms = List.filled(_questions.length, _selectedSymptom);

      List<String> impactDaysChoices = [];
      List<String> impactSymptomChoices = [];

      if (_symptomQuestions[key].containsKey("impactDays")) {
        impactDaysChoices = List<String>.from(
            (_symptomQuestions[key]["impactDays"] as Map<String, dynamic>).keys);
      }
      if (_symptomQuestions[key].containsKey("impactSymptom")) {
        impactSymptomChoices = List<String>.from(
            (_symptomQuestions[key]["impactSymptom"] as Map<String, dynamic>).keys);
      }

      _impactChoices = [impactDaysChoices, impactSymptomChoices];
    } else {
      _questions = [];
      _impactChoices = [[], []];
      _questionSymptoms = [];
    }
  }

  // Call Flask API to get diagnosis results
  Future<void> fetchDiagnosis() async {
    final Uri url = Uri.parse("http://192.168.1.101:8000/diagnose");
    final allTypedSymptoms = [..._finalizedSymptoms];
    final uniqueSymptoms = allTypedSymptoms.toSet().toList();

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
      } else {
        print("❌ API Error: ${response.statusCode}");
      }
    } catch (e) {
      print("🚨 Failed to connect: $e");
    }
  }
}
