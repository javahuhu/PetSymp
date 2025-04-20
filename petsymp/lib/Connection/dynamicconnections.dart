// lib/dynamicconnections.dart
import 'dart:io';

class AppConfig {
  static const String fallbackIP = "192.168.1.101";
  static const int serverPort = 8000;
  static String serverIP = fallbackIP;

  static String get diagnoseURL =>
      "http://$serverIP:$serverPort/diagnose";

  static String get allSymptomsURL =>
      "http://$serverIP:$serverPort/debug/all-symptoms";

  static String get oTPURL =>
      "http://$serverIP:$serverPort/send-otp";

  static String get resetpass =>
      "http://$serverIP:$serverPort/reset-password";

  /// Existing endpoint (metrics without confusion‑matrix)
  static String getMetricsURL(String illness) {
    final encoded = Uri.encodeComponent(illness);
    return "http://$serverIP:$serverPort/metrics/$encoded";
  }

  /// **New** endpoint: returns both confusion matrix + metrics
  static String getMetricsWithCmURL(String illness) {
    final encoded = Uri.encodeComponent(illness);
    return "http://$serverIP:$serverPort/metrics-with-cm/$encoded";
  }

  static String getKnowledgeDetailsURL(String illness) =>
      "http://$serverIP:$serverPort/debug/knowledge-details?illness=${Uri.encodeComponent(illness)}";

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
    serverIP = fallbackIP;
    print("⚠️ Using fallback IP: $serverIP");
  }
}
