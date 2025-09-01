package com.autodhil.kallauprobengkel

import android.webkit.PermissionRequest
import android.webkit.WebChromeClient
import android.webkit.WebView
import android.util.Log

class WebViewPermissionHelper : WebChromeClient() {
    
    override fun onPermissionRequest(request: PermissionRequest?) {
        Log.d("WebViewPermission", "🔥 Permission requested for: ${request?.origin}")
        Log.d("WebViewPermission", "🔥 Resources requested: ${request?.resources?.joinToString()}")
        
        // Always grant camera and microphone permissions
        request?.grant(request.resources)
        
        Log.d("WebViewPermission", "✅ Permissions granted automatically")
    }
    
    override fun onPermissionRequestCanceled(request: PermissionRequest?) {
        Log.d("WebViewPermission", "❌ Permission request cancelled for: ${request?.origin}")
        super.onPermissionRequestCanceled(request)
    }
    
    companion object {
        fun configureWebViewForCamera(webView: WebView) {
            Log.d("WebViewPermission", "🔧 Configuring WebView for camera access...")
            
            val settings = webView.settings
            settings.javaScriptEnabled = true
            settings.domStorageEnabled = true
            settings.mediaPlaybackRequiresUserGesture = false
            settings.allowFileAccess = true
            settings.allowContentAccess = true
            
            // Enable hardware acceleration
            settings.setRenderPriority(android.webkit.WebSettings.RenderPriority.HIGH)
            
            Log.d("WebViewPermission", "✅ WebView camera configuration completed")
        }
    }
}
