import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:strascrous/api/restaurants.dart';
import 'package:strascrous/components/menu.dart';

class MenuPage extends StatefulWidget {
    const MenuPage({
        super.key,
        required this.id,
        required this.type
    });

    final String id;
    final RestaurantType type;

    @override
    State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
    Restaurant? get restaurant => getRestaurant(widget.id);
    final _pageController = PageController();

    @override
    void dispose() {
        _pageController.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                titleSpacing: 8,
                title: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => openSelector(context),
                    child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                                Flexible(
                                    child: Text(
                                        restaurant!.title,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.keyboard_arrow_down),
                            ],
                        )
                    )
                ),
            ),
            body: Pages(
                id: widget.id,
                pageController: _pageController,
            ),
        );
    }

    // TODO: refresh restaurants list
    Future<void> openSelector(BuildContext context) async {
        final restaurants = readRestaurants(widget.type);

        final selectedId = await showModalBottomSheet<String>(
            context: context,
            builder: (BuildContext context) {
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Padding(
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                            child: Text(
                                'Choisir un restaurant',
                                style: Theme.of(context).textTheme.titleLarge,
                            ),
                        ),
                        Expanded(
                            child: ListView(
                                children: restaurants
                                    .map((item) => RestaurantSelectItem(
                                        item: item,
                                        currentId: widget.id,
                                    )).toList()
                            ),
                        ),
                    ],
                );
            }
        );

        if (!context.mounted || selectedId == null || selectedId == widget.id) return;

        final uri = GoRouterState.of(context).uri;
        context.replace(
            uri.replace(
                queryParameters: {
                    ...uri.queryParametersAll,
                    'id': [selectedId],
                },
            ).toString(),
        );
    }
}

class RestaurantSelectItem extends StatelessWidget {
    const RestaurantSelectItem({
        super.key,
        required this.currentId,
        required this.item
    });
    final String currentId;
    final Restaurant item;

    @override
    Widget build(BuildContext context) {
        if (item.id == currentId) {
            return ListTile(
                leading: Icon(Icons.restaurant_outlined),
                title: Text(item.title),
                selected: true,
                trailing: Icon(
                    Icons.check_circle,
                    color: Theme.of(context)
                        .colorScheme.primary,
                ),
            );
        } else {
            return ListTile(
                leading: Icon(Icons.restaurant_outlined),
                title: Text(item.title),
                selected: false,
                onTap: () => Navigator.of(context).pop(item.id),
            );
        }
    }
}
