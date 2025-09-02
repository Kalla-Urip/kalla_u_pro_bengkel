import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:go_router/go_router.dart';
import 'package:kalla_u_pro_bengkel/common/app_colors.dart';
import 'package:kalla_u_pro_bengkel/common/app_text_styles.dart';
import 'inapp_webview_screen.dart';

class WebViewWacScreen extends StatefulWidget {
  const WebViewWacScreen({super.key});

  @override
  State<WebViewWacScreen> createState() => _WebViewWacScreenState();
}

class _WebViewWacScreenState extends State<WebViewWacScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    final params = PlatformWebViewControllerCreationParams();
    _controller = WebViewController.fromPlatformCreationParams(
      params,
      onPermissionRequest: (request) {
        // Debug log to confirm native permission callback is invoked
        try {
          print('WebView onPermissionRequest: ' + request.toString());
        } catch (e) {}

        // Grant all requested resources (camera/mic) for testing
        try {
          request.grant();
        } catch (e) {
          // ignore
        }
      },
    )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent('Mozilla/5.0 (Linux; Android 14; SM-G998B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36')
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            _setupJavaScriptChannel();
          },
        ),
      )
      ..loadRequest(Uri.parse('https://wac.kallaurip.pro/'));

    // Enable Android WebView debugging (like Chrome DevTools)
    if (_controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      final androidController = _controller.platform as AndroidWebViewController;
      androidController.setMediaPlaybackRequiresUserGesture(false);
    }
  }

  void _setupJavaScriptChannel() {
    _controller.addJavaScriptChannel(
      'ToFlutter',
      onMessageReceived: (JavaScriptMessage message) {
        if (message.message == 'Data berhasil dikirim') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data berhasil dikirim dari web!'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop(true);
        }
      },
    );
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
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _controller.reload(),
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new, color: Colors.white),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const InAppWebViewScreen(url: 'https://wac.kallaurip.pro/'),
            )),
            tooltip: 'Open InAppWebView (native) for camera test',
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(child: WebViewWidget(controller: _controller)),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ),
        ],
      ),
    );
  }
}
