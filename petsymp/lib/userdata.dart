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
  List<Map<String, dynamic>> _diagnosisResults = []; // ✅ Stores illness results

  // ✅ Getters
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
  List<Map<String, dynamic>> get diagnosisResults => _diagnosisResults; // ✅ Diagnosis results

  // ✅ Setters
  void setUserName(String name) {
    _userName = name;
    notifyListeners();
  }

  void setOTPemail(String email){
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
      _updateQuestions();
    }
  }

  void setAnotherSymptom(String symptom) {
  if (!_petSymptoms.contains(symptom)) {
    _petSymptoms.add(symptom);
  }
  notifyListeners();
}



  void setSelectedSymptom(String symptom) {
    _selectedSymptom = symptom;
    _updateQuestions();
  }

   void setSymptomDuration(String symptom, String duration) {
    _symptomDurations[symptom] = duration; // ✅ Store duration per symptom
    notifyListeners();
  }

  Map<String, String> getSymptomDurations() {
    return _symptomDurations;
  }
  void setDiagnosisResults(List<Map<String, dynamic>> results) {
    _diagnosisResults = results;
    notifyListeners();
  }

  // 🔹 **Symptom-to-Questions Mapping**
  final Map<String, List<String>> _symptomQuestions = {
    "Vomiting": [
      "How often has your pet been vomiting?",
      "Is your pet vomiting food, bile, or something unusual like blood?",
      "Has your pet eaten anything unusual?",
      "Is your pet showing additional symptoms?",
      "How long has your pet been vomiting?"
    ],
    "Rabies": [
      "Has your pet been bitten or scratched by another animal recently?",
      "What type of animal bit or scratched your pet?",
      "Is your pet showing symptoms like drooling, aggression, or seizures?",
      "Is your pet vaccinated against rabies?",
    ],
    "Lethargy": [
      "How long has your pet been lethargic?",
      "Has your pet been eating and drinking normally?",
      "Is your pet experiencing any other symptoms like vomiting or diarrhea?",
    ],
  };

  // ✅ **Detect & Combine Questions for Single or Multiple Symptoms**
  void _updateQuestions() {
  List<String> allSymptoms = [..._petSymptoms]; // ✅ Include all symptoms

  List<String> combinedQuestions = [];
  for (String sym in allSymptoms) {
    if (_symptomQuestions.containsKey(sym)) {
      combinedQuestions.addAll(_symptomQuestions[sym]!);
    }
  }

  _questions = combinedQuestions.toSet().toList(); // Remove duplicates
  notifyListeners();
}


  // ✅ Fetch Diagnosis from FastAPI
 Future<void> fetchDiagnosis() async {
  final Uri url = Uri.parse("http://192.168.1.102:8000/diagnose");

  // ✅ Ensure all symptoms are stored properly
  if (_anotherSymptom.isNotEmpty && !_petSymptoms.contains(_anotherSymptom)) {
    _petSymptoms.add(_anotherSymptom); // ✅ Merge before sending request
  }

  final Map<String, dynamic> requestData = {
    "userName": _userName,
    "symptoms": _petSymptoms.toSet().toList(),  // ✅ Only send `_petSymptoms`
    "age": _petAge.toString(),
    "breed": _breed,
    "size": _petSize
  };

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      List<Map<String, dynamic>> illnesses = List<Map<String, dynamic>>.from(jsonResponse["diagnoses"]);
      setDiagnosisResults(illnesses);  
    } else {
      print("❌ API Error: ${response.statusCode}");
    }
  } catch (e) {
    print("🚨 Failed to connect to API: $e");
  }
}


}
