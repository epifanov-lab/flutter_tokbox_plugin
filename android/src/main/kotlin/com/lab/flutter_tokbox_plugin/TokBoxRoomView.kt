package com.lab.flutter_tokbox_plugin

import android.Manifest
import android.content.Context
import android.opengl.GLSurfaceView
import android.util.AttributeSet
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.widget.FrameLayout
import android.widget.TextView
import android.widget.Toast

import java.util.*

interface TokBoxCameraListener {
    fun onDisconnect()
}

class TokBoxCameraView
@JvmOverloads constructor(context: Context,
                          attrs: AttributeSet? = null,
                          defStyle: Int = 0) : FrameLayout(context, attrs, defStyle), Session.SessionListener, PublisherKit.PublisherListener {
    companion object {
        private const val MAX_NUM_SUBSCRIBERS = 2
        private const val TAG = "TokeBoxCameraView"
    }

    private var publisherView: FrameLayout
    private var subscriberViewPrimary: FrameLayout
    private var subscriberViewSecondary: FrameLayout
    private var sessionStatus: TextView
    private var callSession: Session? = null
    private var publisher: Publisher? = null
    private val subscribers = ArrayList<Subscriber>()
    private val subscriberStreams = HashMap<Stream, Subscriber>()
    private var tokBoxCameraListener: TokBoxCameraListener? = null
    private var isAudioPublished: Boolean = true

    init {
        val view = LayoutInflater.from(context).inflate(R.layout.tokbox_camera_view, this, true)
        publisherView = view.publisher_view
        subscriberViewPrimary = view.subscriber_view_0
        subscriberViewSecondary = view.subscriber_view_1
        sessionStatus = view.video_status

        view.end_call_button.setOnClickListener { disconnect() }
        view.switch_camera_button.setOnClickListener {
            publisher?.cycleCamera()
        }

        mute_mic_button.setOnClickListener {
            isAudioPublished = !isAudioPublished
            publisher?.publishAudio = isAudioPublished
            mute_mic_button.setImageResource(if (isAudioPublished) R.drawable.ic_mic_on else R.drawable.ic_mic_off)
        }
        keepScreenOn = true
    }

    fun setListener(listener: TokBoxCameraListener) {
        tokBoxCameraListener = listener
    }

    fun connect(apiKey: String, sessionId: String, token: String) {
        val perms = arrayOf(Manifest.permission.INTERNET, Manifest.permission.CAMERA, Manifest.permission.RECORD_AUDIO)
        if (EasyPermissions.hasPermissions(context, *perms)) {
            callSession = Session.Builder(context, apiKey, sessionId).build()
            callSession?.setSessionListener(this)
            callSession?.connect(token)
        } else {
            setStatus("No permissons for camera and mic")
        }
    }

    override fun onConnected(session: Session) {
        setStatus("onConnected: Connected to session " + session.sessionId)
        progress_bar.visibility = View.GONE

        publisher = Publisher.Builder(context)
                .resolution(Publisher.CameraCaptureResolution.MEDIUM)
                .name("publisher")
                .build()

        publisher?.run {
            setPublisherListener(this@TokBoxCameraView)
            setStyle(BaseVideoRenderer.STYLE_VIDEO_SCALE, BaseVideoRenderer.STYLE_VIDEO_FILL)

            publisherView.addView(view)
            if (publisher?.view is GLSurfaceView) {
                (publisher?.view as GLSurfaceView).setZOrderOnTop(true)
            }
        }


        callSession?.publish(publisher)
    }

    override fun onDisconnected(session: Session) {
        setStatus("onDisconnected: disconnected from session " + session.sessionId)

        callSession = null
        tokBoxCameraListener?.onDisconnect()
        tokBoxCameraListener = null
    }

    override fun onError(session: Session, opentokError: OpentokError) {
        setStatus("onError: Error (" + opentokError.message + ") in session " + session.sessionId)

        disconnect()
    }

    override fun onStreamReceived(session: Session, stream: Stream) {
        setStatus("onStreamReceived: New stream " + stream.streamId + " in session " + session.sessionId)

        if (!stream.hasVideo()) return

        if (subscribers.size + 1 > MAX_NUM_SUBSCRIBERS) {
            setStatus("New subscriber ignored. MAX_NUM_SUBSCRIBERS limit reached")
            Toast.makeText(context, "New subscriber ignored. MAX_NUM_SUBSCRIBERS limit reached.", Toast.LENGTH_LONG).show()
            return
        }
        val subscriber = Subscriber.Builder(context, stream).build()
        callSession?.subscribe(subscriber)

        subscribers.add(subscriber)
        subscriberStreams[stream] = subscriber
        subscriber.renderer.setStyle(BaseVideoRenderer.STYLE_VIDEO_SCALE, BaseVideoRenderer.STYLE_VIDEO_FILL)
        if (subscribers.size == 1) {
            subscriberViewPrimary.run {
                addView(subscriber.view)
                visibility = View.VISIBLE
            }
        } else {
            subscriberViewSecondary.run {
                addView(subscriber.view)
                visibility = View.VISIBLE
            }
        }
    }

    override fun onStreamDropped(session: Session, stream: Stream) {
        setStatus("onStreamDropped: Stream " + stream.streamId + " dropped from session " + session.sessionId)
        val subscriber = subscriberStreams[stream] ?: return
        if (subscribers.indexOf(subscriber) == 0) {
            subscriberViewPrimary.run {
                removeAllViews()
                visibility = View.GONE
            }
        } else {
            subscriberViewSecondary.run {
                removeAllViews()
                visibility = View.GONE
            }
        }

        subscribers.remove(subscriber)
        subscriberStreams.remove(stream)

        if (subscribers.isEmpty()) {
            disconnect()
        }
    }

    // Listeners from publisher
    override fun onError(publisherKit: PublisherKit, opentokError: OpentokError) {
        setStatus("onError: Error (" + opentokError.message + ") in publisher")
        Toast.makeText(context, "Session error. See the logcat please.", Toast.LENGTH_LONG).show()

        disconnect()
    }

    override fun onStreamCreated(p0: PublisherKit?, stream: Stream) {
        setStatus("onStreamCreated: Own stream " + stream.streamId + " created")
    }

    override fun onStreamDestroyed(p0: PublisherKit?, stream: Stream) {
        setStatus("onStreamDestroyed: Own stream " + stream.streamId + " destroyed")
    }

    fun disconnect() {
        if (callSession == null) {
            return
        }

        if (subscribers.size > 0) {
            for (subscriber in subscribers) {
                callSession?.unsubscribe(subscriber)
                subscriber.destroy()
            }
        }

        if (publisher != null) {
            publisherView.removeView(publisher?.view)
            callSession?.unpublish(publisher)
            publisher?.destroy()
            publisher = null
        }
        callSession?.disconnect()
    }

    private fun setStatus(message: String) {
        Log.d(TAG, message)
        sessionStatus.text = message
    }
}