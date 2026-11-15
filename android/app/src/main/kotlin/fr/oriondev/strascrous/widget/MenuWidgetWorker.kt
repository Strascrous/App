package fr.oriondev.strascrous.widget

import android.content.Context
import android.util.Log
import androidx.glance.appwidget.GlanceAppWidgetManager
import androidx.glance.appwidget.state.getAppWidgetState
import androidx.glance.appwidget.state.updateAppWidgetState
import androidx.glance.state.PreferencesGlanceStateDefinition
import androidx.work.Constraints
import androidx.work.CoroutineWorker
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.ExistingWorkPolicy
import androidx.work.NetworkType
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.WorkerParameters
import java.util.concurrent.TimeUnit
import kotlinx.coroutines.CancellationException
import org.json.JSONArray

class MenuWidgetWorker(context: Context, params: WorkerParameters) : CoroutineWorker(context, params) {

    override suspend fun doWork(): Result {
        val glanceIds = GlanceAppWidgetManager(applicationContext).getGlanceIds(MenuWidget::class.java)
        val cache = mutableMapOf<String, JSONArray?>()
        var anyFailed = false

        for (glanceId in glanceIds) {
            val prefs = getAppWidgetState(applicationContext, PreferencesGlanceStateDefinition, glanceId)
            val restaurantId = prefs[MenuWidget.RESTAURANT_ID]

            if (restaurantId != null) {
                val menus = cache.getOrPut(restaurantId) { fetch(restaurantId) }
                if (menus == null) anyFailed = true

                updateAppWidgetState(applicationContext, glanceId) {
                    if (it[MenuWidget.RESTAURANT_ID] != restaurantId) return@updateAppWidgetState

                    if (menus != null) it[MenuWidget.MENUS] = menus.toString()
                    it[MenuWidget.FETCH_FAILED] = menus == null
                }
            }

            MenuWidget().update(applicationContext, glanceId)
        }

        return if (anyFailed && runAttemptCount < MAX_RETRIES) Result.retry() else Result.success()
    }

    private suspend fun fetch(restaurantId: String): JSONArray? = try {
        Api.fetchMenus(restaurantId)
    } catch (e: CancellationException) {
        throw e
    } catch (e: Exception) {
        Log.w(TAG, "Échec de la récupération des menus pour $restaurantId", e)
        null
    }

    companion object {
        private const val TAG = "MenuWidgetWorker"
        private const val MAX_RETRIES = 3
        private const val PERIODIC_WORK = "menu_widget_refresh"
        private const val IMMEDIATE_WORK = "menu_widget_refresh_now"

        private val networkConstraint = Constraints.Builder()
            .setRequiredNetworkType(NetworkType.CONNECTED)
            .build()

        fun schedule(context: Context) {
            val request = PeriodicWorkRequestBuilder<MenuWidgetWorker>(2, TimeUnit.HOURS)
                .setConstraints(networkConstraint)
                .build()
            WorkManager.getInstance(context)
                .enqueueUniquePeriodicWork(PERIODIC_WORK, ExistingPeriodicWorkPolicy.KEEP, request)
        }

        fun refreshNow(context: Context) {
            val request = OneTimeWorkRequestBuilder<MenuWidgetWorker>()
                .setConstraints(networkConstraint)
                .build()
            WorkManager.getInstance(context)
                .enqueueUniqueWork(IMMEDIATE_WORK, ExistingWorkPolicy.REPLACE, request)
        }

        fun cancel(context: Context) {
            WorkManager.getInstance(context).apply {
                cancelUniqueWork(PERIODIC_WORK)
                cancelUniqueWork(IMMEDIATE_WORK)
            }
        }
    }
}
