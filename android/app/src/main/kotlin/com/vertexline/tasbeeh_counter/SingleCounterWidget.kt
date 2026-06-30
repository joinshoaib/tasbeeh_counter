package com.vertexline.tasbeeh_counter

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class SingleCounterWidget : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.single_counter_widget)

            val dhikr = widgetData.getString("dhikr_name", "SubhanAllah") ?: "SubhanAllah"
            val count = widgetData.getString("count", "0") ?: "0"
            val target = widgetData.getString("target", "33") ?: "33"
            val arabic_dhikr = widgetData.getString("arabic_name", "سُبْحَانَ اللَّه") ?: "سُبْحَانَ اللَّه"

            views.setTextViewText(R.id.tv_dhikr_name, arabic_dhikr)
            views.setTextViewText(R.id.tv_count, count)
            views.setTextViewText(R.id.tv_target, "/ $target")

            // Intent that reuses existing activity
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