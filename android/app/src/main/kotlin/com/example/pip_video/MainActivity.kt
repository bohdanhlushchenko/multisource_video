package com.example.pip_video

import android.content.Intent
import androidx.annotation.NonNull;
import com.example.pip_video.BetterPlayerService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        startService(Intent(this, BetterPlayerService::class.java))
    }
}