package fr.oriondev.strascrous.widget

import android.appwidget.AppWidgetManager
import android.content.Intent
import android.os.Build
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.clickable
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyListScope
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Button
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ListItem
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.glance.appwidget.GlanceAppWidgetManager
import androidx.glance.appwidget.state.updateAppWidgetState
import es.antonborri.home_widget.HomeWidgetPlugin
import fr.oriondev.strascrous.MainActivity
import kotlinx.coroutines.launch

class MenuWidgetConfigActivity : ComponentActivity() {

    private var appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID

    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)

        appWidgetId = intent?.extras?.getInt(
            AppWidgetManager.EXTRA_APPWIDGET_ID,
            AppWidgetManager.INVALID_APPWIDGET_ID,
        ) ?: AppWidgetManager.INVALID_APPWIDGET_ID

        setResult(RESULT_CANCELED, resultIntent())
        if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            finish()
            return
        }

        val restaurants = RestaurantLite.listFromJson(
            HomeWidgetPlugin.getData(this).getString("restaurants", null),
        )

        setContent {
            ConfigTheme {
                ConfigScreen(restaurants)
            }
        }
    }

    private fun resultIntent() = Intent().putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
    private suspend fun select(restaurant: RestaurantLite) {
        val glanceId = GlanceAppWidgetManager(this).getGlanceIdBy(appWidgetId)

        updateAppWidgetState(applicationContext, glanceId) {
            if (it[MenuWidget.RESTAURANT_ID] != restaurant.id) it.remove(MenuWidget.MENUS)
            it[MenuWidget.RESTAURANT_ID] = restaurant.id
            it[MenuWidget.RESTAURANT_TITLE] = restaurant.title
            it[MenuWidget.RESTAURANT_TYPE] = restaurant.type
            it[MenuWidget.FETCH_FAILED] = false
        }

        MenuWidget().update(applicationContext, glanceId)
        MenuWidgetWorker.schedule(applicationContext)
        MenuWidgetWorker.refreshNow(applicationContext)

        setResult(RESULT_OK, resultIntent())
        finish()
    }

    private fun openApp() {
        startActivity(
            Intent(this, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
        )
        finish()
    }

    @OptIn(ExperimentalMaterial3Api::class)
    @Composable
    private fun ConfigScreen(restaurants: List<RestaurantLite>) {
        val scope = rememberCoroutineScope()
        var selecting by remember { mutableStateOf(false) }

        Scaffold(
            topBar = { TopAppBar(title = { Text("Choisis ton restaurant") }) },
        ) { padding ->
            if (restaurants.isEmpty()) {
                EmptyState(Modifier.padding(padding))
                return@Scaffold
            }

            val (cafeterias, restos) = restaurants.partition { it.isCafeteria }
            LazyColumn(
                modifier = Modifier.fillMaxSize(),
                contentPadding = padding,
            ) {
                section("Resto U'", restos, selecting) { restaurant ->
                    selecting = true
                    scope.launch { select(restaurant) }
                }
                section("Cafétérias", cafeterias, selecting) { restaurant ->
                    selecting = true
                    scope.launch { select(restaurant) }
                }
            }
        }
    }

    private fun LazyListScope.section(
        title: String,
        restaurants: List<RestaurantLite>,
        disabled: Boolean,
        onClick: (RestaurantLite) -> Unit,
    ) {
        if (restaurants.isEmpty()) return

        item(key = "header-$title") {
            Text(
                text = title,
                style = MaterialTheme.typography.titleSmall,
                color = MaterialTheme.colorScheme.primary,
                modifier = Modifier.padding(start = 16.dp, end = 16.dp, top = 16.dp, bottom = 8.dp),
            )
        }
        items(restaurants, key = { it.id }) { restaurant ->
            ListItem(
                headlineContent = { Text(restaurant.title) },
                modifier = Modifier.clickable(enabled = !disabled) { onClick(restaurant) },
            )
        }
    }

    @Composable
    private fun EmptyState(modifier: Modifier = Modifier) {
        Column(
            modifier = modifier
                .fillMaxSize()
                .padding(24.dp),
            verticalArrangement = Arrangement.Center,
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            Text(
                text = "Aucun restaurant disponible",
                style = MaterialTheme.typography.titleMedium,
            )
            Spacer(Modifier.height(8.dp))
            Text(
                text = "Ouvre l'application et choisis ta ville, puis ajoute à nouveau le widget.",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                textAlign = TextAlign.Center,
            )
            Spacer(Modifier.height(24.dp))
            Button(onClick = ::openApp) { Text("Ouvrir Strascrous") }
        }
    }
}

@Composable
private fun ConfigTheme(content: @Composable () -> Unit) {
    val dark = isSystemInDarkTheme()
    val colorScheme = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        val context = LocalContext.current
        if (dark) dynamicDarkColorScheme(context) else dynamicLightColorScheme(context)
    } else {
        if (dark) darkColorScheme() else lightColorScheme()
    }

    MaterialTheme(colorScheme = colorScheme, content = content)
}
