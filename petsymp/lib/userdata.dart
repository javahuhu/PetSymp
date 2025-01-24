import 'package:flutter/material.dart';

class UserData with ChangeNotifier {
  String _userName = '';

  String get userName => _userName;

  void setUserName(String name) {
    _userName = name;
    notifyListeners(); // Notify listeners to rebuild UI if needed
  }
}
