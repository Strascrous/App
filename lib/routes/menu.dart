import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
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
    final box = GetStorage();
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
                                        restaurant?.title ?? 'Choisir un établissement',
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

    Future<void> openSelector(BuildContext context) async {
        var restaurants = readRestaurants(widget.type);
        var isRefreshing = false;

        final selectedId = await showModalBottomSheet<String>(
            context: context,
            builder: (BuildContext context) {
                return StatefulBuilder(
                    builder: (selectorContext, setSelectorState) {
                        return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Padding(
                                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                                    child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                            Expanded(
                                                child: Semantics(
                                                    header: true,
                                                    child: Text(
                                                        widget.type == RestaurantType.cafeteria
                                                            ? 'Choisir une cafétéria'
                                                            : 'Choisir un restaurant',
                                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                            fontWeight: FontWeight.w600,
                                                        ),
                                                    ),
                                                ),
                                            ),
                                            const SizedBox(width: 12),
                                            IconButton(
                                                tooltip: 'Actualiser la liste',
                                                icon: isRefreshing
                                                    ? const SizedBox(
                                                        width: 24,
                                                        height: 24,
                                                        child: CircularProgressIndicator(strokeWidth: 2),
                                                    )
                                                    : const Icon(Icons.refresh),
                                                onPressed: isRefreshing ? null : () async {
                                                    setSelectorState(() => isRefreshing = true);
                                                    try {
                                                        String cityId = box.read('city');
                                                        await fetchRestaurants(cityId);

                                                        if (mounted) setState(() {});
                                                        if (!selectorContext.mounted) return;

                                                        setSelectorState(() {
                                                            restaurants = readRestaurants(widget.type);
                                                        });
                                                    } catch (_) {
                                                        if (!selectorContext.mounted) return;
                                                        // TODO: snackbar
                                                    } finally {
                                                        if (selectorContext.mounted) {
                                                            setSelectorState(() => isRefreshing = false);
                                                        }
                                                    }
                                                },
                                            )
                                        ],
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
                    },
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
