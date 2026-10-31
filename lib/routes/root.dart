import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:strascrous/api/restaurants.dart';
import 'package:strascrous/models/city.dart';

final CITIES = [
    // Académie de Strasbourg
    City("Strasbourg", "strasbourg", CityIcon.svg(name: "strasbourg")),
    City("Mulhouse", "mulhouse", CityIcon.svg(name: "mulhouse")),
    City("Colmar", "colmar", CityIcon.svg(name: "colmar")),

    // Académie de Nancy-Metz
    City("Nancy", "nancy", CityIcon.builtin(icon: Icons.location_city))
];

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
    final SearchController _searchController = SearchController();
    final _box = GetStorage();
    int? selectedCity;

    @override
    void dispose() {
        _searchController.dispose();
        super.dispose();
    }

    void selectCity(int city) {
        _searchController.closeView(CITIES[city].name);

        setState(() {
            selectedCity = city;
        });
    }

    void submit() async {
        final id = CITIES[selectedCity ?? 0].id;

        try {
            final restaurants = await fetchRestaurants(id);
            if (!mounted) return;

            if (restaurants.isEmpty) {
                // TODO: Snackbar
                return;
            }

            await _box.write('city', id);
            if (!mounted) return;
            final restaurant = restaurants.first;
            if (restaurant.type == RestaurantType.cafeteria) return context.go('/cafeteria?id=${restaurants[0].id}');
            context.go('/resto?id=${restaurants[0].id}');
        } catch (e) {
            if (!mounted) return;
            print(e);
            // TODO: Snackbar
        }
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

                            final results = CITIES.where((city) {
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
                            leading: CITIES[selectedCity!].icon,
                            title: Text(CITIES[selectedCity!].name),
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
            onPressed: submit,
            child: Icon(Icons.check)
        );
    }
}
