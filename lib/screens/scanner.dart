import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'webview/webview_screen.dart'; // your WebViewPage class

class ScannerPage extends StatefulWidget {
  const ScannerPage({Key? key}) : super(key: key);

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  bool isProcessing = false;

  Future<void> _handleDetection(BarcodeCapture capture) async {
    final barcode = capture.barcodes.first;
    final String? code = barcode.rawValue;

    if (code == null || isProcessing) return; // avoid multiple scans

    setState(() => isProcessing = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionId = prefs.getString('sessionId') ?? '';

      // Append session_id if missing
      String scanUrl = code;
      if (!scanUrl.contains('session_id=')) {
        final separator = scanUrl.contains('?') ? '&' : '?';
        scanUrl = '$scanUrl${separator}session_id=$sessionId&from_app=1';
      }

      // Call the scanned URL
      final response = await http.get(Uri.parse(scanUrl));

      if (response.statusCode == 200 &&
          response.headers['content-type']?.contains('application/json') == true) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _showSnack('✅ Attendance marked successfully!');
        } else {
          _showSnack('⚠️ ${data['message'] ?? 'Action failed'}');
        }
      } else {
        _showSnack('QR processed successfully');
      }

      // ✅ Redirect to homepage after scan
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => WebViewPage(
            title: 'Home',
            url: 'https://demo.trainzo.fit/index.php?session_id=$sessionId&from_app=1',
            sessionId: sessionId,
          ),
        ),
      );
    } catch (e) {
      _showSnack('Error: $e');
    } finally {
      setState(() => isProcessing = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.red.shade700,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: MobileScannerController(
              detectionSpeed: DetectionSpeed.noDuplicates,
            ),
            onDetect: _handleDetection,
          ),
          if (isProcessing)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
