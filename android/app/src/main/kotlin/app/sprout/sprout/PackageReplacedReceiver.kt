package app.sprout.sprout

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/** Runs in the new version right after an update, since Android closes the old one. */
class PackageReplacedReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_MY_PACKAGE_REPLACED) return
        UpdateEvents.notify(context, UpdateEvents.UPDATED_ID, "Sprout is updated", "Tap to open your garden.")
    }
}
