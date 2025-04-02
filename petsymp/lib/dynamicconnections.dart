// lib/dynamicconnections.dart
import 'dart:io';

class AppConfig {
  // Fallback IP (your development machine’s IP)
  static const String fallbackIP = "192.168.1.101";
  // Port where your Flask server is running
  static const int serverPort = 8000;
  // This will be updated with the detected IP (or remain as fallback)
  static String serverIP = fallbackIP;

  // API URL builders
  static String get diagnoseURL => "http://$serverIP:$serverPort/diagnose";
  static String get allSymptomsURL => "http://$serverIP:$serverPort/debug/all-symptoms";
  static String getKnowledgeDetailsURL(String illness) =>
      "http://$serverIP:$serverPort/debug/knowledge-details?illness=${Uri.encodeComponent(illness)}";

  // Detect the correct server IP by scanning available interfaces
  static Future<void> detectServerIP() async {
    try {
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 &&
              addr.address.startsWith("192.")) {
            serverIP = addr.address;
            print("✅ Detected Server IP: $serverIP");
            return;
          }
        }
      }
    } catch (e) {
      print("⚠️ Error detecting IP: $e");
    }
    // If auto-detection fails, use the fallback
    serverIP = fallbackIP;
    print("⚠️ Using fallback IP: $serverIP");
  }
}
