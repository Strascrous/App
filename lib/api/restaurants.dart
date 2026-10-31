import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart';
import 'package:strascrous/api/config.dart';


enum RestaurantType {
    restaurant('restaurant'),
    cafeteria('cafeteria');

    const RestaurantType(this.value);
    final String value;

    static RestaurantType fromJson(String s) =>
        RestaurantType.values.firstWhere(
            (e) => e.value == s,
            orElse: () => throw FormatException('unknown RestaurantType: $s'),
        );

    String toJson() => value;
}

class Restaurant {
    final String id;
    final String title;
    final RestaurantType type;

    const Restaurant({ required this.id, required this.title, required this.type });

    factory Restaurant.fromJson(Map<String, dynamic> json) {
        return switch (json) {
            { 'id': String id, 'title': String title, 'type': String type } => Restaurant(
                id: id,
                title: title,
                type: RestaurantType.fromJson(type)
            ),
            _ => throw const FormatException("Failed to load meal"),
        };
    }

    Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type.toJson(),
    };
}

Future<List<Restaurant>> fetchRestaurants(String city) async {
    final box = GetStorage();
    final uri = Uri.parse('$BASE_URL/restaurants').replace(queryParameters: {'city': city});
    final res = await get(uri);

    if (res.statusCode != 200) throw Exception('Erreur HTTP ${res.statusCode}');
    final body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;

    if (body['ok'] != true) throw Exception(body['message'] ?? 'Réponse invalide');
    final data = body['data'] as Map<String, dynamic>;
    final list = data['restaurants'] as List<dynamic>;

    final restaurants = list
        .map((item) => Restaurant.fromJson(item as Map<String, dynamic>))
        .toList();

    await box.write(
        'restaurants',
        restaurants.map((item) => item.toJson()).toList(),
    );

    return restaurants;
}

List<Restaurant> readRestaurants(RestaurantType? type) {
    final cached = GetStorage().read<List<dynamic>>('restaurants');

    if (cached == null) return [];

    if (type == null) {
        return cached
            .map((item) => Restaurant.fromJson(
                Map<String, dynamic>.from(item as Map),
            ))
            .toList();
    } else {
        return cached
            .map((item) => Restaurant.fromJson(
                Map<String, dynamic>.from(item as Map),
            ))
            .where((item) => item.type == type)
            .toList();
    }
}

Restaurant? getRestaurant(String id) {
    final restaurants = readRestaurants(null)
        .where((r) => r.id == id);

    if (restaurants.isEmpty) return null;
    return restaurants.first;
}
