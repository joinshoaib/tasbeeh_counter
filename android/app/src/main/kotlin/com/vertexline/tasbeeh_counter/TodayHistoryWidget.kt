package com.vertexline.tasbeeh_counter

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class TodayHistoryWidget : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.today_history_widget)

            // Get today's date
            val date = java.text.SimpleDateFormat("MMM dd", java.util.Locale.getDefault()).format(java.util.Date())
            views.setTextViewText(R.id.tv_date, date)

            // Get all keys from widgetData
            val allKeys = widgetData.all.keys

            // Filter dhikr count keys
            val dhikrEntries = allKeys
                .filter { it.startsWith("dhikr_") }
                .mapNotNull { key ->
                    val name = key.removePrefix("dhikr_")
                    val count = widgetData.getString(key, "0") ?: "0"
                    val targetKey = "target_$name"
                    val target = widgetData.getString(targetKey, "33") ?: "33"
                    
                    // Only include if count > 0
                    if (count != "0") Triple(name, count, target) else null
                }
                .sortedByDescending { it.second.toIntOrNull() ?: 0 }

            // Show up to 3 dhikrs
            val displayDhikrs = dhikrEntries.take(3)

            // Set dhikr rows
            val rowIds = listOf(R.id.row_1, R.id.row_2, R.id.row_3)
            val nameIds = listOf(R.id.tv_dhikr_1, R.id.tv_dhikr_2, R.id.tv_dhikr_3)
            val countIds = listOf(R.id.tv_count_1, R.id.tv_count_2, R.id.tv_count_3)

            for (i in 0..2) {
                if (i < displayDhikrs.size) {
                    val (name, count, target) = displayDhikrs[i]
                    views.setTextViewText(nameIds[i], name)
                    views.setTextViewText(countIds[i], "$count/$target")
                    views.setViewVisibility(rowIds[i], android.view.View.VISIBLE)
                } else {
                    views.setViewVisibility(rowIds[i], android.view.View.GONE)
                }
            }

            // Show "more" indicator
            val moreCount = dhikrEntries.size - 3
            if (moreCount > 0) {
                views.setTextViewText(R.id.tv_more, "+$moreCount more")
                views.setViewVisibility(R.id.tv_more, android.view.View.VISIBLE)
            } else {
                views.setViewVisibility(R.id.tv_more, android.view.View.GONE)
            }

            // Open app on tap
            val intent = Intent(context, MainActivity::class.java).apply {
                action = Intent.ACTION_MAIN
                addCategory(Intent.CATEGORY_LAUNCHER)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP
            }

            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}