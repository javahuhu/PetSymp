import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://192.168.1.101:8000"; // Your local IP

  static Future<void> sendData(String name, String description, double price) async {
    var url = Uri.parse("$baseUrl/items/");
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "description": description,
        "price": price,
      }),
    );

    if (response.statusCode == 200) {
      print("Response: ${response.body}");
    } else {
      print("Error: ${response.statusCode}");
    }
  }
}
