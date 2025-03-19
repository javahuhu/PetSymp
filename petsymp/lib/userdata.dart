import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'fastapi.dart';

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

  // NEW: track only newly added symptoms
  List<String> _newSymptoms = [];
  List<String> get newSymptoms => _newSymptoms;

  // Optional: track which symptom each question comes from
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
    if (!_petSymptoms.contains(symptom)) {
      _petSymptoms.add(symptom);
    }
    // Update questions using new symptoms if available
    updateQuestions();
    notifyListeners();
  }

  // NEW: Use this when adding additional (new) symptoms.
  void addNewPetSymptom(String symptom) {
    if (!_newSymptoms.contains(symptom)) {
      _newSymptoms.add(symptom);
      if (!_petSymptoms.contains(symptom)) {
        _petSymptoms.add(symptom);
      }
      updateQuestions(); // Now update questions based on new input only.
      notifyListeners();
    }
  }

  void setAnotherSymptom(String symptom) {
    if (!_petSymptoms.contains(symptom)) {
      _petSymptoms.add(symptom);
      updateQuestions();
    }
    notifyListeners();
  }

  void setSelectedSymptom(String symptom) {
    _selectedSymptom = symptom;
    updateQuestions();
    notifyListeners();
  }

  void setSymptomDuration(String symptom, String duration) {
    _symptomDurations[symptom] = duration;
    notifyListeners();
  }


   void addSymptomAnswer(String symptom, String answer) {
  _symptomDurations[symptom] = answer;
  notifyListeners();
}

  Map<String, String> getSymptomDurations() {
    return _symptomDurations;
  }

  void setDiagnosisResults(List<Map<String, dynamic>> results) {
    _diagnosisResults = results;
    notifyListeners();
  }

  // 🔹 Mapping for symptom questions and impact values.
  final Map<String, dynamic> _symptomQuestions = {
    "vomiting": {
      "questions": [
        "How long has your pet had vomiting?",
        "Is the vomiting Mild or Severe?"
      ],
      "impactDays": {
        "1-4 days": 1.1,
        "5-7 days": 1.2
      },
      "impactSymptom": {
        "mild": 1.1,
        "severe": 1.5,
      },
    },
    "diarrhea": {
      "questions": [
        "How long has your pet had diarrhea?",
        "Is the diarrhea Watery or Bloody?"
      ],
      "impactDays": {
        "1-4 days": 1.1,
        "5-7 days": 1.2
      },
      "impactSymptom": {
        "watery": 1.3,
        "bloody": 1.5,
      }
    },
    "coughing": {
      "questions": [
        "How long has your pet had coughing?",
        "Is the coughing Dry or Wet?"
      ],
      "impactDays": {
        "5-7 days": 1.2,
        "8-14 days": 1.4,
        "persistent": 1.1,
        "1-4 days": 1.1
      },
      "impactSymptom": {
        "dry": 1.2,
        "wet": 1.4,
      },
    },
    "fever": {
      "questions": [
        "How long has your pet had fever?",
        "Is the fever Mild, Moderate, or Severe?"
      ],
      "impactDays": {
        "1-4 days": 1.1,
        "5-7 days": 1.2,
        "8-14 days": 1.4
      },
      "impactSymptom": {
        "mild": 1.1,
        "moderate": 1.3,
        "severe": 1.5,
      }
    },
    "muscle paralysis": {
      "questions": [
        "How long has your pet had muscle paralysis?",
        "Is the muscle paralysis Ascending?"
      ],
      "impactDays": {
        "1-2 days": 1.0,
        "3-5 days": 1.1,
        "6-10 days": 1.2,
        "11+ days": 1.5
      },
      "impactSymptom": {
        "ascending": 1.3,
        "irreversible": 1.2,
      }
    }
  };

  List<String> getPredefinedSymptoms() {
    return _symptomQuestions.keys.toList();
  }

  // Updated updateQuestions method:
  // If new symptoms exist, generate questions only for those new symptoms.
  void updateQuestions() {
    // Use newSymptoms for question generation if available;
    // otherwise fall back to all petSymptoms.
    List<String> symptomsForQuestions = _newSymptoms.isNotEmpty ? _newSymptoms : _petSymptoms;
    print("🚀 Updating Questions for Symptoms: $symptomsForQuestions");

    if (symptomsForQuestions.isNotEmpty) {
      List<String> aggregatedQuestions = [];
      List<List<String>> aggregatedImpactChoices = [];
      List<String> questionSymptoms = [];
      for (String symptom in symptomsForQuestions) {
        String symptomKey = symptom.toLowerCase();
        if (_symptomQuestions.containsKey(symptomKey)) {
          List<String> questionsForSymptom = List<String>.from(_symptomQuestions[symptomKey]["questions"]);
          aggregatedQuestions.addAll(questionsForSymptom);
          // Record the symptom for each of its two questions (assuming 2 per symptom)
          questionSymptoms.add(symptom);
          questionSymptoms.add(symptom);
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
          aggregatedImpactChoices.add(impactDaysChoices);
          aggregatedImpactChoices.add(impactSymptomChoices);
        }
      }
      _questions = aggregatedQuestions;
      _impactChoices = aggregatedImpactChoices;
      _questionSymptoms = questionSymptoms;
    } else {
      _questions = [];
      _impactChoices = [[], []];
      _questionSymptoms = [];
    }
    print("✅ Updated Questions: $_questions");
    print("✅ Updated Impact Choices: $_impactChoices");
    print("✅ Question Symptoms: $_questionSymptoms");
    notifyListeners();
  }

  Future<void> fetchDiagnosis() async {
  final Uri url = Uri.parse("http://10.153.70.133:8000/diagnose");

  if (_anotherSymptom.isNotEmpty && !_petSymptoms.contains(_anotherSymptom)) {
    _petSymptoms.add(_anotherSymptom);
  }

  // Build the request payload with additional required keys
  final Map<String, dynamic> requestData = {
    "userName": _userName,
    "symptoms": _petSymptoms.toSet().toList(),
    "age": _petAge.toString(),
    "breed": _breed,
    "size": _petSize,
    // Provide pet_info as expected by the backend
    "pet_info": {
      "age": _petAge.toString(),
      "breed": _breed,
      "size": _petSize,
    },
    // Provide user_answers (the answers to the symptom questions)
    "user_answers": _symptomDurations,
  };

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestData),
    );

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
