package com.regl.regl_takip

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
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

                setOnClickPendingIntent(
                    R.id.widget_root,
                    HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java,
                        Uri.parse("regltakip://widget/open")
                    )
                )
                val actionVisible = widgetData.getBoolean("period_action_visible", false)
                if (actionVisible) {
                    setViewVisibility(R.id.widget_period_action, View.VISIBLE)
                    setContentDescription(
                        R.id.widget_period_action,
                        widgetData.getString("period_action_label", "") ?: ""
                    )
                    setOnClickPendingIntent(
                        R.id.widget_period_action,
                        HomeWidgetLaunchIntent.getActivity(
                            context,
                            MainActivity::class.java,
                            Uri.parse("regltakip://widget/period-start")
                        )
                    )
                } else {
                    setViewVisibility(R.id.widget_period_action, View.GONE)
                }

                // Mini faz ring'i Dart tarafında PNG olarak çizilir;
                // yol yoksa (gizli mod / veri yok) görünmez kalır
                val ringPath = widgetData.getString("ring_path", null)
                val bitmap = ringPath?.let { BitmapFactory.decodeFile(it) }
                if (bitmap != null && !actionVisible) {
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
