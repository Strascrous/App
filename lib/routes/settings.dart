import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:strascrous/providers/theme_provider.dart';
import 'package:strascrous/routes/root.dart';

class SettingsPage extends StatefulWidget {
    const SettingsPage({super.key});

    @override
    State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
    final box = GetStorage();

    IconData _getThemeIcon(ThemeMode theme) {
        switch (theme) {
            case ThemeMode.dark:
                return Icons.dark_mode;
            case ThemeMode.light:
                return Icons.light_mode;
            case ThemeMode.system:
                return Icons.brightness_auto;
        }
    }

    String _getCityName() {
        String cityId = box.read('city');
        int index = CITIES.indexWhere((c) => c.id == cityId);

        if (index == -1) return "Inconnue";
        return CITIES[index].name;
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text("Paramètres"),
            ),
            body: ListView(
                children: [
                    ListTile(
                        leading: Icon(Icons.location_on),
                        title: const Text("Ville"),
                        subtitle: Text(_getCityName()),
                        onTap: () => GoRouter.of(context).go("/"),
                    ),
                    ListTile(
                        leading: Icon(
                            _getThemeIcon(context.watch<ThemeProvider>().themeMode),
                        ),
                        title: const Text('Thème'),
                        subtitle: const Text("Cliquez pour sélectionner un autre thème"),
                        onTap: () => _openThemeSelector(context),
                    )
                ],
            ),
        );
    }

    Future<void> _openThemeSelector(BuildContext context) async {
        ThemeMode theme = context.read<ThemeProvider>().themeMode;

        void _selectTheme(ThemeMode mode) {
            context.read<ThemeProvider>().setThemeMode(mode);
            Navigator.pop(context);
        }

        showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Padding(
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                            child: Text(
                                'Choisir un thème',
                                style: Theme.of(context).textTheme.titleLarge,
                            ),
                        ),
                        Expanded(
                            child: ListView(
                                children: [
                                    ListTile(
                                        leading: Icon(Icons.brightness_auto),
                                        title: Text("Automatique"),
                                        subtitle: Text("Choix du thème selon le thème système"),
                                        selected: theme == ThemeMode.system,
                                        trailing: _selectedTrailing(theme == ThemeMode.system),
                                        onTap: () => _selectTheme(ThemeMode.system),
                                    ),
                                    ListTile(
                                        leading: Icon(Icons.dark_mode),
                                        title: Text("Sombre"),
                                        subtitle: Text("Thème sombre"),
                                        selected: theme == ThemeMode.dark,
                                        trailing: _selectedTrailing(theme == ThemeMode.dark),
                                        onTap: () => _selectTheme(ThemeMode.dark)
                                    ),
                                    ListTile(
                                        leading: Icon(Icons.light_mode),
                                        title: Text("Clair"),
                                        subtitle: Text("Thème clair"),
                                        selected: theme == ThemeMode.light,
                                        trailing: _selectedTrailing(theme == ThemeMode.light),
                                        onTap: () => _selectTheme(ThemeMode.light)
                                    ),
                                ],
                            ),
                        ),
                    ],
                );
            }
        );
    }

    Widget? _selectedTrailing(bool selected) {
        if (!selected) return null;

        return Icon(
            Icons.check_circle,
            color: Theme.of(context).colorScheme.primary,
        );
    }
}
