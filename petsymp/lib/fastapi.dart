import 'dart:convert';
import 'package:http/http.dart' as http;
import 'userdata.dart';

class ApiService {
  static const String baseUrl = "http://10.153.70.133:8000";  // ✅ Updated with correct IP

  static Future<Map<String, dynamic>?> diagnosePet(UserData userData) async {
    final Uri url = Uri.parse("$baseUrl/diagnose");  

    // ✅ Ensure all required fields are sent
    List<String> allSymptoms = {
      ...userData.petSymptoms,
      if (userData.selectedSymptom.isNotEmpty) userData.selectedSymptom,
      if (userData.anotherSymptom.isNotEmpty) userData.anotherSymptom,
    }.toList();

    // Include symptom durations or answers
    Map<String, String> symptomAnswers = userData.symptomDurations;

    final Map<String, dynamic> requestData = {
      "userName": userData.userName.trim().isNotEmpty ? userData.userName : "Unknown",
      "age": userData.age > 0 ? userData.age.toString() : "1",
      "breed": userData.breed.trim().isNotEmpty ? userData.breed : "Unknown",
      "size": _validateSize(userData.size),
      "symptoms": allSymptoms.isNotEmpty ? allSymptoms : ["None"],
      "user_answers": symptomAnswers, // Add the symptom answers here
    };

    try {
      print("\n📤 Sending API Request to: $url");
      print("📤 Request Data: ${jsonEncode(requestData)}");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestData),
      ).timeout(const Duration(seconds: 10));  // ✅ Prevent infinite waiting

      print("📩 Response Status: ${response.statusCode}");
      print("📩 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print("✅ Diagnosis Received: ${responseData["message"]}");
        return responseData;
      } else {
        print("❌ API Error: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("🚨 Failed to connect to API: $e");
      return null;
    }
  }

  // 📌 Ensure size is valid (Small, Medium, or Large)
  static String _validateSize(String size) {
    final validSizes = ["Small", "Medium", "Large"];
    String formattedSize = size.trim().isNotEmpty ? size.capitalize() : "Medium";
    return validSizes.contains(formattedSize) ? formattedSize : "Medium";
  }
}

// 📌 Helper extension to capitalize strings
extension StringCasingExtension on String {
  String capitalize() => this.isNotEmpty ? "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}" : "";
}
