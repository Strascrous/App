import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:strascrous/api/restaurants.dart';
import 'package:strascrous/models/city.dart';

final CITIES = [
    // Académie de Strasbourg
    City("Strasbourg", "strasbourg", CityIcon.svg(name: "strasbourg")), // Le Bretzel miam l'Alsace
    City("Mulhouse", "mulhouse", CityIcon.svg(name: "mulhouse")), // Coeur industriel fût une époque
    City("Colmar", "colmar", CityIcon.svg(name: "colmar")), // La route des vins

    // Académie de Nancy-Metz
    City("Nancy", "nancy", CityIcon.builtin(icon: Icons.local_florist)), // Le chardon est l'emblème de Nancy
    City("Metz", "metz", CityIcon.svg(name: "metz")), // Graoully
    City("Épinal", "epinal", CityIcon.svg(name: "epinal")), // Imagerie d'Épinal
    City("Longwy", "longwy", CityIcon.builtin(icon: Icons.castle)), // Vauban
    City("Yutz", "yutz", CityIcon.builtin(icon: Icons.waves)), // Moselle

    // Bourgogne-Franche-Comté
    City("Belfort", "belfort", CityIcon.builtin(icon: Icons.pets)), // Lion de Belfort
    City("Besançon", "besancon", CityIcon.builtin(icon: Icons.watch)), // Capitale française de l'horlogerie
    City("Dijon", "dijon", CityIcon.svg(name: "dijon")), // Chouette de l'église Notre-Dame
    City("Le Creusot", "le.creusot", CityIcon.svg(name: "le.creusot")), // Marteau-Pilon de 100 tonnes = emblème de la ville
    City("Montbéliard", "montbeliard", CityIcon.builtin(icon: Icons.directions_car)), // Peugeot (Sochaux à coté)

    // Académie de Rennes
    City("Rennes", "rennes", CityIcon.builtin(icon: Icons.account_balance)), // Parlement de Bretagne
    City("Brest", "brest", CityIcon.builtin(icon: Icons.anchor)), // Port militaire
    City("Lannion", "lannion", CityIcon.builtin(icon: Icons.satellite_alt)), // radôme de Pleumeur-Bodou (première liaison satellite transatlantique)
    City("Lorient", "lorient", CityIcon.builtin(icon: Icons.sailing)), // Course au large
    City("Quimper", "quimper", CityIcon.svg(name: "quimper")), // faïence de Quimper
    City("Saint Brieuc", "saint.brieuc", CityIcon.svg(name: "saint.brieuc")), // Pêche
    City("Saint Malo", "saint.malo", CityIcon.svg(name: "saint.malo")), // Cité corsaire (Surcouf, Duguay-Trouin)
    City("Vannes", "vannes", CityIcon.svg(name: "vannes")), // Porte du golfe du Morbihan
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
