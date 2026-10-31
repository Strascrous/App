import 'dart:convert';

import 'package:http/http.dart';
import 'package:strascrous/api/config.dart';

class MenusItem {
    final String date;
    final List<MenuItem> noon;
    final List<MenuItem> evening;

    const MenusItem({ required this.date, required this.noon, required this.evening });

    factory MenusItem.fromJson(Map<String, dynamic> json) {
        return switch (json) {
            {
                'date': String date,
                'noon': List<dynamic> noon,
                'evening': List<dynamic> evening,
            } =>
                MenusItem(
                    date: date,
                    noon: noon
                        .map((item) => MenuItem.fromJson(item as Map<String, dynamic>))
                        .toList(),
                    evening: evening
                        .map((item) => MenuItem.fromJson(item as Map<String, dynamic>))
                        .toList(),
                ),
                _ => throw const FormatException("Failed to load meal"),
        };
      }
}

class MenuItem {
    final String title;
    final List<String> elements;

    const MenuItem({ required this.title, required this.elements });

    factory MenuItem.fromJson(Map<String, dynamic> json) {
        return switch (json) {
            {
                'title': String title,
                'elements': List<dynamic> elements,
            } => MenuItem(
                title: title,
                elements: List<String>.from(elements),
            ),
            _ => throw const FormatException("Failed to load menu"),
        };
    }
}

Future<List<MenusItem>> fetchMenu(String id) async {
    final uri = Uri.parse('$BASE_URL/restaurants/$id');
    final res = await get(uri);

    if (res.statusCode != 200) throw Exception('Erreur HTTP ${res.statusCode}');
    final body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;

    if (body['ok'] != true) throw Exception(body['message'] ?? 'Réponse invalide');
    final data = body['data'] as Map<String, dynamic>;
    final list = data['menus'] as List<dynamic>;

    final menus = list
        .map((item) => MenusItem.fromJson(item as Map<String, dynamic>))
        .toList();

    return menus;
}
