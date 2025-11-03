import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({Key? key}) : super(key: key);

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  String? qrCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.red.shade700,
      ),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    setState(() {
                      qrCode = barcode.rawValue!;
                    });
                    // Once scanned, you can pop or handle the value
                    Navigator.pop(context, qrCode);
                    break; // stop after first QR code
                  }
                }
              },
            ),
          ),
          if (qrCode != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Scanned: $qrCode',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}
