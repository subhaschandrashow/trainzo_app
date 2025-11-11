import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const String currentVersion = '1.0.0'; // 🔹 Change this in each release

  @override
  void initState() {
    super.initState();
    _checkForUpdate(); // 👈 Run version check first
  }

  /// 🔍 Check for new app version from your server
  Future<void> _checkForUpdate() async {
    try {
      final response = await http.get(Uri.parse('https://app.trainzo.fit/api/app_version.php'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latestVersion = data['version']?.toString() ?? currentVersion;

        if (latestVersion != currentVersion) {
          _showUpdateDialog(data['download_url']);
          return; // stop navigation until user updates
        }
      }
    } catch (e) {
      debugPrint('⚠️ Version check failed: $e');
    }

    // If no update or check fails → continue normal login check
    _checkLogin();
  }

  /// 🚀 Force update dialog
  void _showUpdateDialog(String url) {
    double progress = 0.0;
    bool isDownloading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> startDownload() async {
              try {
                setState(() {
                  isDownloading = true;
                  progress = 0;
                });

                // Get a safe local directory
                Directory tempDir = await getExternalStorageDirectory() ??
                    await getApplicationDocumentsDirectory();
                String savePath = "${tempDir.path}/trainzo_update.apk";

                Dio dio = Dio();

                await dio.download(
                  url,
                  savePath,
                  onReceiveProgress: (count, total) {
                    setState(() {
                      progress = count / total;
                    });
                  },
                );

                setState(() {
                  isDownloading = false;
                });

                // ✅ Automatically open the APK file
                await OpenFilex.open(savePath);
              } catch (e) {
                setState(() {
                  isDownloading = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Download failed: $e')),
                );
              }
            }

            return AlertDialog(
              title: const Text('Update Available'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isDownloading)
                    Column(
                      children: [
                        LinearProgressIndicator(value: progress),
                        const SizedBox(height: 8),
                        Text("${(progress * 100).toStringAsFixed(0)}%"),
                      ],
                    )
                  else
                    const Text('A new version is available. Tap below to update.'),
                ],
              ),
              actions: [
                if (!isDownloading)
                  TextButton(
                    onPressed: startDownload,
                    child: const Text('Update Now'),
                  ),
              ],
            );
          },
        );
      },
    );
  }


  /// 👤 Check if user is logged in
  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    Map<String, dynamic>? user;
    if (isLoggedIn) {
      user = {
        'id': prefs.getString('userId'),
        'name': prefs.getString('name'),
        'email': prefs.getString('email'),
        'role': prefs.getString('role'),
      };
    }

    // Wait for splash effect
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    // Navigate to Dashboard or Login
    if (isLoggedIn && user != null) {
      Navigator.pushReplacement(
        context,
       MaterialPageRoute(builder: (_) => DashboardScreen(user: user!)),

      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.fitness_center, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'Gym Management Demo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
