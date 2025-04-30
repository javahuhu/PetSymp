class AppConfig {
  static const String fallbackIP = "10.0.2.2:8000"; // Localhost for emulator

  static String serverIP = fallbackIP;

  static String get diagnoseURL => "http://$serverIP/diagnose";
  static String get oTPURL => "http://$serverIP/send-otp";
  static String get resetPassURL => "http://$serverIP/reset-password";

  static String getAllSymptomsURL(String petType) {
    final encType = Uri.encodeComponent(petType);
    return "http://$serverIP/debug/all-symptoms?pet_type=$encType";
  }

  static String getKnowledgeDetailsURL(String petType, String illness) {
    final encType = Uri.encodeComponent(petType);
    final encIll = Uri.encodeComponent(illness);
    return "http://$serverIP/debug/knowledge-details?pet_type=$encType&illness=$encIll";
  }

  static String getMetricsWithCmURL(String petType, String illness) {
    final encType = Uri.encodeComponent(petType);
    final encIll = Uri.encodeComponent(illness);
    return "http://$serverIP/metrics-with-cm/$encIll?pet_type=$encType";
  }

  static String getMetricsURL(String petType, String illness) {
    final encType = Uri.encodeComponent(petType);
    final encIll = Uri.encodeComponent(illness);
    return "http://$serverIP/metrics/$encIll?pet_type=$encType";
  }

  static Future<void> detectServerIP() async {
    serverIP = fallbackIP;
    print("🌐 Using Localhost backend: $serverIP");
  }
}
