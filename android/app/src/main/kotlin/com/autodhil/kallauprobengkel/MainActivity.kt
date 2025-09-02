package com.autodhil.kallauprobengkel

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Build
import android.os.Bundle
import android.view.View
// removed ambiguous import of android.webkit.WebView; use fully-qualified name where needed
import android.Manifest
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import android.content.Intent
import android.net.Uri
import android.util.Base64
import android.database.Cursor
import android.webkit.MimeTypeMap
import java.io.InputStream
import android.os.Environment
import android.provider.MediaStore
import android.webkit.ValueCallback
import android.webkit.WebChromeClient
import java.io.File
import java.io.IOException
import java.text.SimpleDateFormat
import java.util.Date

class MainActivity : FlutterActivity() {
    private val CAMERA_PERMISSION_REQUEST_CODE = 1001
    private val CHANNEL = "webview_permissions"
    private val FILE_CHANNEL = "file_chooser"
    private val FILE_CHOOSER_REQUEST_CODE = 1002
    private var uploadMessage: ValueCallback<Array<Uri>>? = null
    private var cameraImageUri: Uri? = null
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestAllPermissions" -> {
                    requestCameraPermission()
                    result.success("All permissions requested")
                }
                "enableWebViewDebugging" -> {
                    android.webkit.WebView.setWebContentsDebuggingEnabled(true)
                    result.success("WebView debugging enabled")
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, FILE_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "showFileChooser" -> {
                    // Store a pending result to complete after onActivityResult
                    pendingFlutterResult = result
                    // The Flutter side expects the file chooser to return URIs
                    openFileChooser()
                }
                else -> result.notImplemented()
            }
        }
    }

    // Hold pending flutter result for file chooser
    private var pendingFlutterResult: MethodChannel.Result? = null
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Enable WebView debugging for development
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            android.webkit.WebView.setWebContentsDebuggingEnabled(true)
        }
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            window.setDecorFitsSystemWindows(true)
        } else {
            @Suppress("DEPRECATION")
            window.decorView.systemUiVisibility = View.SYSTEM_UI_FLAG_VISIBLE
        }
        
        // Request camera permissions
        requestCameraPermission()
    // Setup a WebChromeClient on the Flutter WebView (if available) to handle file chooser.
    // Note: Flutter's WebView implementations may create their own WebView instances; this best-effort
    // approach will work for native WebView usages. If using the hybrid composition of flutter_inappwebview
    // it will handle file chooser itself; MainActivity handler is a fallback.
    }
    
    private fun requestCameraPermission() {
        val permissions = arrayOf(
            Manifest.permission.CAMERA,
            Manifest.permission.RECORD_AUDIO,
            Manifest.permission.MODIFY_AUDIO_SETTINGS,
            Manifest.permission.ACCESS_FINE_LOCATION,
            Manifest.permission.ACCESS_COARSE_LOCATION,
            Manifest.permission.READ_EXTERNAL_STORAGE,
            Manifest.permission.WRITE_EXTERNAL_STORAGE
        )
        
        val permissionsToRequest = permissions.filter {
            ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
        }
        
        if (permissionsToRequest.isNotEmpty()) {
            ActivityCompat.requestPermissions(
                this,
                permissionsToRequest.toTypedArray(),
                CAMERA_PERMISSION_REQUEST_CODE
            )
        }
    }
    
    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        
        when (requestCode) {
            CAMERA_PERMISSION_REQUEST_CODE -> {
                permissions.forEachIndexed { index, permission ->
                    val granted = grantResults.getOrNull(index) == PackageManager.PERMISSION_GRANTED
                    println("🔥 Permission $permission: ${if (granted) "GRANTED" else "DENIED"}")
                }
            }
        }
    }

    // Create image file for camera capture
    @Throws(IOException::class)
    private fun createImageFile(): File {
        val timeStamp: String = SimpleDateFormat("yyyyMMdd_HHmmss").format(Date())
        val storageDir: File? = getExternalFilesDir(Environment.DIRECTORY_PICTURES)
        return File.createTempFile(
            "JPEG_${timeStamp}_",
            ".jpg",
            storageDir
        )
    }

    // Handle results from file chooser / camera intents
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == FILE_CHOOSER_REQUEST_CODE) {
            if (uploadMessage == null) return

            val results: Array<Uri>? = when {
                resultCode != RESULT_OK -> null
                data == null -> {
                    // If there's no data, but we have a cameraImageUri, return it
                    cameraImageUri?.let { arrayOf(it) }
                }
                else -> {
                    // Get picked URIs
                    val clipData = data.clipData
                    if (clipData != null) {
                        val uris = Array(clipData.itemCount) { i -> clipData.getItemAt(i).uri }
                        uris
                    } else {
                        data.data?.let { arrayOf(it) }
                    }
                }
            }

            uploadMessage?.onReceiveValue(results ?: arrayOf())
            uploadMessage = null
            cameraImageUri = null

            // Also complete any pending Flutter MethodChannel result
            if (pendingFlutterResult != null) {
                try {
                    val list = mutableListOf<Map<String, String>>()
                    results?.forEach { uri ->
                        try {
                            val mime = contentResolver.getType(uri) ?: "image/*"
                            // get display name
                            var name = uri.lastPathSegment ?: "file"
                            // try to query display name for content://
                            if (uri.scheme == "content") {
                                val cursor: Cursor? = contentResolver.query(uri, null, null, null, null)
                                cursor?.use {
                                    val idx = it.getColumnIndex(android.provider.OpenableColumns.DISPLAY_NAME)
                                    if (idx != -1 && it.moveToFirst()) {
                                        name = it.getString(idx)
                                    }
                                }
                            }
                            val inputStream: InputStream? = contentResolver.openInputStream(uri)
                            val bytes = inputStream?.readBytes()
                            inputStream?.close()
                            if (bytes != null) {
                                val encoded = Base64.encodeToString(bytes, Base64.NO_WRAP)
                                list.add(mapOf("name" to name, "mime" to mime, "data" to encoded))
                            }
                        } catch (e: Exception) {
                            // skip item on error
                        }
                    }
                    pendingFlutterResult?.success(list)
                } catch (e: Exception) {
                    pendingFlutterResult?.error("error", e.message, null)
                } finally {
                    pendingFlutterResult = null
                }
            }
        }
    }

    // Expose a method the WebView can call to open a chooser. We add this to the activity so native WebView clients can use it.
    fun openFileChooser() {
        // Prepare camera intent
        val takePictureIntent = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
        var photoFile: File? = null
        try {
            photoFile = createImageFile()
            cameraImageUri = Uri.fromFile(photoFile)
            takePictureIntent.putExtra(MediaStore.EXTRA_OUTPUT, cameraImageUri)
        } catch (ex: IOException) {
            photoFile = null
            cameraImageUri = null
        }

        val contentSelectionIntent = Intent(Intent.ACTION_GET_CONTENT)
        contentSelectionIntent.addCategory(Intent.CATEGORY_OPENABLE)
        contentSelectionIntent.type = "image/*"

        val intentArray: Array<Intent> = if (photoFile != null) arrayOf(takePictureIntent) else arrayOf()

        val chooserIntent = Intent(Intent.ACTION_CHOOSER)
        chooserIntent.putExtra(Intent.EXTRA_INTENT, contentSelectionIntent)
        chooserIntent.putExtra(Intent.EXTRA_TITLE, "Select or take a photo")
        chooserIntent.putExtra(Intent.EXTRA_INITIAL_INTENTS, intentArray)

        startActivityForResult(chooserIntent, FILE_CHOOSER_REQUEST_CODE)
    }

    // This method will be called by WebChromeClient when file chooser is requested
    fun setUploadMessage(callback: ValueCallback<Array<Uri>>) {
        this.uploadMessage = callback
    }
}