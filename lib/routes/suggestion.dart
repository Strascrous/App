import 'package:flutter/material.dart';
import 'package:strascrous/utils/uri.dart';

class SuggestionPage extends StatelessWidget {
    const SuggestionPage({ super.key });

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text("Proposer une idée"),
                leading: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                ),
            ),
            body: ListView(
                children: [
                    ListTile(
                        leading: const Icon(Icons.email),
                        title: const Text("Par e-mail"),
                        subtitle: const Text("report@strascrous.fr"),
                        onTap: () => openUri(Uri(
                            scheme: "mailto",
                            path: "contact@strascrous.fr",
                            query: "subject=${Uri.encodeComponent("[Suggestion] Courte description de l'idée")}"
                                "&body=${Uri.encodeComponent("Décris l'idée ici\n\n")}",
                        ))
                    ),
                    ListTile(
                        leading: const SizedBox(
                            width: 24,
                            height: 24,
                            child: Center(
                                child: Text("🤓", style: TextStyle(fontSize: 20)),
                            ),
                        ),
                        title: const Text("Pour les nerds"),
                        subtitle: const Text("Tu peux faire une issue GitHub directement"),
                        onTap: () => openUri(Uri.parse("https://github.com/Strascrous/App/issues"))
                    ),
                ],
            ),
        );
    }
}
