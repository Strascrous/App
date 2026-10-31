import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class City {
    String name = '';
    String id = "";
    CityIcon? icon;

    City(this.name, this.id, this.icon);
}


enum CityIconSource {
    builtin,
    svg,
}

class CityIcon extends StatelessWidget {
    final CityIconSource source;
    final IconData? icon;
    final String? name;

    const CityIcon.builtin({
        super.key,
        required IconData this.icon,
    })  : source = CityIconSource.builtin, name = null;

    const CityIcon.svg({
        super.key,
        required String this.name,
    })  : source = CityIconSource.svg, icon = null;

    @override
    Widget build(BuildContext context) {
        if (source == CityIconSource.builtin) {
            return Icon(icon);
        }

        return SvgPicture.asset(
            'assets/icons/cities/$name.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.onSurfaceVariant,
                BlendMode.srcIn,
            ),
        );
    }
}
