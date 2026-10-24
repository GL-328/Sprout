package app.sprout.sprout

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel

/**
 * Carries install results to Dart while the app runs, and keeps the last one
 * so the app can show it after a restart.
 */
object UpdateEvents : EventChannel.StreamHandler {
    private const val PREFS = "sprout_updater"
    private const val CHANNEL = "updates"
    private const val CONFIRM_ID = 7101
    const val UPDATED_ID = 7102

    private val main = Handler(Looper.getMainLooper())
    private var sink: EventChannel.EventSink? = null

    @Volatile
    private var pendingConfirm: Intent? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
    }

    override fun onCancel(arguments: Any?) {
        sink = null
    }

    fun emit(context: Context, status: Int, message: String?) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
            .putInt("status", status)
            .putString("message", message ?: "")
            .putLong("at", System.currentTimeMillis())
            .apply()
        main.post { sink?.success(mapOf("status" to status, "message" to (message ?: ""))) }
    }

    /** The last result, once; null if there is none. */
    fun takeLastResult(context: Context): Map<String, Any>? {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        if (!prefs.contains("status")) return null
        val result = mapOf<String, Any>(
            "status" to prefs.getInt("status", 1),
            "message" to (prefs.getString("message", "") ?: ""),
            "at" to prefs.getLong("at", 0),
        )
        prefs.edit().clear().apply()
        return result
    }

    /**
     * Shows Android's "Update this app?" screen. It opens straight away when
     * Sprout is on screen; otherwise a notification brings Sprout back first,
     * because Android blocks screens opened from the background.
     */
    fun showConfirm(context: Context, confirm: Intent) {
        confirm.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        main.post {
            val activity = MainActivity.resumed
            if (activity != null) {
                activity.startActivity(confirm)
            } else {
                pendingConfirm = confirm
                notify(context, CONFIRM_ID, "Your Sprout update is ready", "Tap to finish updating.")
            }
        }
    }

    fun takePendingConfirm(): Intent? = pendingConfirm.also { pendingConfirm = null }

    /** A small notification that opens Sprout. */
    fun notify(context: Context, id: Int, title: String, text: String) {
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            manager.createNotificationChannel(
                NotificationChannel(CHANNEL, "Updates", NotificationManager.IMPORTANCE_DEFAULT),
            )
        }
        val open = context.packageManager.getLaunchIntentForPackage(context.packageName) ?: return
        val tap = PendingIntent.getActivity(context, id, open, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(context, CHANNEL)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(context)
        }
        val notification = builder
            .setSmallIcon(R.drawable.ic_stat_sprout)
            .setContentTitle(title)
            .setContentText(text)
            .setContentIntent(tap)
            .setAutoCancel(true)
            .build()
        try {
            manager.notify(id, notification)
        } catch (_: SecurityException) {
            // Notifications are off; the app shows the result when opened.
        }
    }
}
