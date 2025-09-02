import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
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
  // production: no debug banners

  @override
  void initState() {
    super.initState();
    _ensurePermissions();
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      InAppWebViewController.setWebContentsDebuggingEnabled(true);
    }
  }

  Future<void> _ensurePermissions() async {
    final cam = await Permission.camera.status;
    final mic = await Permission.microphone.status;

    if (cam.isGranted && mic.isGranted) {
      return;
    }

  await [Permission.camera, Permission.microphone].request();
  }

  // Inject helper that will convert base64 data to File objects and assign them to input element
  Future<void> _injectSetFilesHelper(InAppWebViewController controller) async {
    const helper = '''(function(){
      if(window.flutterSetFiles) return;
      window.flutterSetFiles = async function(elementId, files){
        try{
          // find target input: by id if provided, otherwise try activeElement or first visible file input
          let input = null;
          if(elementId){
            input = document.getElementById(elementId) || null;
          }
          if(!input){
            try{ if(document.activeElement && document.activeElement.tagName.toLowerCase()==='input' && document.activeElement.type==='file') input = document.activeElement; }catch(e){}
          }
          if(!input){
            // try visible inputs
            const list = Array.from(document.querySelectorAll('input[type=file]'));
            if(list.length>0){
              // prefer inputs that are visible/enabled
              input = list.find(i=>!i.disabled && i.offsetParent!==null) || list[0];
            }
          }
          if(!input) return false;
          const dt = new DataTransfer();
          for(const f of files){
            const res = await fetch('data:' + f.mime + ';base64,' + f.data);
            const blob = await res.blob();
            const file = new File([blob], f.name, { type: f.mime });
            dt.items.add(file);
          }
          input.files = dt.files;
          const ev = new Event('change', { bubbles: true });
          input.dispatchEvent(ev);
          return true;
        }catch(e){ console.error('flutterSetFiles error', e); return false; }
  }

      function ensureId(el){
        if(el.id) return el.id;
        const id = 'flutter-file-input-' + Date.now() + '-' + Math.floor(Math.random()*10000);
        el.id = id;
        return id;
      }

      function interceptInput(el){
        try{
          if(el._flutterIntercept) return;
          el._flutterIntercept = true;
          const id = ensureId(el);
          el.addEventListener('click', function(e){
            console.log('[flutter_inappwebview] file input clicked', id, el.multiple, el.accept);
            e.preventDefault();
            try{
              if(window.flutter_inappwebview && window.flutter_inappwebview.callHandler){
                window.flutter_inappwebview.callHandler('pickFile', { id: id, multiple: el.multiple, accept: el.accept || '' });
              } else {
                console.log('[flutter_inappwebview] callHandler not available');
              }
            }catch(err){ console.error('[flutter_inappwebview] pickFile call error', err); }
          });

          el.addEventListener('change', function(e){
            console.log('[flutter_inappwebview] input change event', id, el.files && el.files.length);
          });
        }catch(e){ console.error('[flutter_inappwebview] interceptInput error', e); }
      }

      function attachInterceptors(){
        try{
          const inputs = document.querySelectorAll('input[type=file]');
          inputs.forEach(interceptInput);
          const labels = document.querySelectorAll('label[for]');
          labels.forEach(function(lbl){
            try{
              const forId = lbl.getAttribute('for');
              const el = document.getElementById(forId);
              if(el && el.type==='file' && !lbl._flutterIntercept){
                lbl._flutterIntercept = true;
                lbl.addEventListener('click', function(e){
                  e.preventDefault();
                  console.log('[flutter_inappwebview] label click for', forId);
                  if(window.flutter_inappwebview && window.flutter_inappwebview.callHandler){
                    window.flutter_inappwebview.callHandler('pickFile', { id: forId, multiple: el.multiple, accept: el.accept || '' });
                  }
                });
              }
            }catch(e){}
          });
        }catch(e){ console.error('[flutter_inappwebview] attachInterceptors error', e); }
      }

      // forward basic click info to Flutter for debugging
      try{
        if(!window._flutter_click_forwarder){
          window._flutter_click_forwarder = true;
          document.addEventListener('click', function(e){
            try{
              const t = e.target || e.srcElement;
              const info = { tag: t.tagName, id: t.id || '', classes: t.className || '', name: t.name || '' };
              if(window.flutter_inappwebview && window.flutter_inappwebview.callHandler){
                window.flutter_inappwebview.callHandler('clickEvent', info);
              }
            }catch(err){ }
          }, true);
        }
      }catch(e){}

      (function(){
        try{
          const orig = HTMLInputElement.prototype.click;
          HTMLInputElement.prototype.click = function(){
            try{
              if(this.type==='file'){
                const id = ensureId(this);
                console.log('[flutter_inappwebview] programmatic click intercepted', id);
                if(window.flutter_inappwebview && window.flutter_inappwebview.callHandler){
                  window.flutter_inappwebview.callHandler('pickFile', { id: id, multiple: this.multiple, accept: this.accept || '' });
                  return;
                }
              }
            }catch(e){ console.error(e); }
            return orig.apply(this, arguments);
          };
        }catch(e){}
      })();

      attachInterceptors();
      document.addEventListener('DOMContentLoaded', attachInterceptors);

      try{
        const mo = new MutationObserver(function(muts){ attachInterceptors(); });
        mo.observe(document.documentElement || document.body, { childList: true, subtree: true });
      }catch(e){}

    })();''';

    try {
      await controller.evaluateJavascript(source: helper);
    } catch (e) {
      // ignore
    }
  }

  Future<void> _pickAndInjectFiles([String elementId = '']) async {
    if (_controller == null) return;

    try {
      List<Map<String, dynamic>> files = [];
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        const channel = MethodChannel('file_chooser');
        final res = await channel.invokeMethod('showFileChooser');
        if (res == null) return;
        // res expected to be List<Map<String, String>> with keys name,mime,data
        for (final item in (res as List)) {
          files.add({
            'name': item['name'] ?? 'file',
            'mime': item['mime'] ?? 'image/*',
            'data': item['data'] ?? ''
          });
        }
      } else {
        final result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.image,
        );
        if (result == null) return;

        for (final p in result.paths.whereType<String>()) {
          final f = File(p);
          final bytes = await f.readAsBytes();
          final base64Data = base64Encode(bytes);
          final name = p.split('/').last;
          final mime = 'image/' + (name.split('.').last.toLowerCase());
          files.add({'name': name, 'mime': mime, 'data': base64Data});
        }
      }

  final jsonStr = jsonEncode(files);
  final js = "window.flutterSetFiles('$elementId', $jsonStr)";
  final res = await _controller?.evaluateJavascript(source: js);
      print('setFiles result: $res');
      // If helper returned false, try fallback without elementId to let helper auto-find an input
      if(res == false){
        try{
          final js2 = "window.flutterSetFiles('', $jsonStr)";
          final res2 = await _controller?.evaluateJavascript(source: js2);
          print('setFiles fallback result: $res2');
        }catch(e){ print('setFiles fallback error: $e'); }
      }
    } catch (e) {
      print('upload photo error: $e');
    }
  }

  // removed debug probe timer for production

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
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _controller?.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(widget.url)),
      
              initialSettings: InAppWebViewSettings(
                // cross-platform settings
                javaScriptEnabled: true,
                useShouldOverrideUrlLoading: true,
                mediaPlaybackRequiresUserGesture: false,
                javaScriptCanOpenWindowsAutomatically: true,
                // Note: Android-specific legacy options (e.g. useHybridComposition,
                // thirdPartyCookiesEnabled) were removed to avoid deprecated types.
              ),
              onWebViewCreated: (controller) {
                _controller = controller;
                try {
                  controller.addJavaScriptHandler(
                    handlerName: 'pickFile',
                    callback: (args) async {
                        String elementId = 'fileupload';
                        try{
                          if(args.isNotEmpty){
                            final first = args[0];
                            if(first is Map){
                              elementId = first['id']?.toString() ?? elementId;
                            } else if(first is String){
                              elementId = first;
                            }
                          }
                        }catch(e){ }
                        print('[InAppWebView] pickFile handler invoked from JS: args=$args target=$elementId');
                        await _pickAndInjectFiles(elementId);
                        print('[InAppWebView] pickFile handler completed for $elementId');
                        return true;
                    },
                  );
                  // production: no clickEvent debug handler
                } catch (e) {
                  print('[InAppWebView] addJavaScriptHandler error: $e');
                }
                // attempt to inject helper immediately in case onLoadStop timing misses
                try{
                  _injectSetFilesHelper(controller);
                }catch(e){ print('[dart_inapp] early inject error $e'); }
              },
              onLoadStart: (controller, url) {
                setState(() => _isLoading = true);
              },
              onLoadStop: (controller, url) async {
                setState(() => _isLoading = false);
                await _injectSetFilesHelper(controller);
                // production: injected helper attempted (silent)
              },
              // keep minimal handlers; avoid verbose console forwarding in production
              onPermissionRequest: (controller, request) async {
                print('InAppWebView permission request from: ${request.origin}');
                return PermissionResponse(
                  resources: request.resources,
                  action: PermissionResponseAction.GRANT,
                );
              },
              onReceivedError: (controller, request, error) {
                // updated API: handle load errors here
                setState(() => _isLoading = false);
              },
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          // production UI
        ],
      ),
                           // Removed deprecated initialOptions block
    );
  }

}
