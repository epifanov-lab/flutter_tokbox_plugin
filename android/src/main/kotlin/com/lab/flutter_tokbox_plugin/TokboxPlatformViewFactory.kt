package com.lab.flutter_tokbox_plugin

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class TokboxViewFactory(private val messenger: BinaryMessenger): PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context?, id: Int, args: Any?): PlatformView {
        println("@@@@@ TokboxViewFactory: $id $args")
        val params = args as Map<String, String>
        return TokboxPlatformView(context!!, messenger, id, params)
    }
}