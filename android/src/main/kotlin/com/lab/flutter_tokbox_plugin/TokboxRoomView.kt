package com.lab.flutter_tokbox_plugin

import android.Manifest
import android.content.Context
import android.opengl.GLSurfaceView
import android.util.AttributeSet
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.widget.*

import com.opentok.android.Session
import com.opentok.android.Stream
import com.opentok.android.Publisher
import com.opentok.android.PublisherKit
import com.opentok.android.Subscriber
import com.opentok.android.BaseVideoRenderer
import com.opentok.android.OpentokError
import pub.devrel.easypermissions.EasyPermissions


import java.util.*

interface TokboxCameraListener {
    fun onDisconnect()
}

class TokboxCameraView
@JvmOverloads constructor(context: Context, attrs: AttributeSet? = null, defStyle: Int = 0)
    : FrameLayout(context, attrs, defStyle), Session.SessionListener, PublisherKit.PublisherListener {

    companion object {
        private const val MAX_NUM_SUBSCRIBERS = 2
        private const val TAG = "TokeBoxCameraView"
    }

    private var mPublisherView: FrameLayout
    private var mSubscriberViewPrimary: FrameLayout
    private var mSubscriberViewSecondary: FrameLayout
    private var mSessionStatus: TextView
    private var mEndCallButton: View
    private var mSwitchCameraButton: View
    private var mMuteButton: ImageView
    private var mProgressBar: ProgressBar

    private var callSession: Session? = null
    private var publisher: Publisher? = null
    private val subscribers = ArrayList<Subscriber>()
    private val subscriberStreams = HashMap<Stream, Subscriber>()
    private var tokboxCameraListener: TokboxCameraListener? = null
    private var isAudioPublished: Boolean = true

    init {
        val view = LayoutInflater.from(context).inflate(R.layout.tokbox_camera_view, this, true)
        mPublisherView = view.findViewById(R.id.publisher_view)
        mSubscriberViewPrimary = view.findViewById(R.id.subscriber_view_0)
        mSubscriberViewSecondary = view.findViewById(R.id.subscriber_view_1)
        mSessionStatus = view.findViewById(R.id.video_status)
        mEndCallButton = view.findViewById(R.id.end_call_button)
        mSwitchCameraButton = view.findViewById(R.id.switch_camera_button)
        mMuteButton = view.findViewById(R.id.mute_mic_button)
        mProgressBar = view.findViewById(R.id.progress_bar)

        mEndCallButton.setOnClickListener { disconnect() }
        mSwitchCameraButton.setOnClickListener { publisher?.cycleCamera() }
        mMuteButton.setOnClickListener {
            isAudioPublished = !isAudioPublished
            publisher?.publishAudio = isAudioPublished
            mMuteButton.setImageResource(
                    if (isAudioPublished) R.drawable.ic_mic_on
                    else R.drawable.ic_mic_off)
            }

        keepScreenOn = true
    }

    fun setListener(listener: TokboxCameraListener) {
        tokboxCameraListener = listener
    }

    fun connect(apiKey: String, sessionId: String, token: String) {
        callSession = Session.Builder(context, apiKey, sessionId).build()
        callSession?.setSessionListener(this)
        callSession?.connect(token)
    }

    override fun onConnected(session: Session) {
        setStatus("onConnected: Connected to session " + session.sessionId)
        mProgressBar.visibility = View.GONE

        publisher = Publisher.Builder(context)
                .resolution(Publisher.CameraCaptureResolution.MEDIUM)
                .name("publisher")
                .build()

        publisher?.run {
            setPublisherListener(this@TokboxCameraView)
            setStyle(BaseVideoRenderer.STYLE_VIDEO_SCALE, BaseVideoRenderer.STYLE_VIDEO_FILL)

            mPublisherView.addView(view)
            if (publisher?.view is GLSurfaceView) {
                (publisher?.view as GLSurfaceView).setZOrderOnTop(true)
            }
        }


        callSession?.publish(publisher)
    }

    override fun onDisconnected(session: Session) {
        setStatus("onDisconnected: disconnected from session " + session.sessionId)

        callSession = null
        tokboxCameraListener?.onDisconnect()
        tokboxCameraListener = null
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
            mSubscriberViewPrimary.run {
                addView(subscriber.view)
                visibility = View.VISIBLE
            }
        } else {
            mSubscriberViewSecondary.run {
                addView(subscriber.view)
                visibility = View.VISIBLE
            }
        }
    }

    override fun onStreamDropped(session: Session, stream: Stream) {
        setStatus("onStreamDropped: Stream " + stream.streamId + " dropped from session " + session.sessionId)
        val subscriber = subscriberStreams[stream] ?: return
        if (subscribers.indexOf(subscriber) == 0) {
            mSubscriberViewPrimary.run {
                removeAllViews()
                visibility = View.GONE
            }
        } else {
            mSubscriberViewSecondary.run {
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
            mPublisherView.removeView(publisher?.view)
            callSession?.unpublish(publisher)
            publisher?.destroy()
            publisher = null
        }
        callSession?.disconnect()
    }

    fun setStatus(message: String) {
        Log.d(TAG, message)
        mSessionStatus.text = message
    }
}