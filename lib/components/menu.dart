import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:strascrous/api/menus.dart';

class Pages extends StatefulWidget {
    const Pages({ super.key, required this.id, required this.pageController });

    final String id;
    final PageController pageController;

    @override
    State<Pages> createState() => PagesState();
}

class PagesState extends State<Pages> {
    late Future<List<MenusItem>> futureMenu;
    int _currentPage = 0;
    bool _initialPageSelected = false;
    String? _selectedDate;

    String _formatDate(String value) {
        final date = DateTime.tryParse(value);
        if (date == null) return value;

        return DateFormat('EEEE d MMMM y', 'fr_FR').format(date);
    }

    int _closestDayIndex(List<MenusItem> menus) {
        final now = DateTime.now();
        final today = DateTime.utc(now.year, now.month, now.day);
        int lastPastIndex = 0;

        for (int i = 0; i < menus.length; i++) {
            final date = DateTime.tryParse(menus[i].date);
            if (date == null) continue;

            final day = DateTime.utc(date.year, date.month, date.day);
            if (!day.isBefore(today)) return i;

            lastPastIndex = i;
        }

        return lastPastIndex;
    }

    @override
    void initState() {
        super.initState();
        futureMenu = fetchMenu(widget.id);
    }

    @override
    void didUpdateWidget(covariant Pages oldWidget) {
        super.didUpdateWidget(oldWidget);

        if (oldWidget.id != widget.id) {
            _currentPage = 0;
            _initialPageSelected = false;
            _selectedDate = null;
            futureMenu = fetchMenu(widget.id);
        }
    }

    Future<void> _refreshMenus() async {
        final menuFuture = fetchMenu(widget.id);
        setState(() {
            _currentPage = 0;
            _initialPageSelected = false;
            futureMenu = menuFuture;
        });

        try {
            await menuFuture;
        } catch (_) {}
    }

    Future<void> _selectDate(List<MenusItem> menus) async {
        final menuIndexes = <DateTime, int>{};
        for (int i = 0; i < menus.length; i++) {
            final date = DateTime.tryParse(menus[i].date);
            if (date == null) continue;

            menuIndexes[DateUtils.dateOnly(date)] = i;
        }
        if (menuIndexes.isEmpty) return;

        final dates = menuIndexes.keys.toList()..sort();
        final currentDate = DateTime.tryParse(menus[_currentPage].date);
        final selectedDate = await showDatePicker(
            context: context,
            initialDate: currentDate == null
                ? dates.first
                : DateUtils.dateOnly(currentDate),
            firstDate: dates.first,
            lastDate: dates.last,
            selectableDayPredicate: (day) => menuIndexes.containsKey(day),
        );

        if (!mounted || selectedDate == null) {
            return;
        }

        final index = menuIndexes[selectedDate];
        if (index == null) return;

        await widget.pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
        );
    }

    Widget _buildMessage(String message) {
        return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
                SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text(message)),
                ),
            ],
        );
    }

    @override
    Widget build(BuildContext context) {
        return RefreshIndicator(
            onRefresh: _refreshMenus,
            notificationPredicate: (notification) =>
                notification.metrics.axis == Axis.vertical,
            child: _buildMenus(context),
        );
    }

    Widget _buildMenus(BuildContext context) {
        return FutureBuilder<List<MenusItem>>(
            future: futureMenu,
            builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                    if (snapshot.data == null || snapshot.data!.isEmpty) {
                        return _buildMessage("Aucun menu n'est disponible");
                    }

                    if (!_initialPageSelected) {
                        _initialPageSelected = true;
                        final index = snapshot.data!.indexWhere(
                            (menu) => menu.date == _selectedDate,
                        );
                        _currentPage = index >= 0
                            ? index
                            : _closestDayIndex(snapshot.data!);
                        _selectedDate = snapshot.data![_currentPage].date;
                        final initialPage = _currentPage;
                        final menuFuture = futureMenu;

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted && identical(futureMenu, menuFuture) &&
                                widget.pageController.hasClients) {
                                widget.pageController.jumpToPage(initialPage);
                            }
                        });
                    }

                    List<Menu> children = [];
                    for (var d in snapshot.data!) {
                        children.add(Menu(menu: d));
                    }

                    return Column(
                        children: [
                            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                    IconButton(
                                        tooltip: 'Jour précédent',
                                        icon: const Icon(Icons.chevron_left),
                                        onPressed: _currentPage > 0
                                            ? () => widget.pageController.previousPage(
                                                duration: const Duration(milliseconds: 300),
                                                curve: Curves.easeInOut,
                                            )
                                            : null,
                                    ),
                                    TextButton.icon(
                                        onPressed: () => _selectDate(snapshot.data!),
                                        label: Text(
                                            _formatDate(snapshot.data![_currentPage].date),
                                        ),
                                    ),
                                    IconButton(
                                        tooltip: 'Jour suivant',
                                        icon: const Icon(Icons.chevron_right),
                                        onPressed: _currentPage < children.length - 1
                                            ? () => widget.pageController.nextPage(
                                                duration: const Duration(milliseconds: 300),
                                                curve: Curves.easeInOut,
                                            )
                                            : null,
                                    ),
                                ],
                            ),

                            Expanded(
                                child: PageView(
                                    controller: widget.pageController,
                                    scrollDirection: Axis.horizontal,
                                    onPageChanged: (page) {
                                        setState(() {
                                            _currentPage = page;
                                            _selectedDate = snapshot.data![page].date;
                                        });
                                    },
                                    children: children,
                                ),
                            )
                        ],
                    );
                } else if (snapshot.hasError) {
                    return _buildMessage('${snapshot.error!}');
                }

                return Center(child: CircularProgressIndicator());
            },
        );
    }
}

