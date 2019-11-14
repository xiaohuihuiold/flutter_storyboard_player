package com.xhhold.flutter.storyboard.player.plugin

import android.media.MediaPlayer
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

class MediaPlugin(private val methodChannel: MethodChannel, private val eventChannel: EventChannel) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    companion object {
        @JvmStatic
        fun registerWith(registrar: PluginRegistry.Registrar) {
            val methodChannel = MethodChannel(registrar.messenger(), "com.xhhold.flutter.storyboard.player/method/media")
            val eventChannel = EventChannel(registrar.messenger(), "com.xhhold.flutter.storyboard.player/event/media")
            val instance = MediaPlugin(methodChannel, eventChannel)
            methodChannel.setMethodCallHandler(instance)
            eventChannel.setStreamHandler(instance)
        }
    }

    var mediaPlayer: MediaPlayer? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "play" -> {
                val path = call.argument<String?>("path")
                if (path == null) {
                    mediaPlayer?.start()
                } else {
                    mediaPlayer?.stop()
                    mediaPlayer?.reset()
                    mediaPlayer?.release()
                    mediaPlayer = null
                    mediaPlayer = MediaPlayer()
                    mediaPlayer?.setDataSource(path)
                    mediaPlayer?.prepare()
                    mediaPlayer?.start()
                }
                result.success(null)
            }
            "pause" -> {
                mediaPlayer?.pause()
                result.success(null)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onListen(p0: Any?, eventSink: EventChannel.EventSink?) {
        Thread {
            while (true) {
                if (mediaPlayer?.isPlaying == true) {
                    eventSink?.success(mapOf("type" to 0, "time" to mediaPlayer?.currentPosition))
                }
                Thread.sleep(10)
            }
        }.start()
    }

    override fun onCancel(p0: Any?) {
    }

}