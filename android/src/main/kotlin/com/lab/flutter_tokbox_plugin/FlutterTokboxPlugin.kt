package com.lab.flutter_tokbox_plugin

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry.Registrar

const val PLUGIN_CHANNEL_KEY = "flutter_tokbox_plugin"
const val PLUGIN_VIEW_CHANNEL_KEY = "$PLUGIN_CHANNEL_KEY.view"

public class FlutterTokboxPlugin: FlutterPlugin, ActivityAware, MethodChannel.MethodCallHandler {
  private lateinit var channel : MethodChannel
  private var pluginBinding: FlutterPlugin.FlutterPluginBinding? = null

  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      println("@@@@@ FlutterTokboxPlugin.registerWith")
      //if (registrar.activity() == null) return
      registrar.platformViewRegistry()
              .registerViewFactory(PLUGIN_VIEW_CHANNEL_KEY,
                      TokboxViewFactory(registrar.messenger()))
    }
  }

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    println("@@@@@ FlutterTokboxPlugin.onAttachedToEngine")
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, PLUGIN_CHANNEL_KEY)
    channel.setMethodCallHandler(this)
    pluginBinding = flutterPluginBinding
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    println("@@@@@ FlutterTokboxPlugin.onDetachedFromEngine")
    channel.setMethodCallHandler(null)
    pluginBinding = null
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    println("@@@@@ FlutterTokboxPlugin.onAttachedToActivity")
    pluginBinding!!.platformViewRegistry
            .registerViewFactory(PLUGIN_VIEW_CHANNEL_KEY,
                    TokboxViewFactory(pluginBinding!!.binaryMessenger))
  }

  override fun onDetachedFromActivity() {
    println("@@@@@ FlutterTokboxPlugin.onDetachedFromActivity")
    this.onDetachedFromActivity()
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    println("@@@@@ FlutterTokboxPlugin.onReattachedToActivityForConfigChanges")
  }

  override fun onDetachedFromActivityForConfigChanges() {
    println("@@@@@ FlutterTokboxPlugin.onDetachedFromActivityForConfigChanges")
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    println("@@@@@ FlutterTokboxPlugin.onMethodCall: ${call.method} with args ${call.arguments}")
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else result.notImplemented()
  }

}