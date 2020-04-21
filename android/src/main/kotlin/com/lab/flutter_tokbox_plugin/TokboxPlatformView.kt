package com.lab.flutter_tokbox_plugin

import android.content.Context
import android.os.Handler
import android.view.View
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

class TokboxPlatformView(private val context: Context,
                         messenger: BinaryMessenger, id: Int,
                         private val parameters: Map<String, String>)
                         : PlatformView, MethodChannel.MethodCallHandler, TokboxCameraListener {

    private val mTokboxView: TokboxCameraView = TokboxCameraView(context = context)
    private var callDisposeResult: MethodChannel.Result? = null

    init {
        println("@@@@@ TokboxPlatformView.constructor: $id $parameters")

        MethodChannel(messenger, "$PLUGIN_VIEW_CHANNEL_KEY#$id")
                .setMethodCallHandler(this)

        mTokboxView.setListener(this)

        Handler().postDelayed({
            mTokboxView.connect(
                    parameters.getValue("api_key"),
                    parameters.getValue("session_id"),
                    parameters.getValue("token"))
        }, 400)
    }

    override fun getView(): View = mTokboxView

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        println("@@@@@ TokboxPlatformView.onMethodCall: ${call.method} with args ${call.arguments}")
        when (call.method) {
            "onCallDispose" -> callDisposeResult = result
            else -> result.notImplemented()
        }
    }

    override fun dispose() {
        println("@@@@@ TokboxPlatformView.dispose")
        mTokboxView.disconnect()
        callDisposeResult?.success(null)
        callDisposeResult = null
    }

    override fun onDisconnect() {
        println("@@@@@ TokboxPlatformView.onDisconnect")
        callDisposeResult?.success(null)
    }

}