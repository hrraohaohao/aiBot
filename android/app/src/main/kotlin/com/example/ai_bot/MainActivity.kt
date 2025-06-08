package com.example.ai_bot

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import androidx.multidex.MultiDex
import android.content.Context

class MainActivity: FlutterActivity() {
    override fun attachBaseContext(base: Context) {
        super.attachBaseContext(base)
        MultiDex.install(this)
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }
}
