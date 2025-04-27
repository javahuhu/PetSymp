// lib/api_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dynamicconnections.dart'; // Import our config file

class ApiService {
  /// Main diagnosis function
  static Future<Map<String, dynamic>?> diagnosePet({
    required String userName,
    required List<String> symptoms,
    required int age,
    required String breed,
    required String size,
    required String petType,  // ← new!
    required Map<String, Map<String, String>> userAnswers,
  }) async {
    final Uri url = Uri.parse(AppConfig.diagnoseURL);

    final factBase = {
      "owner": userName.trim().isNotEmpty ? userName : "Unknown",
      "symptoms": symptoms.isNotEmpty ? symptoms : ["None"],
      "pet_type": petType.toLowerCase(),           // ← top-level pet_type
      "pet_info": {
        "age": age > 0 ? age.toString() : "1",
        "breed": breed.trim().isNotEmpty ? breed : "Unknown",
        "size": _validateSize(size),
      },
      "user_answers": userAnswers,
    };

    try {
      if (kDebugMode) {
        print("\n📤 Sending API Request to: $url");
        print("📤 Request Data: ${jsonEncode(factBase)}");
      }

      final response = await http
          .post(url,
              headers: {"Content-Type": "application/json"},
              body: jsonEncode(factBase))
          .timeout(const Duration(seconds: 10));

      if (kDebugMode) {
        print("📩 Response Status: ${response.statusCode}");
        if (response.body.length < 1000) print("📩 Body: ${response.body}");
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print("❌ API Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("🚨 Failed to connect: $e");
      return null;
    }
  }

  /// Validate pet size
  static String _validateSize(String size) {
    final valid = ["Small", "Medium", "Large"];
    final cap = size.trim().isNotEmpty
        ? "${size[0].toUpperCase()}${size.substring(1).toLowerCase()}"
        : "Medium";
    return valid.contains(cap) ? cap : "Medium";
  }

  /// Debug endpoint to test connectivity
  static Future<bool> testConnection(String petType) async {
    try {
      final Uri url =
          Uri.parse(AppConfig.getAllSymptomsURL(petType.toLowerCase()));
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      print("🚨 Connection test failed: $e");
      return false;
    }
  }

  /// Get all symptoms from the backend
  static Future<List<String>> getAllSymptoms(String petType) async {
    try {
      final Uri url =
          Uri.parse(AppConfig.getAllSymptomsURL(petType.toLowerCase()));
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final allSymptoms = <String>{};

        // Flatten the list of symptoms from all illnesses
        data.forEach((_, symptoms) {
          for (var s in symptoms as List) {
            allSymptoms.add(s as String);
          }
        });

        return allSymptoms.toList();
      }
      return [];
    } catch (e) {
      print("🚨 Failed to get symptoms: $e");
      return [];
    }
  }
}
