import 'package:flutter/material.dart';
import 'package:strascrous/utils/uri.dart';

class BugPage extends StatelessWidget {
    const BugPage({ super.key });

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text("Signaler un bug"),
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
                            path: "report@strascrous.fr",
                            query: "subject=${Uri.encodeComponent("[Bug] Courte description du bug")}"
                                "&body=${Uri.encodeComponent("Décris le bug ici (ce que tu faisais, ce qui s'est passé, ce que tu attendais)\n\n")}",
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
