import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:strascrous/api/restaurants.dart';
import 'package:strascrous_data/data.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
    final SearchController _searchController = SearchController();
    final _distanceRevision = ValueNotifier<int>(0);
    final _box = GetStorage();
    int? selectedCity;

    @override
    void dispose() {
        _searchController.dispose();
        _distanceRevision.dispose();
        super.dispose();
    }

    void _selectCity(int city) {
        _searchController.closeView(cities[city].name);

        setState(() {
            selectedCity = city;
        });
    }

    void _submit() async {
        final id = cities[selectedCity ?? 0].id;

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

    void _useLocation() async {
        bool serviceEnabled;
        LocationPermission permission;

        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) return; // TODO: Snackbar

        permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
            if (permission == LocationPermission.denied) {
                // TODO: Snackbar
                return;
            }
        }

        if (permission == LocationPermission.deniedForever) {
            // TODO: Snackbar
            return;
        }

        final position = await Geolocator.getCurrentPosition();
        if (!mounted) return;

        setState(() {
            for (final city in cities) {
                city.location.distanceTo(position.latitude, position.longitude);
            }

            _distanceRevision.value++;
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
                        barTrailing: [
                            IconButton(
                                icon: Icon(Icons.location_pin),
                                onPressed: _useLocation,
                            ),
                        ],
                        viewTrailing: [
                            IconButton(
                                icon: Icon(Icons.location_pin),
                                onPressed: _useLocation,
                            ),
                        ],

                        suggestionsBuilder: (context, controller) {
                            return [
                                ValueListenableBuilder<int>(
                                    valueListenable: _distanceRevision,
                                    builder: (context, revision, child) {
                                        final query = controller.text.trim().toLowerCase();

                                        final results = cities.where((city) {
                                            return city.name.toLowerCase().contains(query);
                                        }).toList();

                                        if (results.isEmpty) {
                                            if (results.isEmpty) {
                                                return const ListTile(
                                                    leading: Icon(Icons.search_off),
                                                    title: Text('Aucune ville trouvée'),
                                                );
                                            }
                                        }

                                        if (results.any((city) => city.location.distance != null)) {
                                            results.sort((a, b) {
                                                final distanceA = a.location.distance;
                                                final distanceB = b.location.distance;

                                                if (distanceA == null) return distanceB == null ? 0 : 1;
                                                if (distanceB == null) return -1;

                                                return distanceA.compareTo(distanceB);
                                            });
                                        }

                                        return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: results.map((city) {
                                                return ListTile(
                                                    leading: city.icon,
                                                    trailing: city.location.distance != null ?
                                                        Text("${city.location.distance!.toStringAsFixed(2)} km"):SizedBox(),
                                                    title: Text(city.name),
                                                    onTap: () => _selectCity(cities.indexOf(city)),
                                                );
                                            }).toList(),
                                        );
                                    }
                                )
                            ];
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
            onPressed: _submit,
            child: Icon(Icons.check)
        );
    }
}
