import 'package:flutter/material.dart';

class UserData with ChangeNotifier {
  String _userName = '';
  int _petHeight = 0;
  int _petWeight = 0;
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
    _petHeight= height;
    notifyListeners();
  }

  void setpetWeight(int weight) {
    _petWeight= weight;
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
    _questions = _symptomQuestions[symptom] ?? [];
    notifyListeners();
  }

  // Symptom-to-Questions Mapping
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
      "Is your pet showing symptoms like \ndrooling,  aggression, or seizures?",
      "Is your pet vaccinated against rabies?",
    ],
    "Lethargy": [
      "How long has your pet been lethargic?",
      "Has your pet been eating and drinking \nnormally?",
      "Is your pet experiencing any other \nsymptoms like vomiting or diarrhea?",
    ],

    "Vomiting + Rabies": [
    "Is your pet experiencing any other \nsymptoms like vomiting or diarrhea?",
    ],
  };

  // ✅ Set selected symptom and fetch related questions
  void setSelectedSymptom(String symptom) {
    _selectedSymptom = symptom;
    _questions = _symptomQuestions[symptom] ?? [];
    notifyListeners();
  }

  
}
