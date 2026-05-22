// android/app/src/main/kotlin/com/mokges/app/MokgesWidget.kt
package com.mokges.app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import android.app.PendingIntent
import android.content.Intent
import es.antonborri.home_widget.HomeWidgetPlugin

class MokgesWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val widgetData = HomeWidgetPlugin.getData(context)
        val views = RemoteViews(context.packageName, R.layout.mokges_widget)

        // Open app on click
        val intent = Intent(context, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            context, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(android.R.id.content, pendingIntent)

        // Load tasks
        for (i in 0..2) {
            val title = widgetData.getString("task_${i}_title", "") ?: ""
            val time = widgetData.getString("task_${i}_time", "") ?: ""

            if (title.isNotEmpty()) {
                val titleId = context.resources.getIdentifier(
                    "task_${i}_title", "id", context.packageName)
                val timeId = context.resources.getIdentifier(
                    "task_${i}_time", "id", context.packageName)

                views.setTextViewText(titleId, title)
                views.setTextViewText(timeId, time)
            }
        }

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}
