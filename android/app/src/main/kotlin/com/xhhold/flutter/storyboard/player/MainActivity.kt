package com.xhhold.flutter.storyboard.player

import android.os.Bundle
import com.xhhold.flutter.storyboard.player.plugin.MediaPlugin

import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {

    private fun registerCustomPlugin() {
        MediaPlugin.registerWith(this.registrarFor(MediaPlugin::class.java.canonicalName))
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)
        registerCustomPlugin()
    }
}
