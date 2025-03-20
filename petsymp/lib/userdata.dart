import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserData with ChangeNotifier {
  String _userName = '';
  String _petSize = '';
  String _email = '';
  int _petAge = 0;
  String _breed = '';
  String _anotherSymptom = '';
  Map<String, String> _symptomDurations = {};
  String _selectedSymptom = "";
  List<String> _petSymptoms = [];
  List<String> _questions = [];
  List<List<String>> _impactChoices = [];
  List<Map<String, dynamic>> _diagnosisResults = [];

  // Track only the new (unanswered) symptoms.
  List<String> _newSymptoms = [];
  List<String> get newSymptoms => _newSymptoms;

  // Track which symptom each question belongs to.
  List<String> _questionSymptoms = [];
  List<String> get questionSymptoms => _questionSymptoms;

  // Getters
  String get userName => _userName;
  String get email => _email;
  String get breed => _breed;
  String get size => _petSize;
  int get age => _petAge;
  String get anotherSymptom => _anotherSymptom;
  Map<String, String> get symptomDurations => _symptomDurations;
  String get selectedSymptom => _selectedSymptom;
  List<String> get petSymptoms => _petSymptoms;
  List<String> get questions => _questions;
  List<List<String>> get impactChoices => _impactChoices;
  List<Map<String, dynamic>> get diagnosisResults => _diagnosisResults;

  // Setters
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
  
  void addPetSymptom(String symptom) {
    String normalized = symptom.trim();
    if (!_petSymptoms.contains(normalized)) {
      _petSymptoms.add(normalized);
    }
    // Do not update questions here.
    notifyListeners();
  }
  
  // Use this for each new (single) symptom input.
  void addNewPetSymptom(String symptom) {
    String normalized = symptom.trim();
    if (!_newSymptoms.contains(normalized)) {
      _newSymptoms.add(normalized);
      if (!_petSymptoms.contains(normalized)) {
        _petSymptoms.add(normalized);
      }
      // Do not update questions here.
      notifyListeners();
    }
  }
  
  // Once a symptom’s questions are answered, clear it from the new batch.
  void clearNewSymptoms() {
    _newSymptoms.clear();
    notifyListeners();
  }
  
  void setAnotherSymptom(String symptom) {
    String normalized = symptom.trim();
    _anotherSymptom = normalized;  // Update the field!
    if (!_petSymptoms.contains(normalized)) {
      _petSymptoms.add(normalized);
    }
    // Optionally update questions if needed.
    notifyListeners();
  }
  
  void setSelectedSymptom(String symptom) {
    _selectedSymptom = symptom.trim();
    // Delay updating questions until after the current frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateQuestions();
      notifyListeners();
    });
  }
  
  void setSymptomDuration(String symptom, String duration) {
    _symptomDurations[symptom.trim()] = duration;
    notifyListeners();
  }
  
  void addSymptomAnswer(String symptom, String answer) {
    _symptomDurations[symptom.trim()] = answer;
    notifyListeners();
  }
  
  Map<String, String> getSymptomDurations() {
    return _symptomDurations;
  }
  
  void setDiagnosisResults(List<Map<String, dynamic>> results) {
    _diagnosisResults = results;
    notifyListeners();
  }

  // Mapping for symptom questions and impact values.
  final Map<String, dynamic> _symptomQuestions = {
    "vomiting": {
      "questions": [
        "How long has your pet had vomiting?",
        "Is the vomiting Mild or Severe?"
      ],
      "impactDays": {"1-4 days": 1.1, "5-7 days": 1.2},
      "impactSymptom": {"mild": 1.1, "severe": 1.5},
    },
    "diarrhea": {
      "questions": [
        "How long has your pet had diarrhea?",
        "Is the diarrhea Watery or Bloody?"
      ],
      "impactDays": {"1-4 days": 1.1, "5-7 days": 1.2},
      "impactSymptom": {"watery": 1.3, "bloody": 1.5},
    },
    "coughing": {
      "questions": [
        "How long has your pet had coughing?",
        "Is the coughing Dry or Wet?"
      ],
      "impactDays": {
        "1-4 days": 1.1,
        "5-7 days": 1.2,
        "8-14 days": 1.4,
        "persistent": 1.1
      },
      "impactSymptom": {"dry": 1.2, "wet": 1.4},
    },
    "fever": {
      "questions": [
        "How long has your pet had fever?",
        "Is the fever Mild, Moderate, or Severe?"
      ],
      "impactDays": {"1-4 days": 1.1, "5-7 days": 1.2, "8-14 days": 1.4},
      "impactSymptom": {"mild": 1.1, "moderate": 1.3, "severe": 1.5},
    },
    "lethargy": {
      "questions": [
        "How long has your pet had lethargy?",
        "Is the lethargy Mild or Severe?"
      ],
      "impactDays": {"1-2 days": 1.0, "3-5 days": 1.1, "6-10 days": 1.2, "11+ days": 1.5},
      "impactSymptom": {"mild": 1.1, "severe": 1.5, "variable": 1.1},
    },
    "eye discharge": {
      "questions": [
        "How long has your pet had eye discharge?",
        "Is the eye discharge Watery or Mucous-like?"
      ],
      "impactDays": {"1-2 days": 1.0, "3-10 days": 1.1},
      "impactSymptom": {"watery": 1.3, "mucous-like": 1.2},
    },
    "nasal discharge": {
      "questions": [
        "How long has your pet had nasal discharge?",
        "Is the nasal discharge Clear or Purulent?"
      ],
      "impactDays": {"1-2 days": 1.0, "3-10 days": 1.1},
      "impactSymptom": {"clear": 1.2, "purulent": 1.2},
    },
    "muscle twitching": {
      "questions": [
        "How long has your pet had muscle twitching?",
        "Is the muscle twitching Mild or Severe?"
      ],
      "impactDays": {"1-2 days": 1.0, "3-5 days": 1.1, "6-10 days": 1.2, "11+ days": 1.5},
      "impactSymptom": {"mild": 1.1, "severe": 1.5, "variable": 1.1},
    },
    "seizures": {
      "questions": [
        "How long has your pet had seizures?",
        "Are the seizures Partial or Generalized?"
      ],
      "impactDays": {"1-2 days": 1.0, "3-5 days": 1.1, "6-10 days": 1.2, "11+ days": 1.5},
      "impactSymptom": {
        "partial": 1.1,
        "generalized": 1.4,
        "intermittent": 1.2,
        "progressive": 1.3,
        "chronic": 1.1
      },
    },
    "sneezing": {
      "questions": [
        "How long has your pet had sneezing?",
        "Is the sneezing Intermittent?"
      ],
      "impactDays": {"1-2 days": 1.0, "3-5 days": 1.1, "6-10 days": 1.2},
      "impactSymptom": {"intermittent": 1.2},
    },
    "muscle paralysis": {
      "questions": [
        "How long has your pet had muscle paralysis?",
        "Is the muscle paralysis Ascending?"
      ],
      "impactDays": {"1-2 days": 1.0, "3-5 days": 1.1, "6-10 days": 1.2, "11+ days": 1.5},
      "impactSymptom": {"ascending": 1.3, "irreversible": 1.2},
    },
  };

  List<String> getPredefinedSymptoms() {
    return _symptomQuestions.keys.toList();
  }

  // Update follow-up questions using only the currently selected symptom.
  // This is called via setSelectedSymptom.
  void updateQuestions() {
    if (_selectedSymptom.isNotEmpty) {
      final String symptomKey = _selectedSymptom.toLowerCase();
      if (_symptomQuestions.containsKey(symptomKey)) {
        _questions = List<String>.from(_symptomQuestions[symptomKey]["questions"]);
        _questionSymptoms = List.filled(_questions.length, _selectedSymptom);
        List<String> impactDaysChoices = [];
        List<String> impactSymptomChoices = [];
        if (_symptomQuestions[symptomKey].containsKey("impactDays")) {
          impactDaysChoices = List<String>.from(
            (_symptomQuestions[symptomKey]["impactDays"] as Map<String, dynamic>).keys,
          );
        }
        if (_symptomQuestions[symptomKey].containsKey("impactSymptom")) {
          impactSymptomChoices = List<String>.from(
            (_symptomQuestions[symptomKey]["impactSymptom"] as Map<String, dynamic>).keys,
          );
        }
        _impactChoices = [impactDaysChoices, impactSymptomChoices];
      } else {
        _questions = [];
        _impactChoices = [[], []];
        _questionSymptoms = [];
      }
    } else {
      _questions = [];
      _impactChoices = [[], []];
      _questionSymptoms = [];
    }
    // No immediate notifyListeners() here; it's called in setSelectedSymptom's post-frame callback.
  }

  Future<void> fetchDiagnosis() async {
    final Uri url = Uri.parse("http://10.0.2.2:8000/diagnose");

    if (_anotherSymptom.isNotEmpty && !_petSymptoms.contains(_anotherSymptom)) {
      _petSymptoms.add(_anotherSymptom);
    }

    final Map<String, dynamic> requestData = {
      "owner": _userName,
      "symptoms": _petSymptoms.toSet().toList(),
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
        List<Map<String, dynamic>> illnesses =
            List<Map<String, dynamic>>.from(jsonResponse["diagnoses"]);
        setDiagnosisResults(illnesses);
      } else {
        print("❌ API Error: ${response.statusCode}");
      }
    } catch (e) {
      print("🚨 Failed to connect to API: $e");
    }
  }
}
