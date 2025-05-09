
class AppConfig {
  static const String fallbackIP = "petsympbackend.onrender.com";

  static String serverIP = fallbackIP;

  static String get diagnoseURL =>
      "https://$serverIP/diagnose";

  static String get oTPURL =>
      "https://$serverIP/send-otp";

  static String get resetPassURL =>
      "https://$serverIP/reset-password";

  /// ❗ No pet type inside URL, only query parameters
  static String getAllSymptomsURL(String petType) {
    final encType = Uri.encodeComponent(petType);
    return "https://$serverIP/debug/all-symptoms?pet_type=$encType";
  }

  static String getKnowledgeDetailsURL(String petType, String illness) {
    final encType = Uri.encodeComponent(petType);
    final encIll = Uri.encodeComponent(illness);
    return "https://$serverIP/debug/knowledge-details?pet_type=$encType&illness=$encIll";
  }

  static String getMetricsWithCmURL(String petType, String illness) {
    final encType = Uri.encodeComponent(petType);
    final encIll = Uri.encodeComponent(illness);
    return "https://$serverIP/metrics-with-cm/$encIll?pet_type=$encType";
  }

  static String getMetricsURL(String petType, String illness) {
    final encType = Uri.encodeComponent(petType);
    final encIll = Uri.encodeComponent(illness);
    return "https://$serverIP/metrics/$encIll?pet_type=$encType";
  }

  /// Always use the Render backend
  static Future<void> detectServerIP() async {
    serverIP = fallbackIP;
    print("🌐 Using Render backend: $serverIP");
  }
}