import 'package:flutter/material.dart';
import 'package:kalla_u_pro_bengkel/common/app_colors.dart';
import 'package:kalla_u_pro_bengkel/common/app_text_styles.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class CustomBarcodeScreen extends StatefulWidget {
  const CustomBarcodeScreen({super.key});

  @override
  State<CustomBarcodeScreen> createState() => _CustomBarcodeScreenState();
}

class _CustomBarcodeScreenState extends State<CustomBarcodeScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  bool _isProcessing = false;

  // Simple validation for Toyota Vehicle Identification Number (VIN)
  // A real VIN is 17 characters long.
  // This is a basic check. A more robust validation might involve regex or a checksum algorithm.
  bool _isValidFrameNumber(String code) {
    // For now, we'll just check if it's not empty and has a reasonable length.
    return code.isNotEmpty && code.length > 8 && code.length < 20;
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      backgroundColor: AppColors.primary,
        leadingWidth: 21,
        title: const Text('Scan QR Mobil', style: AppTextStyles.subtitle2),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              if (_isProcessing) return;

              final String? code = capture.barcodes.first.rawValue;

              if (code != null) {
                setState(() {
                  _isProcessing = true;
                });

                // Validate the scanned code
                if (_isValidFrameNumber(code)) {
                  // If valid, pop the screen and return the code
                  Navigator.pop(context, code);
                } else {
                  // If not valid, show a snackbar and resume scanning
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bukan format No. Rangka yang valid.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  // Resume scanning after a short delay
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) {
                      setState(() {
                        _isProcessing = false;
                      });
                    }
                  });
                }
              }
            },
          ),
          // Custom overlay UI
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Arahkan kamera ke QR Code',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}