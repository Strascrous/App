import 'package:flutter/material.dart';
import 'package:strascrous/components/svg.dart';
import 'package:strascrous/utils/uri.dart';

class CreditsPage extends StatefulWidget {
    const CreditsPage({super.key});

    @override
    State<CreditsPage> createState() => _CreditsPageState();
}

class _CreditsPageState extends State<CreditsPage> {
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text("Crédits"),
                leading: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                ),
            ),
            body: ListView(
                children: [
                    SectionHeader(icon: Icons.code, title: "Développement"),
                    ListTile(
                        title: const Text("Orion"),
                        subtitle: const Text("Développeur principale du projet"),
                        leading: Image(
                            image: NetworkImage("https://oriondev.fr/favicon.png"),
                            width: 32,
                            height: 32,
                        ),
                        onTap: () => openUri(Uri.parse("https://oriondev.fr")),
                    ),

                    SizedBox(height: 8),
                    SectionHeader(icon: Icons.image, title: "Icônes"),
                    ListTile(
                        title: const Text("Material Design Icons"),
                        subtitle: const Text("Certaines icônes utilisées pour les villes"),
                        leading: IconSvg("credits/mdi", alt: "Material Desgin Icons"),
                        onTap: () => openUri(Uri.parse("https://pictogrammers.com/library/mdi/")),
                    ),
                ],
            ),
        );
    }
}

class SectionHeader extends StatelessWidget {
    const SectionHeader({super.key, required this.icon, required this.title});

    final IconData icon;
    final String title;

    @override
    Widget build(BuildContext context) {
        final theme = Theme.of(context);
        return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
                children: [
                    Icon(icon, size: 20, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                        title,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(color: theme.colorScheme.primary),
                    ),
                ],
            ),
        );
    }
}
