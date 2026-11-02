package app.sprout.sprout

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/** Today's date as the app writes it (yyyy-mm-dd), to spot data from an earlier day. */
private fun today(): String = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())

/** Opens Sprout at [link] (sprout://today, sprout://mood?value=N). */
private fun open(context: Context, link: String) =
    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse(link))

/** Reads a number the app saved (ints arrive as Int, but be forgiving). */
private fun SharedPreferences.number(key: String): Int =
    when (val v = all[key]) {
        is Int -> v
        is Long -> v.toInt()
        else -> 0
    }

/** The Today widget: the seed meter and the next two quests. Tapping it opens Today. */
class TodayWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val written = widgetData.getString("day", null)
        val fresh = written == today()
        val goal = widgetData.number("meter_goal").coerceAtLeast(1)
        val filled = widgetData.number("meter_filled").coerceIn(0, goal)
        val left = widgetData.number("quests_left")
        val done = widgetData.number("quests_done")
        val quests = listOf("quest_1", "quest_2").map { widgetData.getString(it, "") ?: "" }

        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_today)
            views.setProgressBar(R.id.today_meter, goal, filled, false)
            views.setTextViewText(R.id.today_meter_label, "$filled of $goal to your next seed")

            // A new day, and the app hasn't been opened yet: don't show yesterday's list.
            val note = when {
                written == null -> "Open Sprout to fill this in"
                !fresh -> "Open Sprout to see today's quests"
                left == 0 && done > 0 -> "All done for today"
                left == 0 -> "No quests planned for today"
                else -> null
            }
            views.setTextViewText(R.id.today_left, if (fresh && left > 0) "$left to go" else "")
            views.setViewVisibility(R.id.today_note, if (note != null) View.VISIBLE else View.GONE)
            views.setTextViewText(R.id.today_note, note ?: "")
            val rows = listOf(R.id.today_q1_row to R.id.today_q1, R.id.today_q2_row to R.id.today_q2)
            for ((i, row) in rows.withIndex()) {
                val title = if (note == null) quests[i] else ""
                views.setViewVisibility(row.first, if (title.isNotEmpty()) View.VISIBLE else View.GONE)
                views.setTextViewText(row.second, title)
            }

            views.setOnClickPendingIntent(R.id.today_root, open(context, "sprout://today"))
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}

/** The Mood widget: five faces to check in with, or today's mood (tap to change). */
class MoodWidgetProvider : HomeWidgetProvider() {
    private val faces = listOf(R.id.mood_1, R.id.mood_2, R.id.mood_3, R.id.mood_4, R.id.mood_5)
    private val pictures = listOf(
        R.drawable.widget_mood_1,
        R.drawable.widget_mood_2,
        R.drawable.widget_mood_3,
        R.drawable.widget_mood_4,
        R.drawable.widget_mood_5,
    )
    private val labels = listOf("rough", "low", "okay", "good", "great")

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val fresh = widgetData.getString("day", null) == today()
        val mood = if (fresh) widgetData.number("mood") else 0

        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_mood)
            if (mood in 1..5) {
                views.setViewVisibility(R.id.mood_pick, View.GONE)
                views.setViewVisibility(R.id.mood_done, View.VISIBLE)
                views.setImageViewResource(R.id.mood_face, pictures[mood - 1])
                views.setTextViewText(R.id.mood_label, "Feeling ${labels[mood - 1]} today")
                views.setOnClickPendingIntent(R.id.mood_root, open(context, "sprout://mood"))
            } else {
                views.setViewVisibility(R.id.mood_pick, View.VISIBLE)
                views.setViewVisibility(R.id.mood_done, View.GONE)
                views.setOnClickPendingIntent(R.id.mood_root, open(context, "sprout://mood"))
                for ((i, face) in faces.withIndex()) {
                    views.setOnClickPendingIntent(face, open(context, "sprout://mood?value=${i + 1}"))
                }
            }
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
