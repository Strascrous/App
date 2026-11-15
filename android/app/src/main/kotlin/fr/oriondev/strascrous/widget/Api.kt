package fr.oriondev.strascrous.widget

import android.net.Uri
import fr.oriondev.strascrous.BuildConfig
import java.io.IOException
import java.net.HttpURLConnection
import java.net.URL
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONArray
import org.json.JSONObject

object Api {
    val BASE_URL =
        if (BuildConfig.DEBUG) "http://10.0.2.2:3000" else "https://api.strascrous.fr"

    private const val CONNECT_TIMEOUT_MS = 10_000
    private const val READ_TIMEOUT_MS = 15_000

    suspend fun fetchMenus(restaurantId: String): JSONArray {
        val url = URL("$BASE_URL/restaurants/${Uri.encode(restaurantId)}")

        val body = withContext(Dispatchers.IO) {
            val connection = url.openConnection() as HttpURLConnection
            try {
                connection.requestMethod = "GET"
                connection.connectTimeout = CONNECT_TIMEOUT_MS
                connection.readTimeout = READ_TIMEOUT_MS
                connection.setRequestProperty("Accept", "application/json")

                val code = connection.responseCode
                if (code != HttpURLConnection.HTTP_OK) {
                    throw IOException("HTTP $code on $url")
                }

                connection.inputStream.bufferedReader(Charsets.UTF_8).use { it.readText() }
            } finally {
                connection.disconnect()
            }
        }

        val json = JSONObject(body)
        if (!json.optBoolean("ok")) {
            throw IOException("ok=false on $url")
        }
        return json.getJSONObject("data").getJSONArray("menus")
    }
}
