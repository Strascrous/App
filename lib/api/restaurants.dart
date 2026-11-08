import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart';
import 'package:strascrous/api/config.dart';

class Restaurant {
    final String id;
    final String title;
    final String description;
    final RestaurantType type;
    final RestaurantDetails details;

    const Restaurant({ required this.id, required this.title, required this.description,
        required this.type, required this.details });

    factory Restaurant.fromJson(Map<String, dynamic> json) {
        return switch (json) {
            { 'id': String id, 'title': String title, 'description': String description,
                'type': String type, 'details': Map<String, dynamic> details } => Restaurant(
                id: id,
                title: title,
                description: description,
                type: RestaurantType.fromJson(type),
                details: RestaurantDetails.fromJson(details)
            ),
            _ => throw const FormatException("Failed to load restaurant"),
        };
    }

    Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type.toJson(),
        'details': details.toJson(),
    };
}

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

class RestaurantDetails {
    final String hours;
    final String address;
    final String access;
    final List<Payment> payments;
    final List<String> additionalPayments;
    final bool wifi;
    final bool pmr;

    const RestaurantDetails({
        required this.hours, required this.address, required this.access,
        required this.payments, required this.additionalPayments,
        required this.wifi, required this.pmr
    });

    factory RestaurantDetails.fromJson(Map<String, dynamic> json) {
        return switch (json) {
            { 'hours': String hours, 'address': String address, 'access': String access,
                'payments': List<dynamic> payments, 'additional_payments': List<dynamic> additionalPayments,
                'wifi': bool wifi, 'pmr': bool pmr } => RestaurantDetails(
                hours: hours,
                address: address,
                access: access,
                payments: payments
                    .map((value) => Payment.fromJson(value as String))
                    .toList(),
                additionalPayments: List<String>.from(additionalPayments),
                wifi: wifi,
                pmr: pmr
            ),
            _ => throw const FormatException("Failed to load RestaurantDetails"),
        };
    }

    Map<String, dynamic> toJson() => {
        'hours': hours,
        'address': address,
        'access': access,
        'payments': payments.map((payment) => payment.toJson()).toList(),
        'additional_payments': additionalPayments,
        'wifi': wifi,
        'pmr': pmr,
    };
}

enum Payment {
    izly('izly'),
    card('cb'),
    cash('espece'),
    moneo('moneo');

    const Payment(this.value);
    final String value;

    static Payment fromJson(String s) =>
        Payment.values.firstWhere(
            (e) => e.value == s,
            orElse: () => throw FormatException('unknown Payment: $s'),
        );

    String toJson() => value;
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
