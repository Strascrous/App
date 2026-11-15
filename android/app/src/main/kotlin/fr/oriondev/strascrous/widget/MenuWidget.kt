package fr.oriondev.strascrous.widget

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.GlanceTheme
import androidx.glance.action.Action
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.action.actionStartActivity
import androidx.glance.appwidget.appWidgetBackground
import androidx.glance.appwidget.cornerRadius
import androidx.glance.appwidget.lazy.LazyColumn
import androidx.glance.appwidget.lazy.items
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.currentState
import androidx.glance.layout.Alignment
import androidx.glance.layout.Column
import androidx.glance.layout.ColumnScope
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.width
import androidx.glance.state.GlanceStateDefinition
import androidx.glance.state.PreferencesGlanceStateDefinition
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import fr.oriondev.strascrous.MainActivity
import java.text.SimpleDateFormat
import java.util.Locale

class MenuWidget : GlanceAppWidget() {
    companion object {
        val RESTAURANT_ID = stringPreferencesKey("restaurant_id")
        val RESTAURANT_TITLE = stringPreferencesKey("restaurant_title")
        val RESTAURANT_TYPE = stringPreferencesKey("restaurant_type")
        val MENUS = stringPreferencesKey("menus")
        val FETCH_FAILED = booleanPreferencesKey("fetch_failed")
    }

    override val stateDefinition: GlanceStateDefinition<*> = PreferencesGlanceStateDefinition

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            GlanceTheme {
                Content(context, currentState())
            }
        }
    }

    @Composable
    private fun Content(context: Context, prefs: Preferences) {
        val restaurantId = prefs[RESTAURANT_ID]
        val menus = prefs[MENUS]
        val service = pickService(menus)
        val openApp = actionStartActivity(openAppIntent(context, prefs))

        Column(
            modifier = GlanceModifier
                .fillMaxSize()
                .appWidgetBackground()
                .background(GlanceTheme.colors.widgetBackground)
                .widgetCornerRadius()
                .padding(horizontal = 16.dp, vertical = 14.dp)
                .clickable(openApp),
        ) {
            Header(
                title = prefs[RESTAURANT_TITLE] ?: "Strascrous",
                date = service?.date?.let(::formatDate),
            )

            when {
                service != null -> Menu(service, openApp)
                restaurantId == null -> Message("Aucun restaurant sélectionné")
                menus == null && prefs[FETCH_FAILED] == true -> Message("Menu indisponible, nouvel essai bientôt")
                menus == null -> Message("Chargement du menu…")
                else -> Message("Pas de menu prévu pour le moment")
            }
        }
    }

    @Composable
    private fun Header(title: String, date: String?) {
        Row(
            modifier = GlanceModifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text(
                text = title,
                maxLines = 1,
                modifier = GlanceModifier.defaultWeight(),
                style = TextStyle(
                    color = GlanceTheme.colors.onSurface,
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Medium,
                ),
            )
            if (date != null) {
                Spacer(GlanceModifier.width(8.dp))
                Text(
                    text = date,
                    maxLines = 1,
                    style = TextStyle(
                        color = GlanceTheme.colors.primary,
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Medium,
                    ),
                )
            }
        }
    }

    @Composable
    private fun ColumnScope.Menu(service: Service, onClick: Action) {
        val rows = flattenMenu(service.items)

        LazyColumn(GlanceModifier.fillMaxWidth().defaultWeight()) {
            items(rows) { row ->
                when (row) {
                    is MenuRow.Section -> Text(
                        text = row.title.uppercase(Locale.FRENCH),
                        maxLines = 1,
                        modifier = GlanceModifier.fillMaxWidth().padding(top = SECTION_GAP).clickable(onClick),
                        style = TextStyle(
                            color = GlanceTheme.colors.primary,
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Medium,
                        ),
                    )
                    is MenuRow.Line -> Text(
                        text = row.text,
                        maxLines = 1,
                        modifier = GlanceModifier.fillMaxWidth().padding(top = 2.dp).clickable(onClick),
                        style = TextStyle(color = GlanceTheme.colors.onSurface, fontSize = 14.sp),
                    )
                }
            }
        }
    }

    @Composable
    private fun Message(text: String) {
        Spacer(GlanceModifier.height(SECTION_GAP))
        Text(
            text = text,
            style = TextStyle(color = GlanceTheme.colors.onSurfaceVariant, fontSize = 14.sp),
        )
    }
}

private val SECTION_GAP = 8.dp

private sealed interface MenuRow {
    data class Section(val title: String) : MenuRow
    data class Line(val text: String) : MenuRow
}

private fun isCafeteria(title: String) =
    title.lowercase(Locale.FRENCH).let { "cafétéria" in it || "cafeteria" in it }
private fun isEmptyLine(line: String) = line.isBlank() || line.trim() in setOf("-", "–", "—")

private fun flattenMenu(items: List<MenuItem>): List<MenuRow> =
    items
        .filterNot { isCafeteria(it.title) }
        .map { it.title.trim() to it.elements.map(String::trim).filterNot(::isEmptyLine) }
        .filter { (_, lines) -> lines.isNotEmpty() }
        .flatMap { (title, lines) -> listOf(MenuRow.Section(title)) + lines.map(MenuRow::Line) }

private fun formatDate(date: String): String = try {
    val parsed = SimpleDateFormat("yyyy-MM-dd", Locale.FRENCH).parse(date.take(10))!!
    SimpleDateFormat("EEE d MMM", Locale.FRENCH).format(parsed)
} catch (e: Exception) {
    date
}

private fun GlanceModifier.widgetCornerRadius(): GlanceModifier =
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        cornerRadius(android.R.dimen.system_app_widget_background_radius)
    } else {
        cornerRadius(20.dp)
    }

private fun openAppIntent(context: Context, prefs: Preferences): Intent =
    Intent(context, MainActivity::class.java).apply {
        val id = prefs[MenuWidget.RESTAURANT_ID]
        if (id != null) {
            val path = if (prefs[MenuWidget.RESTAURANT_TYPE] == "cafeteria") "cafeteria" else "resto"
            data = Uri.parse("strascrous://app/$path?id=${Uri.encode(id)}")
        }
        flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
    }

class MenuWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = MenuWidget()

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        super.onUpdate(context, appWidgetManager, appWidgetIds)
        MenuWidgetWorker.schedule(context)
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
        MenuWidgetWorker.cancel(context)
    }
}
