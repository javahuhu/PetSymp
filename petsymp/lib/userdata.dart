import 'package:flutter/material.dart';

class UserData with ChangeNotifier {
  String _userName = '';
  int _petHeight = 0;
  int _petWeight = 0;
  int _petAge = 0;
  String _breed = '';
  String _anotherSymptom = '';
  String _duration = '';
  String _selectedSymptom = "";
  final List<String> _petSymptoms = [];
  List<String> _questions = [];

  // Getter methods
  String get userName => _userName;
  String get breed => _breed;
  int get height => _petHeight;
  int get weight => _petWeight;
  int get age => _petAge;
  String get anotherSymptom => _anotherSymptom;
  String get duration => _duration;
  String get selectedSymptom => _selectedSymptom;
  List<String> get petSymptoms => _petSymptoms;
  List<String> get questions => _questions;

  // ✅ Set user name
  void setUserName(String name) {
    _userName = name;
    notifyListeners();
  }

  void setpetBreed(String breed) {
    _breed = breed;
    notifyListeners();
  }

  void setpetHeight(int height) {
    _petHeight = height;
    notifyListeners();
  }

  void setpetAge(int age ){
    _petAge = age;
   notifyListeners();
  }

  void setpetWeight(int weight) {
    _petWeight = weight;
    notifyListeners();
  }

  // ✅ Add symptoms (avoiding duplicates)
  void addPetSymptom(String symptom) {
    if (!_petSymptoms.contains(symptom)) {
      _petSymptoms.add(symptom);
      _updateQuestions(); // Update questions when a symptom is added
    }
  }

  // ✅ Set duration
  void setDuration(String selectedDuration) {
    _duration = selectedDuration;
    notifyListeners();
  }

  // ✅ Set additional symptom
  void setAnotherSymptom(String symptom) {
    _anotherSymptom = symptom;
    _updateQuestions();
  }

  // 🔹 **Symptom-to-Questions Mapping**
  final Map<String, List<String>> _symptomQuestions = {
    "Vomiting": [
      "How often has your pet been vomiting?",
      "Is your pet vomiting food, bile, or \nsomething unusual like blood?",
      "Has your pet eaten anything unusual?",
      "Is your pet showing additional \nsymptoms?",
      "How long has your pet been vomiting?"
    ],
    "Rabies": [
      "Has your pet been bitten or scratched by \nanother animal recently?",
      "What type of animal bit or scratched \nyour pet?",
      "Is your pet showing symptoms like \ndrooling, aggression, or seizures?",
      "Is your pet vaccinated against rabies?",
    ],
    "Lethargy": [
      "How long has your pet been lethargic?",
      "Has your pet been eating and drinking \nnormally?",
      "Is your pet experiencing any other \nsymptoms like vomiting or diarrhea?",
    ],
   
  };

  // ✅ **Updated function to handle single and multiple symptoms**
  void setSelectedSymptom(String symptom) {
    _selectedSymptom = symptom;
    _updateQuestions();
  }

  // ✅ **Detect & Combine Questions for Single or Multiple Symptoms**
  void _updateQuestions() {
    // Get all selected symptoms dynamically
    List<String> allSymptoms = [
      if (_selectedSymptom.isNotEmpty) _selectedSymptom,
      if (_anotherSymptom.isNotEmpty) _anotherSymptom,
      ..._petSymptoms
    ];

    // Remove duplicates in case the same symptom was added twice
    allSymptoms = allSymptoms.toSet().toList();

    // ✅ Collect all relevant questions
    List<String> combinedQuestions = [];
    for (String sym in allSymptoms) {
      if (_symptomQuestions.containsKey(sym)) {
        combinedQuestions.addAll(_symptomQuestions[sym]!);
      }
    }

    // ✅ Remove duplicate questions and update the questions list
    _questions = combinedQuestions.toSet().toList();
    notifyListeners();
  }
}
