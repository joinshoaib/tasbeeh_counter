package com.vertexline.tasbeeh_counter

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class DailyStatsWidget : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.daily_stats_widget)

            val todayCount = widgetData.getString("today_count", "0") ?: "0"
            val dailyGoal = widgetData.getString("daily_goal", "100") ?: "100"
            val progress = todayCount.toFloat() / dailyGoal.toFloat()

            val percent = (progress * 100).toInt()
            views.setTextViewText(R.id.tv_percent, "$percent%")

            views.setTextViewText(R.id.tv_today_count, todayCount)
            views.setTextViewText(R.id.tv_daily_goal, "/ $dailyGoal")

            // Progress bar (0-100)
            views.setProgressBar(R.id.progress_bar, 100, (progress * 100).toInt(), false)
            

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