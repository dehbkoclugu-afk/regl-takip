package com.regl.regl_takip

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.net.Uri
import android.util.Log
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
            try {
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

                    val ringPath = widgetData.getString("ring_path", null)
                    val bitmap = try {
                        ringPath?.let { BitmapFactory.decodeFile(it) }
                    } catch (error: Throwable) {
                        Log.w(TAG, "Ring bitmap could not be decoded", error)
                        null
                    }
                    if (bitmap != null && !actionVisible) {
                        setImageViewBitmap(R.id.widget_ring, bitmap)
                        setViewVisibility(R.id.widget_ring, View.VISIBLE)
                    } else {
                        setViewVisibility(R.id.widget_ring, View.GONE)
                    }
                }
                appWidgetManager.updateAppWidget(widgetId, views)
            } catch (error: Throwable) {
                // AppWidgetProvider is invoked by the launcher while the Flutter
                // activity may be closed. A stale widget/layout preference must
                // not crash the whole application process.
                Log.e(TAG, "Compact widget update failed for id=$widgetId", error)
            }
        }
    }

    private companion object {
        const val TAG = "CycleWidgetProvider"
    }
}
