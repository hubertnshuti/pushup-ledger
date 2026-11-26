package com.hubertnshuti.pushup_ledger

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import org.json.JSONException
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/** Shows the line stored for today and opens the app when tapped. */
class PushupWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        manager: AppWidgetManager,
        widgetIds: IntArray,
    ) {
        val views = buildViews(context)
        widgetIds.forEach { manager.updateAppWidget(it, views) }
    }

    companion object {
        private const val PREFERENCES = "pushup_widget"
        private const val LINES_KEY = "lines_by_date"

        fun saveLines(context: Context, lines: Map<String, String>) {
            context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
                .edit()
                .putString(LINES_KEY, JSONObject(lines).toString())
                .apply()

            val manager = AppWidgetManager.getInstance(context)
            val component = ComponentName(context, PushupWidgetProvider::class.java)
            val views = buildViews(context)
            manager.getAppWidgetIds(component).forEach {
                manager.updateAppWidget(it, views)
            }
        }

        private fun buildViews(context: Context): RemoteViews {
            val intent = Intent(context, MainActivity::class.java)
            val tapAction = PendingIntent.getActivity(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            return RemoteViews(context.packageName, R.layout.widget_pushup).apply {
                setTextViewText(R.id.widget_line, lineForToday(context))
                setOnClickPendingIntent(R.id.widget_root, tapAction)
            }
        }

        private fun lineForToday(context: Context): String {
            val fallback = context.getString(R.string.widget_fallback)
            val stored = context
                .getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
                .getString(LINES_KEY, null) ?: return fallback
            val today = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
            return try {
                JSONObject(stored).optString(today, fallback)
            } catch (_: JSONException) {
                fallback
            }
        }
    }
}
