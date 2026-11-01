import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:strascrous/api/restaurants.dart';
import 'package:strascrous/components/navigation.dart';
import 'package:strascrous/providers/theme_provider.dart';
import 'package:strascrous/routes/menu.dart';
import 'package:strascrous/routes/root.dart';
import 'package:strascrous/routes/settings.dart';

Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting('fr_FR');
    await GetStorage.init();

    runApp(const App());
}

class App extends StatefulWidget {
    const App({super.key});

    @override
    State<App> createState() => _AppState();
}

class _AppState extends State<App> {
    static final _defaultLightColorScheme = ColorScheme.fromSeed(
        seedColor:  Colors.blueAccent,
        brightness: Brightness.light,
    );

    static final _defaultDarkColorScheme = ColorScheme.fromSeed(
        seedColor:  Colors.blueAccent,
        brightness: Brightness.dark,
    );

    @override
    Widget build(BuildContext context) {
        return ChangeNotifierProvider(
            create: (context) => ThemeProvider(),
            child: Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
                        return MaterialApp.router(
                            title: "Strascrous",
                            theme: ThemeData(
                                colorScheme: lightColorScheme ?? _defaultLightColorScheme,
                                useMaterial3: true,
                            ),
                            darkTheme: ThemeData(
                                colorScheme: darkColorScheme ?? _defaultDarkColorScheme,
                                useMaterial3: true,
                            ),
                            themeMode: themeProvider.themeMode,
                            routerConfig: router
                        );
                    });
                }
            )
        );
    }
}

Widget _buildMenuPage(GoRouterState state, RestaurantType type) {
    final id = state.uri.queryParameters['id'];
    final restaurants = readRestaurants(type);

    if (id == null && restaurants.isEmpty) {
        return Scaffold(
            appBar: AppBar(
                title: Text(type == RestaurantType.cafeteria ? 'Cafétéria' : "Resto U'"),
            ),
            body: Center(
                child: Text(type == RestaurantType.cafeteria
                    ? "Aucune cafétéria n'est disponible dans cette ville."
                    : "Aucun restaurant n'est disponible dans cette ville."),
            ),
        );
    }

    return MenuPage(
        id: id ?? restaurants.first.id,
        type: type,
    );
}

// TODO: stockage de la dernière route
final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
        GoRoute(
            path: '/',
            builder: (context, state) => const RootPage(),
        ),
        StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
                return Scaffold(
                    body: navigationShell,
                    bottomNavigationBar: Navigation(
                        navigationShell: navigationShell,
                    ),
                );
            },
            branches: [
                StatefulShellBranch(
                    routes: [
                        GoRoute(
                            path: '/resto',
                            builder: (context, state) => _buildMenuPage(
                                state,
                                RestaurantType.restaurant,
                            ),
                        ),
                    ],
                ),
                StatefulShellBranch(
                    routes: [
                        GoRoute(
                            path: '/cafeteria',
                            builder: (context, state) => _buildMenuPage(
                                state,
                                RestaurantType.cafeteria,
                            ),
                        ),
                    ],
                ),
                StatefulShellBranch(
                    routes: [
                        GoRoute(
                            path: '/settings',
                            builder: (context, state) => const SettingsPage(),
                        ),
                    ],
                ),
            ],
        ),
    ]
);
