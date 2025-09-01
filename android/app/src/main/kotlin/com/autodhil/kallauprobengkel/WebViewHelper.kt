package com.autodhil.kallauprobengkel

import android.app.Activity
import android.webkit.WebSettings
import android.webkit.WebView
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

class WebViewHelper : MethodCallHandler {
    
    companion object {
        fun setupWebViewForCamera(webView: WebView, activity: Activity) {
            // Set custom WebChromeClient for permission handling
            webView.webChromeClient = CustomWebChromeClient(activity)
            
            // Configure WebView settings for camera access
            val settings = webView.settings
            settings.javaScriptEnabled = true
            settings.domStorageEnabled = true
            settings.databaseEnabled = true
            settings.cacheMode = WebSettings.LOAD_DEFAULT
            settings.mediaPlaybackRequiresUserGesture = false
            settings.allowFileAccess = true
            settings.allowContentAccess = true
            settings.allowFileAccessFromFileURLs = true
            settings.allowUniversalAccessFromFileURLs = true
            
            // Enable mixed content for HTTPS sites
            settings.mixedContentMode = WebSettings.MIXED_CONTENT_ALWAYS_ALLOW
            
            println("WebView configured for camera access")
        }
    }
    
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "setupWebViewForCamera" -> {
                // This can be called from Flutter if needed
                result.success("WebView camera setup completed")
            }
            else -> {
                result.notImplemented()
            }
        }
    }
}
