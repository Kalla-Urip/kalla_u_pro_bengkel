import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';
import 'package:kalla_u_pro_bengkel/common/app_colors.dart';
import 'package:kalla_u_pro_bengkel/common/app_text_styles.dart';

class InAppWebViewScreen extends StatefulWidget {
  final String url;
  const InAppWebViewScreen({Key? key, required this.url}) : super(key: key);

  @override
  State<InAppWebViewScreen> createState() => _InAppWebViewScreenState();
}

class _InAppWebViewScreenState extends State<InAppWebViewScreen> {
  InAppWebViewController? _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      InAppWebViewController.setWebContentsDebuggingEnabled(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'WAC AI Method',
          style: AppTextStyles.subtitle2,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller?.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(widget.url)),
              initialSettings:  InAppWebViewSettings(
                javaScriptEnabled: true,
                javaScriptCanOpenWindowsAutomatically: true,
                allowsInlineMediaPlayback: true,
                mediaPlaybackRequiresUserGesture: false,
                // PENTING: tidak ada JS interception apa pun
              ),
              onWebViewCreated: (c) => _controller = c,

              // Opsional debugging log JS
              // onConsoleMessage: (c, m) => debugPrint('[WV] ${m.message}'),

              onLoadStart: (c, u) => setState(() => _isLoading = true),
              onLoadStop: (c, u) => setState(() => _isLoading = false),
              onLoadError: (c, u, code, msg) => setState(() => _isLoading = false),

              // Izinkan kamera/mic saat halaman pakai getUserMedia (opsional)
              onPermissionRequest: (c, req) async => PermissionResponse(
                resources: req.resources,
                action: PermissionResponseAction.GRANT,
              ),
            ),
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
