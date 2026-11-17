import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:strascrous/api/restaurants.dart';

Future<void> syncWidgetRestaurants(List<Restaurant> restaurants) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;

    try {
        await HomeWidget.saveWidgetData<String>(
            'restaurants',
            jsonEncode(restaurants
                .map((r) => {'id': r.id, 'title': r.title, 'type': r.type.toJson()})
                .toList()),
        );
        await HomeWidget.updateWidget(
            qualifiedAndroidName: 'fr.strascrous.app.widget.MenuWidgetReceiver',
        );
    } catch (e) {
        debugPrint('Synchronisation du widget impossible : $e');
    }
}
