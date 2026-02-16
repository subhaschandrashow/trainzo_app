import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WebViewPage extends StatefulWidget {
  final String title;
  final String url;

  const WebViewPage({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  WebViewController? _controller;
  bool isLoading = true;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    String finalUrl = widget.url;

    if (token != null && token.isNotEmpty) {
      final originalUri = Uri.parse(widget.url);

      final updatedRedirectUri = originalUri.replace(
        queryParameters: {
          ...originalUri.queryParameters,
          'from_app': '1',
        },
      );

      final mobileLoginUri = Uri(
        scheme: originalUri.scheme,
        host: originalUri.host,
        port: originalUri.hasPort ? originalUri.port : null,
        path: '/api/mobile_login.php',
        queryParameters: {
          'token': token,
          'redirect': updatedRedirectUri.toString(),
        },
      );

      finalUrl = mobileLoginUri.toString();
    }

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => isLoading = true);
          },
          onPageFinished: (url) {
            setState(() => isLoading = false);
          },
          onWebResourceError: (error) {
            setState(() => isLoading = false);
          },
        ),
      )
      ..addJavaScriptChannel(
        'FlutterUpload',
        onMessageReceived: (message) async {
          final parts = message.message.split(':');

          if (parts[0] == 'pick_image') {
            final inputId = parts.length > 1 ? parts[1] : null;
            await _pickImageAndSendToWeb(inputId);
          }
        },
      )
      ..loadRequest(Uri.parse(finalUrl));

    setState(() {
      _controller = controller;
    });
  }

  Future<void> _pickImageAndSendToWeb(String? inputId) async {
    if (_controller == null) return;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Capture Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      final js = """
      (function() {
        const input = document.getElementById('$inputId');
        if (input) {
          const byteCharacters = atob('$base64Image');
          const byteNumbers = new Array(byteCharacters.length);
          for (let i = 0; i < byteCharacters.length; i++) {
            byteNumbers[i] = byteCharacters.charCodeAt(i);
          }
          const byteArray = new Uint8Array(byteNumbers);

          const file = new File([byteArray], '${image.name}');
          const dataTransfer = new DataTransfer();
          dataTransfer.items.add(file);
          input.files = dataTransfer.files;

          const event = new Event('change', { bubbles: true });
          input.dispatchEvent(event);
        }
      })();
      """;

      _controller!.runJavaScript(js);
    }
  }

  Future<bool> _onWillPop() async {
    if (_controller != null && await _controller!.canGoBack()) {
      _controller!.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Stack(
          children: [
            WebViewWidget(controller: _controller!),
            if (isLoading)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
