package fr.oriondev.strascrous.widget

import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Locale
import org.json.JSONArray
import org.json.JSONException

data class RestaurantLite(val id: String, val title: String, val type: String) {
    val isCafeteria get() = type == "cafeteria"

    companion object {
        fun listFromJson(json: String?): List<RestaurantLite> {
            if (json.isNullOrBlank()) return emptyList()

            return try {
                val array = JSONArray(json)
                (0 until array.length()).mapNotNull { i ->
                    array.optJSONObject(i)?.let { o ->
                        val id = o.optString("id")
                        if (id.isEmpty()) null
                        else RestaurantLite(id, o.optString("title"), o.optString("type"))
                    }
                }
            } catch (e: JSONException) {
                emptyList()
            }
        }
    }
}

data class MenuItem(val title: String, val elements: List<String>)
data class Service(val date: String, val label: String, val items: List<MenuItem>)

private const val NOON_UNTIL = 14
private const val EVENING_UNTIL = 21
private class DayMenu(val date: String, val noon: List<MenuItem>, val evening: List<MenuItem>)

fun pickService(menusJson: String?, now: Calendar = Calendar.getInstance()): Service? {
    val days = parseDays(menusJson)
    if (days.isEmpty()) return null

    val format = SimpleDateFormat("yyyy-MM-dd", Locale.US).apply { timeZone = now.timeZone }
    val today = format.format(now.time)
    val tomorrow = format.format((now.clone() as Calendar).apply { add(Calendar.DAY_OF_YEAR, 1) }.time)
    val hour = now.get(Calendar.HOUR_OF_DAY)

    fun dayLabel(date: String) = when (date) {
        today -> " · aujourd'hui"
        tomorrow -> " · demain"
        else -> ""
    }

    days.firstOrNull { it.date == today }?.let { day ->
        if (hour < NOON_UNTIL && day.noon.isNotEmpty()) {
            return Service(day.date, "Midi" + dayLabel(day.date), day.noon)
        }

        if (hour < EVENING_UNTIL && day.evening.isNotEmpty()) {
            return Service(day.date, "Soir" + dayLabel(day.date), day.evening)
        }
    }

    val next = days
        .filter { it.date > today && (it.noon.isNotEmpty() || it.evening.isNotEmpty()) }
        .minByOrNull { it.date }
        ?: return null

    return if (next.noon.isNotEmpty()) {
        Service(next.date, "Midi" + dayLabel(next.date), next.noon)
    } else {
        Service(next.date, "Soir" + dayLabel(next.date), next.evening)
    }
}

private fun parseDays(json: String?): List<DayMenu> {
    if (json.isNullOrBlank()) return emptyList()

    return try {
        val array = JSONArray(json)
        (0 until array.length()).mapNotNull { i ->
            val o = array.optJSONObject(i) ?: return@mapNotNull null
            val date = o.optString("date")
            if (date.length != 10) null
            else DayMenu(date, parseItems(o.optJSONArray("noon")), parseItems(o.optJSONArray("evening")))
        }
    } catch (e: JSONException) {
        emptyList()
    }
}

private fun parseItems(array: JSONArray?): List<MenuItem> {
    if (array == null) return emptyList()

    return (0 until array.length()).mapNotNull { i ->
        val o = array.optJSONObject(i) ?: return@mapNotNull null
        val title = o.optString("title").trim()
        val elements = o.optJSONArray("elements")?.let { els ->
            (0 until els.length()).mapNotNull { j -> els.optString(j).trim().takeIf { it.isNotEmpty() } }
        }.orEmpty()

        if (title.isEmpty() && elements.isEmpty()) null else MenuItem(title, elements)
    }
}
