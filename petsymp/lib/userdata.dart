import 'package:flutter/material.dart';

class UserData with ChangeNotifier {
  String _userName = '';
  String _anotherSymptom = '';
  String _duration = '';
  String _selectedSymptom = "";
  List<String> _petSymptoms = [];
  List<String> _questions = [];

  // Getter methods
  String get userName => _userName;
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

  // ✅ Add symptoms (avoiding duplicates)
  void addPetSymptom(String symptom) {
    if (!_petSymptoms.contains(symptom)) {
      _petSymptoms.add(symptom);
      notifyListeners();
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
    notifyListeners();
  }

  // Symptom-to-Questions Mapping
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

  // ✅ Set selected symptom and fetch related questions
  void setSelectedSymptom(String symptom) {
    _selectedSymptom = symptom;
    _questions = _symptomQuestions[symptom] ?? [];
    notifyListeners();
  }
}
