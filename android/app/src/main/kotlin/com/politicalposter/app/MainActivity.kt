package com.politicalposter.app

import android.content.ActivityNotFoundException
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent.getIntent

import android.os.Bundle
import android.content.ContentValues
import android.content.Intent
import android.database.ContentObserver
import android.media.RingtoneManager
import android.os.Handler
import android.provider.MediaStore
import android.util.Log


class MainActivity: FlutterActivity() {
    private val CHANNEL = "gpay_launcher"
    //private val reviewManager: ReviewManager? = null
    private var screenshotObserver: ContentObserver? = null


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->

            if (call.method == "startListening") {
                startScreenshotObserver()
                result.success("Listening started")
            } else if (call.method == "stopListening") {
                stopScreenshotObserver()
                result.success("Listening stopped")
            } else {
                result.notImplemented()
            }

            if (call.method == "launchGPay") {
                // launchReviewFlow();
                val url = call.argument<String>("url")
                val packageName = call.argument<String>("packageName")
                if (url != null) {

                    launchGPay(url,packageName.toString())
                    result.success(null)
                } else {
                    result.error("UNAVAILABLE", "URL not available.", null)
                }
            }else if(call.method == "whatsapp"){
                launchWhatsApp();
            } else {
                result.notImplemented()
            }
        }

        // Direct UPI (Alnico Direct UPI Standard). Its own channel — kept separate from the
        // gpay_launcher channel above so the two handlers cannot interfere.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, UpiBridge.CHANNEL)
            .setMethodCallHandler { call, result -> UpiBridge.handle(this, call, result) }
    }

    // REQUIRED. A UPI app returns its result through the Activity, not the SDK. Omit this
    // and payments silently never resolve — the user pays and the CTA stays disabled forever.
    @Deprecated("Activity.onActivityResult — required for the Razorpay CustomUI hand-off.")
    @Suppress("DEPRECATION")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        UpiBridge.forwardActivityResult(requestCode, resultCode, data)
    }

    private fun launchGPay(url: String, packagename : String) {
        val intent = Intent(Intent.ACTION_VIEW).apply {
            data = Uri.parse(url)
            `package` = packagename
            // `package` = "com.google.android.apps.nbu.paisa.user"
        }
        if (intent.resolveActivity(packageManager) != null) {
            startActivity(intent)
        } else {
            // Handle the case where Google Pay is not installed
        }
    }

    private fun launchWhatsApp() {
        val whatsappIntent = Intent(Intent.ACTION_SEND)
        whatsappIntent.setType("text/plain")
        whatsappIntent.setPackage("com.whatsapp")
        whatsappIntent.putExtra(Intent.EXTRA_TEXT, "The text you wanted to share")
        try {
            activity.startActivity(whatsappIntent)
        } catch (ex: ActivityNotFoundException) {
            //ToastHelper.MakeShortText("Whatsapp have not been installed.")
        }
    }

    //  private var manager: ReviewManager? = null
    // private lateinit var reviewInfo: ReviewInfo
//    private fun initRating() {
//        val request = manager?.requestReviewFlow()
//        request?.addOnCompleteListener { task ->
//            if (task.isSuccessful) {
//                // We got the ReviewInfo object
//                val reviewInfo = task.result
//            } else {
//                // There was some problem, log or handle the error code.
//                //  @ReviewErrorCode val reviewErrorCode = (task.getException() as ReviewException).errorCode
//            }
//        }
//
//    }

//    private fun launchReviewFlow() {
//        initRating()
//        val flow = manager?.launchReviewFlow(activity, reviewInfo)
//        flow?.addOnCompleteListener { _ ->
//            // The flow has finished. The API does not indicate whether the user
//            // reviewed or not, or even whether the review dialog was shown. Thus, no
//            // matter the result, we continue our app flow.
//        }
//    }



    private fun startScreenshotObserver() {
        val handler = Handler(mainLooper)
        screenshotObserver = object : ContentObserver(handler) {
            override fun onChange(selfChange: Boolean) {
                super.onChange(selfChange)
                // Notify Flutter about the screenshot attempt
                flutterEngine?.dartExecutor?.binaryMessenger?.let { MethodChannel(it, CHANNEL).invokeMethod("onScreenshot", null) }
            }
        }
        contentResolver.registerContentObserver(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, true, screenshotObserver!!)
    }

    private fun stopScreenshotObserver() {
        screenshotObserver?.let {
            contentResolver.unregisterContentObserver(it)
            screenshotObserver = null
        }
    }
    private fun setRingtoneFile(audioBytes: ByteArray?, title: String): Boolean {
        try {
            if (audioBytes == null) return false

            val fileName = "$title.mp3"

            val values = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
                put(MediaStore.MediaColumns.MIME_TYPE, "audio/mpeg")
                put(MediaStore.MediaColumns.RELATIVE_PATH, "Ringtones/")
                put(MediaStore.Audio.Media.IS_RINGTONE, true)
            }

            val uri = MediaStore.Audio.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
            val newUri = contentResolver.insert(uri, values)

            if (newUri != null) {
                contentResolver.openOutputStream(newUri)?.use { outputStream ->
                    outputStream.write(audioBytes)
                    outputStream.flush()
                }

                RingtoneManager.setActualDefaultRingtoneUri(this, RingtoneManager.TYPE_RINGTONE, newUri)
                return true
            } else {
                Log.e("MainActivity", "Failed to insert media")
            }
        } catch (e: Exception) {
            Log.e("MainActivity", "Exception while setting ringtone: ${e.message}")
            e.printStackTrace()
        }
        return false
    }
}