class Menu extends StatefulWidget {
    const Menu({ super.key, required this.menu });
    final MenusItem menu;

    @override
    State<Menu> createState() => MenuState();
}

// TODO: Quand ce sera revenu, faire le websocket avec les repas servis :
/* Padding(
    padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
    child: Card.filled(
        child: ListTile(
            leading: const Icon(Icons.restaurant),
            title: Row(
                children: [
                    const Expanded(
                        child: Text("Repas servis (200 / 2 800)"),
                    ),
                    const Text("7,1 %"),
                ],
            ),
            subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: LinearProgressIndicator(
                    value: 200 / 2800,
                    borderRadius: BorderRadius.circular(4),
                ),
            ),
        ),
    ),
    ), */


class MenuState extends State<Menu> with TickerProviderStateMixin {
    late final TabController _tabController;
    int tabLength = 0;
    List<Tab> tabs = [];
    List<ListView> content = [];

    void addContent(List<MenuItem> data) {
        List<ListTile> elements = [];
        for (var e in data) {
            String title = e.title;
            String subtitle = "";

            if (e.elements.length == 1) {
                subtitle = e.elements[0];
            } else {
                for (var e in e.elements) {
                    if (e.trim() == '') { continue; }
                    subtitle += '• $e\n';
                }
            }

            elements.add(
                ListTile(
                    title: Text(title),
                    subtitle: Text(
                        subtitle.replaceAll("\n\n", "\n"),
                        maxLines: 50,
                        overflow: TextOverflow.visible,
                    ),
                )
            );
        }
        content.add(ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: elements,
        ));
    }

    @override
    void initState() {
        super.initState();
        if (widget.menu.noon.isNotEmpty) {
            tabs.add(Tab(text: "Midi"));
            addContent(widget.menu.noon);
        }

        if (widget.menu.evening.isNotEmpty) {
            tabs.add(Tab(text: "Soir"));
            addContent(widget.menu.evening);
        }
        _tabController = TabController(length: tabs.length, vsync: this);
    }

    @override
    void dispose() {
        _tabController.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        return Column(
            children: [
                TabBar(
                    controller: _tabController,
                    tabs: tabs
                ),
                Expanded(
                    child: TabBarView(
                        controller: _tabController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: content,
                    ),
                )
            ],
        );
    }
}
