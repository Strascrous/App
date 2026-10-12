import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Navigation extends StatelessWidget {
    final StatefulNavigationShell navigationShell;

    const Navigation({
        super.key,
        required this.navigationShell,
    });

    @override
    Widget build(BuildContext context) {
        return BottomNavigationBar(
            currentIndex: navigationShell.currentIndex,
            onTap: (index) {
                navigationShell.goBranch(index);
            },
            items: [
                BottomNavigationBarItem(
                    icon: Icon(Icons.restaurant),
                    label: "Resto U'",
                ),
                BottomNavigationBarItem(
                    icon: Icon(Icons.local_cafe),
                    label: "Cafétéria",
                ),
                BottomNavigationBarItem(
                    icon: Icon(Icons.settings),
                    label: "Paramètres",
                ),
            ],
        );
    }
}
