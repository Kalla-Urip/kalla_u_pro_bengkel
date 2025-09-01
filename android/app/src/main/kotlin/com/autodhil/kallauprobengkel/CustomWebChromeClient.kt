package com.autodhil.kallauprobengkel

import android.Manifest
import android.app.Activity
import android.content.pm.PackageManager
import android.webkit.PermissionRequest
import android.webkit.WebChromeClient
import android.webkit.WebView
import androidx.core.content.ContextCompat

class CustomWebChromeClient(private val activity: Activity) : WebChromeClient() {
    
    override fun onPermissionRequest(request: PermissionRequest) {
        // Check if we have camera permission
        val hasCameraPermission = ContextCompat.checkSelfPermission(
            activity, 
            Manifest.permission.CAMERA
        ) == PackageManager.PERMISSION_GRANTED
        
        val hasMicrophonePermission = ContextCompat.checkSelfPermission(
            activity, 
            Manifest.permission.RECORD_AUDIO
        ) == PackageManager.PERMISSION_GRANTED
        
        // Log the request
        println("WebView Permission Request - Resources: ${request.resources.joinToString()}")
        println("WebView Permission Request - Origin: ${request.origin}")
        
        // Grant permissions if we have them
        if (hasCameraPermission && hasMicrophonePermission) {
            println("Granting WebView camera and microphone permissions")
            request.grant(request.resources)
        } else {
            println("Denying WebView permissions - App permissions not granted")
            request.deny()
        }
    }
    
    override fun onPermissionRequestCanceled(request: PermissionRequest) {
        super.onPermissionRequestCanceled(request)
        println("WebView Permission Request Canceled")
    }
}
