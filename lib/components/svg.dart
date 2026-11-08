import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class IconSvg extends StatelessWidget {
    const IconSvg(this.path, { super.key, this.alt });
    final String path;
    final String? alt;

    @override
    Widget build(BuildContext context) {
        return SvgPicture.asset(
            'assets/icons/$path.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.onSurfaceVariant,
                BlendMode.srcIn,
            ),
            semanticsLabel: alt,
        );
    }
}
