package com.lab.flutter_tokbox_plugin

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

const val PLUGIN_CHANNEL_KEY = "flutter_tokbox_plugin"
const val PLUGIN_VIEW_CHANNEL_KEY = "$PLUGIN_CHANNEL_KEY.view"

public class FlutterTokboxPlugin: FlutterPlugin, MethodChannel.MethodCallHandler {
  private lateinit var channel : MethodChannel
  private var pluginBinding: FlutterPlugin.FlutterPluginBinding? = null

  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      if (registrar.activity() == null) return

      registrar.platformViewRegistry()
              .registerViewFactory(PLUGIN_VIEW_CHANNEL_KEY, TokboxViewFactory(registrar.messenger()))
    }
  }

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, PLUGIN_CHANNEL_KEY)
    channel.setMethodCallHandler(this)
    pluginBinding = flutterPluginBinding
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    pluginBinding = null
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else {
      result.notImplemented()
    }
  }

}

class TokboxViewFactory(private val messenger: BinaryMessenger): PlatformViewFactory(StandardMessageCodec.INSTANCE) {
  override fun create(context: Context?, id: Int, args: Any?): PlatformView {
    val params = args as Map<String, String>
    return TokboxPlatformView(context!!, messenger, id, params)
  }
}