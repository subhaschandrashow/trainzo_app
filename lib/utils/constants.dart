// lib/utils/constants.dart

class Constants {
  // 🌐 Root Website URL
  static const String rootUrl = "https://app.trainzo.fit";
  // 🌐 Base API URL
  static const String apiBaseUrl = "$rootUrl/api";

  // Endpoints
  static const String loginUrl = "$apiBaseUrl/login.php";
  static const String registerUrl = "$apiBaseUrl/register.php";
  static const String gymListUrl = "$apiBaseUrl/gym.php";

  // App constants
  static const String appName = "Gym Management";
  static const String appVersion = "1.0.0";
}
