import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:go_router/go_router.dart';
import 'package:strascrous/models/city.dart';

final cities = [
    City("Strasbourg", 1, CityIcon.svg(name: "strasbourg")),
    City("Mulhouse", 2, CityIcon.svg(name: "mulhouse")),
    City("Colmar", 3, CityIcon.svg(name: "colmar")),
];

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
    final SearchController _searchController = SearchController();
    int? selectedCity;

    @override
    void dispose() {
        _searchController.dispose();
        super.dispose();
    }

    void selectCity(int city) {
        _searchController.closeView(cities[city].name);

        setState(() {
            selectedCity = city;
        });
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text("Où étudies-tu ?"),
            ),
            body: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16),
                children: [
                     const Text(
                         "Choisis ta ville pour retrouver les restaurants universitaires et les services à proximité.",
                         textScaler: TextScaler.linear(1.2),
                     ),
                     SizedBox(height: 24),
                     SearchAnchor.bar(
                        searchController: _searchController,
                        barHintText: "Rechercher une ville",
                        barLeading: const Icon(Icons.search),

                        suggestionsBuilder: (context, controller) {
                            final query = controller.text.trim().toLowerCase();

                            final results = cities.where((city) {
                                return city.name.toLowerCase().contains(query);
                            }).toList();

                            if (results.isEmpty) {
                                return [
                                    const ListTile(
                                        leading: Icon(Icons.search_off),
                                        title: Text('Aucune ville trouvée'),
                                    ),
                                ];
                            }

                            return results.mapIndexed((i, city) {
                                return ListTile(
                                    leading: city.icon,
                                    title: Text(city.name),
                                    onTap: () => selectCity(i),
                                );
                            }).toList();
                        },
                    ),
                    if (selectedCity != null) ...[
                        const SizedBox(height: 24),
                        ListTile(
                            leading: cities[selectedCity!].icon,
                            title: Text(cities[selectedCity!].name),
                            trailing: Icon(Icons.check),
                            subtitle: const Text('Ville sélectionnée'),
                        ),
                    ],
                ],
            ),
            floatingActionButton: _FAB(context),
        );
    }

    Widget _FAB(BuildContext context) {
        if (selectedCity == null) return Container();

        return FloatingActionButton(
            onPressed: () => GoRouter.of(context).go("/uwu"),
            child: Icon(Icons.check)
        );
    }
}
