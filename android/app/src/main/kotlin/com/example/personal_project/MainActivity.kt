package com.example.personal_project

import io.flutter.embedding.android.FlutterActivity
import android.media.MediaMetadataRetriever
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "audio_utils"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getAudioDuration") {
                val filePath = call.argument<String>("filePath")
                if (filePath != null) {
                    try {
                        val mmr = MediaMetadataRetriever()
                        mmr.setDataSource(filePath)
                        val durationStr = mmr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)
                        val duration = durationStr?.toInt() ?: 0
                        result.success(duration) // Duration in milliseconds
                    } catch (e: Exception) {
                        result.error("UNAVAILABLE", "Audio duration not available.", null)
                    }
                } else {
                    result.error("INVALID_ARGUMENT", "File path is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
