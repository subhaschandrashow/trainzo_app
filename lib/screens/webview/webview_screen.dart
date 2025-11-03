import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/constants.dart';

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
        'FlutterUpload', // JS channel name
        onMessageReceived: (message) async {
          // Expecting message: "pick_image"
          if (message.message == 'pick_image') {
            await _pickImageAndSendToWeb();
          }
        },
      )
      ..loadRequest(Uri.parse(finalUrl));
  }

  Future<void> _pickImageAndSendToWeb() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Send the base64 string back to the WebView
      final js = """
        (function() {
          const input = document.querySelector('input[name="cover_img"]');
          if (input) {
            const blob = Uint8Array.from(atob('$base64Image'), c => c.charCodeAt(0));
            const file = new File([blob], '${image.name}');
            const dataTransfer = new DataTransfer();
            dataTransfer.items.add(file);
            input.files = dataTransfer.files;

            // Trigger change event
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
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: Colors.blueAccent,
        ),
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
