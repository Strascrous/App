import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:strascrous/api/restaurants.dart';
import 'package:strascrous/components/menu.dart';
import 'package:strascrous/components/svg.dart';

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
    void initState() {
        super.initState();
        _saveLastRestaurant();
    }

    @override
    void didUpdateWidget(covariant MenuPage oldWidget) {
        super.didUpdateWidget(oldWidget);

        if (oldWidget.id != widget.id || oldWidget.type != widget.type) {
            _saveLastRestaurant();
        }
    }

    Future<void> _saveLastRestaurant() async {
        final path = widget.type == RestaurantType.cafeteria
            ? '/cafeteria'
            : '/resto';

        final uri = Uri(
            path: path,
            queryParameters: {'id': widget.id},
        );

        await box.write('last_restaurant', uri.toString());
    }

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
                actions: [
                    IconButton(
                        icon: Icon(Icons.info),
                        onPressed: () => openInformation(context),
                    )
                ],
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

    Future<void> openInformation(BuildContext context) async {
        if (restaurant == null) return;
        final r = restaurant!;

        final List<Widget> payments = [];
        for (var p in r.details.payments) {
            switch (p) {
                case Payment.izly:
                    payments.add(IconSvg("payments/izly", alt: "Izly"));
                    break;
                case Payment.card:
                    payments.add(Icon(Icons.credit_card, semanticLabel: "Carte bancaire"));
                    break;
                case Payment.cash:
                    payments.add(Icon(Icons.attach_money, semanticLabel: "Espèce"));
                    break;
                case Payment.moneo:
                    payments.add(IconSvg("payments/moneo", alt: "Monéo"));
                    break;
            }
        }

        await showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Padding(
                            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                    Expanded(
                                        child: Semantics(
                                            header: true,
                                            child: Text(
                                                r.title,
                                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                ),
                                            ),
                                        ),
                                    ),
                                    const SizedBox(width: 12),
                                    RestaurantDetailsIcons(details: r.details)
                                ]
                            )
                        ),
                        Expanded(
                            child: ListView(
                                children: [
                                    if (r.details.hours.isNotEmpty) RestaurantDetailsTile(
                                        title: "Horaires",
                                        subtitle: r.details.hours,
                                        icon: Icons.access_time
                                    ),
                                    if (r.details.address.isNotEmpty) RestaurantDetailsTile(
                                        title: "Adresse",
                                        subtitle: r.details.address,
                                        icon: Icons.location_on
                                    ),
                                    if (r.details.access.isNotEmpty) RestaurantDetailsTile(
                                        title: "Moyens d'accès",
                                        subtitle: r.details.access,
                                        icon: Icons.tram
                                    ),
                                    if (payments.isNotEmpty) ListTile(
                                        titleAlignment: ListTileTitleAlignment.top,
                                        leading: Padding(
                                            padding: EdgeInsetsGeometry.only(top: 4),
                                            child: Icon(Icons.account_balance_wallet_outlined),
                                        ),
                                        title: Text("Moyens de paiement"),
                                        subtitle: Padding(
                                            padding: EdgeInsetsGeometry.only(top: 2),
                                            child: Row(
                                                spacing: 8,
                                                children: payments,
                                            ),
                                        )
                                    )
                                ],
                            ),
                        )
                    ]
                );
            }
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
                trailing: RestaurantDetailsIcons(details: item.details),
            );
        }
    }
}

class RestaurantDetailsIcons extends StatelessWidget {
    const RestaurantDetailsIcons({ super.key, required this.details });
    final RestaurantDetails details;

    @override
    Widget build(BuildContext context) {
        return details.wifi || details.pmr
            ? Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                    if (details.pmr) const Icon(Icons.accessible, semanticLabel: "Accessible au PMR"),
                    if (details.wifi) const Icon(Icons.wifi, semanticLabel: "Wi-Fi disponible"),
                ],
            )
            : SizedBox();
    }
}

class RestaurantDetailsTile extends StatelessWidget {
    const RestaurantDetailsTile({ super.key, required this.title, required this.subtitle, required this.icon });
    final String title;
    final String subtitle;
    final IconData icon;

    @override
    Widget build(BuildContext context) {
        if (!subtitle.contains('\n')) {
            return ListTile(
                leading: Icon(icon),
                title: Text(title),
                subtitle: Text(subtitle, maxLines: 10),
            );
        }

        return ListTile(
            titleAlignment: ListTileTitleAlignment.top,
            leading: Padding(
                padding: EdgeInsetsGeometry.only(top: 4),
                child: Icon(icon),
            ),
            title: Text(title),
            subtitle: Text(
                subtitle,
                maxLines: 10,
            ),
        );
    }
}
