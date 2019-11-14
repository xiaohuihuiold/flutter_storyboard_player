package com.xhhold.flutter.storyboard.player.plugin

import android.media.MediaPlayer
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import java.util.concurrent.locks.Lock
import java.util.concurrent.locks.ReadWriteLock
import java.util.concurrent.locks.ReentrantLock

class MediaPlugin(private val registrar: PluginRegistry.Registrar, private val methodChannel: MethodChannel, private val eventChannel: EventChannel) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    companion object {
        @JvmStatic
        fun registerWith(registrar: PluginRegistry.Registrar) {
            val methodChannel = MethodChannel(registrar.messenger(), "com.xhhold.flutter.storyboard.player/method/media")
            val eventChannel = EventChannel(registrar.messenger(), "com.xhhold.flutter.storyboard.player/event/media")
            val instance = MediaPlugin(registrar, methodChannel, eventChannel)
            methodChannel.setMethodCallHandler(instance)
            eventChannel.setStreamHandler(instance)
        }
    }

    private var mediaPlayer: MediaPlayer? = null
    private var eventSink: EventChannel.EventSink? = null

    @Volatile
    var pause: Boolean = false

    init {
        Thread {
            while (true) {
                while (pause) {
                }
                if (eventSink != null && mediaPlayer?.isPlaying == true) {
                    registrar.activity().runOnUiThread {
                        eventSink?.success(mapOf("type" to 1, "time" to mediaPlayer?.currentPosition))
                    }
                }
                Thread.sleep(10)
            }
        }.start()
    }

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
                    mediaPlayer?.isLooping = true
                    mediaPlayer?.setDataSource(path)
                    mediaPlayer?.prepare()
                    mediaPlayer?.start()
                }
                pause = false
                result.success(null)
            }
            "pause" -> {
                mediaPlayer?.pause()
                pause = true
                result.success(null)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onListen(p0: Any?, eventSink: EventChannel.EventSink?) {
        this.eventSink = eventSink
    }

    override fun onCancel(p0: Any?) {
    }

}