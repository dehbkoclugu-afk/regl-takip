package com.regl.regl_takip

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class CycleWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.cycle_widget).apply {
                setTextViewText(R.id.widget_line1, widgetData.getString("line1", "Regl Takip"))
                val line2 = widgetData.getString("line2", "") ?: ""
                setTextViewText(R.id.widget_line2, line2)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
