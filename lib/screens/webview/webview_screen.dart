import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:image_picker/image_picker.dart';

class WebViewPage extends StatefulWidget {
  final String title;
  final String url;
  final String? sessionId; // Optional for shared login

  const WebViewPage({
    super.key,
    required this.title,
    required this.url,
    this.sessionId,
  });

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;
  bool isLoading = true;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    // ✅ Append session ID if provided
    String finalUrl = widget.url;
    if (widget.sessionId != null && widget.sessionId!.isNotEmpty) {
      final separator = finalUrl.contains('?') ? '&' : '?';
      finalUrl = '$finalUrl${separator}session_id=${widget.sessionId}&from_app=1';
    }

    // ✅ Initialize controller
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => isLoading = true),
          onPageFinished: (_) => setState(() => isLoading = false),
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
  }

  Future<void> _pickImageAndSendToWeb(String? inputId) async {
    // Ask user: camera or gallery
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
      _controller.runJavaScript(js);
    }
  }


  Future<bool> _onWillPop() async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (isLoading)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
