package com.regl.regl_takip

import android.content.SharedPreferences
import org.json.JSONObject
import java.time.LocalDate

/**
 * Dart tarafı önümüzdeki günlerin widget içeriğini "daily" anahtarına
 * (yyyy-MM-dd → alanlar) yazar. Provider her çizimde bugünün satırını
 * seçer; böylece uygulama açılmasa da "Gün X / N gün kaldı" gün değişince
 * ilerler. Bugünün kaydı yoksa (veri eski ya da hiç yazılmamış) düz
 * anahtarlara düşülür — eski davranış.
 */
internal class WidgetDaily(private val data: SharedPreferences) {
    private val today: JSONObject? = try {
        data.getString("daily", null)?.let {
            JSONObject(it).optJSONObject(LocalDate.now().toString())
        }
    } catch (error: Exception) {
        null
    }

    fun string(key: String, jsonKey: String = key, fallback: String? = ""): String? {
        val entry = today
        if (entry != null && entry.has(jsonKey)) {
            return if (entry.isNull(jsonKey)) null else entry.getString(jsonKey)
        }
        return data.getString(key, fallback)
    }
}
