package com.lab.flutter_tokbox_plugin

import android.content.Context
import android.os.Handler
import android.view.View
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

class TokBoxPlatformView(private val context: Context,
                         messenger: BinaryMessenger, id: Int,
                         private val parameters: Map<String, String>)
                         : PlatformView, MethodChannel.MethodCallHandler, TokBoxCameraListener {

    private val tokboxView: TokBoxCameraView = TokBoxCameraView(context = context)
    private var callDisposeResult: MethodChannel.Result? = null

    init {
        MethodChannel(messenger, "$PLUGIN_VIEW_KEY#$id")
                .setMethodCallHandler(this)

        tokboxView.setListener(this)

        Handler().postDelayed({
            tokboxView.connect(
                    parameters.getValue("api_key"),
                    parameters.getValue("session_id"),
                    parameters.getValue("token"))
        }, 400)
    }

    override fun getView(): View = tokboxView

    override fun onMethodCall(methodCall: MethodCall, result: MethodChannel.Result) {
        when (methodCall.method) {
            "onCallDispose" -> callDisposeResult = result
            else -> result.notImplemented()
        }
    }

    override fun dispose() {
        tokboxView.disconnect()
        callDisposeResult?.success(null)
        callDisposeResult = null
    }

    override fun onDisconnect() {
        callDisposeResult?.success(null)
    }

}