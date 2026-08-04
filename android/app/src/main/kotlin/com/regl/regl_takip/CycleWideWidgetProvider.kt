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

/**
 * 4x2 geniş widget: ring + gün + üç tahmin satırı.
 * Veriler Dart tarafında lokalize edilip SharedPreferences ile gelir;
 * boş değerli satırlar gizlenir (gizli mod / hamilelik / hap modu).
 */
class CycleWideWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (widgetId in appWidgetIds) {
            try {
                val views = RemoteViews(context.packageName, R.layout.cycle_widget_wide).apply {
                    setTextViewText(R.id.widget_line1, widgetData.getString("line1", "Regl Takip"))
                    setTextViewText(R.id.widget_line2, widgetData.getString("line2", "") ?: "")

                    setOnClickPendingIntent(
                        R.id.widget_root,
                        HomeWidgetLaunchIntent.getActivity(
                            context,
                            MainActivity::class.java,
                            Uri.parse("regltakip://widget/open")
                        )
                    )
                    val actionVisible = widgetData.getBoolean("period_action_visible", false)
                    setViewVisibility(
                        R.id.widget_period_action,
                        if (actionVisible) View.VISIBLE else View.GONE
                    )
                    if (actionVisible) {
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
                    }

                    val ringPath = widgetData.getString("ring_path", null)
                    val bitmap = try {
                        ringPath?.let { BitmapFactory.decodeFile(it) }
                    } catch (error: Throwable) {
                        Log.w(TAG, "Ring bitmap could not be decoded", error)
                        null
                    }
                    if (bitmap != null) {
                        setImageViewBitmap(R.id.widget_ring, bitmap)
                        setViewVisibility(R.id.widget_ring, View.VISIBLE)
                    } else {
                        setViewVisibility(R.id.widget_ring, View.GONE)
                    }

                    bindRow(widgetData, "pred1", R.id.widget_row1, R.id.widget_row1_label, R.id.widget_row1_value)
                    bindRow(widgetData, "pred2", R.id.widget_row2, R.id.widget_row2_label, R.id.widget_row2_value)
                    bindRow(widgetData, "pred3", R.id.widget_row3, R.id.widget_row3_label, R.id.widget_row3_value)
                }
                appWidgetManager.updateAppWidget(widgetId, views)
            } catch (error: Throwable) {
                // The launcher can refresh widgets independently of Flutter.
                // Stale preferences or an OEM RemoteViews failure should not
                // terminate the application process.
                Log.e(TAG, "Wide widget update failed for id=$widgetId", error)
            }
        }
    }

    private fun RemoteViews.bindRow(
        data: SharedPreferences,
        key: String,
        rowId: Int,
        labelId: Int,
        valueId: Int
    ) {
        val label = data.getString("${key}_label", "") ?: ""
        val value = data.getString("${key}_value", "") ?: ""
        if (label.isEmpty() || value.isEmpty()) {
            setViewVisibility(rowId, View.GONE)
        } else {
            setTextViewText(labelId, label)
            setTextViewText(valueId, value)
            setViewVisibility(rowId, View.VISIBLE)
        }
    }

    private companion object {
        const val TAG = "CycleWideWidgetProvider"
    }
}
