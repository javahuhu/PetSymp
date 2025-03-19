import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // Detect server IP address automatically
  static Future<String> getServerIP() async {
    try {
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          if (addr.address.startsWith("192.")) {
            return addr.address;
          }
        }
      }
    } catch (e) {
      print("⚠️ Error detecting IP: $e");
    }
    return "192.168.0.107"; // Default IP if auto-detection fails
  }

  // Main diagnosis function
  static Future<Map<String, dynamic>?> diagnosePet({
    required String userName,
    required List<String> symptoms,
    required int age,
    required String breed,
    required String size,
    required Map<String, Map<String, String>> userAnswers,
  }) async {
    final String serverIP = await getServerIP();
    final Uri url = Uri.parse("http://$serverIP:8000/diagnose");

    // Prepare the fact base according to backend expectations.
    // Note: The key "owner" is used (instead of "userName")
    final Map<String, dynamic> factBase = {
      "owner": userName.trim().isNotEmpty ? userName : "Unknown",
      "symptoms": symptoms.isNotEmpty ? symptoms : ["None"],
      "pet_info": {
        "age": age > 0 ? age.toString() : "1",
        "breed": breed.trim().isNotEmpty ? breed : "Unknown",
        "size": _validateSize(size),
      },
      "user_answers": userAnswers,
    };

    try {
      print("\n📤 Sending API Request to: $url");
      print("📤 Request Data: ${jsonEncode(factBase)}");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(factBase),
      ).timeout(const Duration(seconds: 10));

      print("📩 Response Status: ${response.statusCode}");
      if (kDebugMode && response.body.length < 1000) {
        print("📩 Response Body: ${response.body}");
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData;
      } else {
        print("❌ API Error: ${response.statusCode} - ${response.reasonPhrase}");
        return null;
      }
    } catch (e) {
      print("🚨 Failed to connect to API: $e");
      return null;
    }
  }

  // Validate pet size
  static String _validateSize(String size) {
    final validSizes = ["Small", "Medium", "Large"];
    String formattedSize = size.trim().isNotEmpty ? size.capitalize() : "Medium";
    return validSizes.contains(formattedSize) ? formattedSize : "Medium";
  }

  // Debug endpoint to test connectivity
  static Future<bool> testConnection() async {
    try {
      final String serverIP = await getServerIP();
      final Uri url = Uri.parse("http://$serverIP:8000/debug/all-symptoms");
      
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      print("🚨 Connection test failed: $e");
      return false;
    }
  }
  
  // Get all symptoms from the backend
  static Future<List<String>> getAllSymptoms() async {
    try {
      final String serverIP = await getServerIP();
      final Uri url = Uri.parse("http://$serverIP:8000/debug/all-symptoms");
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        List<String> allSymptoms = [];
        
        // Flatten the list of symptoms from all illnesses
        data.forEach((illness, symptoms) {
          for (var symptom in symptoms) {
            if (!allSymptoms.contains(symptom)) {
              allSymptoms.add(symptom);
            }
          }
        });
        
        return allSymptoms;
      }
      return [];
    } catch (e) {
      print("🚨 Failed to get symptoms: $e");
      return [];
    }
  }
}

// Helper extension to capitalize strings
extension StringCasingExtension on String {
  String capitalize() =>
      isNotEmpty ? "${this[0].toUpperCase()}${substring(1).toLowerCase()}" : "";
}
