package com.regl.regl_takip

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.view.View
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

                // Mini faz ring'i Dart tarafında PNG olarak çizilir;
                // yol yoksa (gizli mod / veri yok) görünmez kalır
                val ringPath = widgetData.getString("ring_path", null)
                val bitmap = ringPath?.let { BitmapFactory.decodeFile(it) }
                if (bitmap != null) {
                    setImageViewBitmap(R.id.widget_ring, bitmap)
                    setViewVisibility(R.id.widget_ring, View.VISIBLE)
                } else {
                    setViewVisibility(R.id.widget_ring, View.GONE)
                }
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
