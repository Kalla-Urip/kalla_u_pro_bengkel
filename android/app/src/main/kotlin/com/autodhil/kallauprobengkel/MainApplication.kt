package com.autodhil.kallauprobengkel

import io.flutter.app.FlutterApplication
import android.webkit.WebView

class MainApplication : FlutterApplication() {
    override fun onCreate() {
        super.onCreate()
        
        // Enable WebView debugging
        WebView.setWebContentsDebuggingEnabled(true)
    }
}
