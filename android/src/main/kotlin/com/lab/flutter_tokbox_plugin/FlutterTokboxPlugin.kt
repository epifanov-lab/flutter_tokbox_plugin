package com.lab.flutter_tokbox_plugin

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

const val PLUGIN_VIEW_KEY = "flutter_tokbox_plugin.view"

public class FlutterTokboxPlugin: FlutterPlugin {

  private var pluginBinding: FlutterPlugin.FlutterPluginBinding? = null

  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      if (registrar.activity() == null) return

      registrar.platformViewRegistry()
              .registerViewFactory(PLUGIN_VIEW_KEY, TokBoxViewFactory(registrar.messenger()))
    }
  }

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    pluginBinding = flutterPluginBinding
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    pluginBinding = null
  }

}

class TokBoxViewFactory(private val messenger: BinaryMessenger): PlatformViewFactory(StandardMessageCodec.INSTANCE) {
  override fun create(context: Context?, id: Int, args: Any?): PlatformView {
    val params = args as Map<String, String>
    return TokBoxPlatformView(context!!, messenger, id, params)
  }
}