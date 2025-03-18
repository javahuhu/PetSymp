import 'dart:convert';
import 'package:http/http.dart' as http;
import 'userdata.dart';

class ApiService {
  static const String baseUrl = "http://192.168.1.102:8000";  // ✅ Ensure correct IP

  static Future<Map<String, dynamic>?> diagnosePet(UserData userData) async {
    final Uri url = Uri.parse("$baseUrl/diagnose");  

    // ✅ Ensure all required fields are sent
    List<String> allSymptoms = {
      ...userData.petSymptoms,
      if (userData.selectedSymptom.isNotEmpty) userData.selectedSymptom,
      if (userData.anotherSymptom.isNotEmpty) userData.anotherSymptom,
    }.toList();

    final Map<String, dynamic> requestData = {
      "userName": userData.userName.trim().isNotEmpty ? userData.userName : "Unknown",
      "age": userData.age > 0 ? userData.age.toString() : "1",
      "breed": userData.breed.trim().isNotEmpty ? userData.breed : "Unknown",
      "size": userData.size.trim().isNotEmpty ? userData.size : "Medium",
      "weight": "5.0",
      "height": "50",
      "symptoms": allSymptoms.isNotEmpty ? allSymptoms : ["None"],
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
}
