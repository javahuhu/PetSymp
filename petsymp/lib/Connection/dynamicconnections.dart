import 'dart:io';

class AppConfig {
  static const String fallbackIP = "192.168.1.101";
  static const int serverPort = 8000;

  static String serverIP = fallbackIP;

  static String get diagnoseURL =>
      "http://$serverIP:$serverPort/diagnose";

  static String get oTPURL =>
      "http://$serverIP:$serverPort/send-otp";

  static String get resetPassURL =>
      "http://$serverIP:$serverPort/reset-password";

  /// ❗ Correct: No pet type inside URL, only query parameters
  static String getAllSymptomsURL(String petType) {
    final encType = Uri.encodeComponent(petType);
    return "http://$serverIP:$serverPort/debug/all-symptoms?pet_type=$encType";
  }

  static String getKnowledgeDetailsURL(String petType, String illness) {
    final encType = Uri.encodeComponent(petType);
    final encIll = Uri.encodeComponent(illness);
    return "http://$serverIP:$serverPort/debug/knowledge-details?pet_type=$encType&illness=$encIll";
  }

  static String getMetricsWithCmURL(String petType, String illness) {
    final encType = Uri.encodeComponent(petType);
    final encIll = Uri.encodeComponent(illness);
    return "http://$serverIP:$serverPort/metrics-with-cm/$encIll?pet_type=$encType";
  }

  static String getMetricsURL(String petType, String illness) {
    final encType = Uri.encodeComponent(petType);
    final encIll = Uri.encodeComponent(illness);
    return "http://$serverIP:$serverPort/metrics/$encIll?pet_type=$encType";
  }

  static Future<void> detectServerIP() async {
    try {
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 &&
              addr.address.startsWith("192.")) {
            serverIP = addr.address;
            print("✅ Detected server IP: $serverIP");
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
