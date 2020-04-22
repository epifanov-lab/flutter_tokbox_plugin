package com.lab.flutter_tokbox_plugin

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.ContextWrapper
import android.os.Handler
import android.view.View
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import pub.devrel.easypermissions.AfterPermissionGranted
import pub.devrel.easypermissions.AppSettingsDialog
import pub.devrel.easypermissions.EasyPermissions
import pub.devrel.easypermissions.EasyPermissions.PermissionCallbacks

const val RC_SETTINGS_SCREEN_PERM = 123
const val RC_VIDEO_APP_PERM = 124

class TokboxPlatformView(private val context: Context,
                         messenger: BinaryMessenger,
                         private val activity: Activity,
                         id: Int,
                         private val parameters: Map<String, String>)
                         : PlatformView, MethodChannel.MethodCallHandler, PermissionCallbacks, TokboxCameraListener {

    private val mTokboxView: TokboxCameraView = TokboxCameraView(context = context)
    private var callDisposeResult: MethodChannel.Result? = null

    init {
        println("@@@@@ TokboxPlatformView.constructor: $id $parameters")

        MethodChannel(messenger, "$PLUGIN_VIEW_CHANNEL_KEY#$id")
                .setMethodCallHandler(this)

        mTokboxView.setListener(this)

        Handler().postDelayed(this::requestPermissions, 400)
    }

    @AfterPermissionGranted(RC_VIDEO_APP_PERM)
    private fun requestPermissions() {
        val perms = arrayOf(Manifest.permission.INTERNET, Manifest.permission.CAMERA, Manifest.permission.RECORD_AUDIO)
        println("@@@@@ TokboxPlatformView.requestPermissions: $activity - $perms")
        if (EasyPermissions.hasPermissions(context, *perms)) {
            if (EasyPermissions.hasPermissions(context, *perms)) {
                if (areConfigsValid(parameters)) {
                    mTokboxView.connect(
                            parameters.getValue("api_key"),
                            parameters.getValue("session_id"),
                            parameters.getValue("token"))
                } else {
                    mTokboxView.setStatus("API KEY, SESSION ID or TOKEN cannot be null or empty.")
                }
            } else mTokboxView.setStatus("No permissons for camera and mic")
        } else {
            EasyPermissions.requestPermissions(activity, activity.getString(R.string.rationale_video_app),
                    RC_VIDEO_APP_PERM, *perms)
        }
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



    override fun onPermissionsDenied(requestCode: Int, perms: MutableList<String>?) {
        println("onPermissionsDenied:" + requestCode + ":" + perms!!.size)
        if (EasyPermissions.somePermissionPermanentlyDenied(activity, perms)) {
            AppSettingsDialog.Builder(activity)
                    .setTitle(activity.getString(R.string.title_settings_dialog))
                    .setRationale(activity.getString(R.string.rationale_ask_again))
                    .setPositiveButton(activity.getString(R.string.setting))
                    .setNegativeButton(activity.getString(R.string.cancel))
                    .setRequestCode(RC_SETTINGS_SCREEN_PERM)
                    .build()
                    .show()
        }
    }

    override fun onPermissionsGranted(requestCode: Int, perms: MutableList<String>?) {
        println("onPermissionsGranted:" + requestCode + ":" + perms!!.size)
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        EasyPermissions.onRequestPermissionsResult(requestCode, permissions, grantResults, this)
    }

    fun areConfigsValid(parameters: Map<String, String>): Boolean {
        return parameters.getValue("api_key") != null && parameters.getValue("api_key").isNotEmpty()
                && parameters.getValue("session_id") != null && parameters.getValue("session_id").isNotEmpty()
                && parameters.getValue("token") != null && parameters.getValue("token").isNotEmpty()
    }

}