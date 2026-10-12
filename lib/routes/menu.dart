import 'package:flutter/material.dart';

class MenuPage extends StatefulWidget {
    const MenuPage({super.key});

    @override
    State<MenuPage> createState() => _MenuPageState();
}

final placeholderMenu = [
    ListTile(
        title: Text("Cafétéria"),
        subtitle: Text(
            "- Sandwich en formule étudiant à 1€ (maraîcher ou parisien)\n"
            "- Divers sandwich (thon mayo, indien, etc.)\n"
            "- Moricette garni\n"
            "- Café, viennoiserie, pâtisserie américaine",
            maxLines: 10,
            overflow: TextOverflow.visible,
        ),
    ),
    ListTile(
        title: Text("Salle Des Etudiants - Barbecue"),
        subtitle: Text(
            "- Emincé de porc sauce champignon\n",
            maxLines: 10,
            overflow: TextOverflow.visible,
        ),
    ),
    ListTile(
        title: Text("Salle Des Etudiants - Plat du Jour 1"),
        subtitle: Text(
            "- Chili aux lentilles et haricots rouges\n",
            maxLines: 10,
            overflow: TextOverflow.visible,
        ),
    ),
    ListTile(
        title: Text("Salle Des Etudiants - Plat du Jour 2"),
        subtitle: Text(
            "- Nem et riz cantonais\n",
            maxLines: 10,
            overflow: TextOverflow.visible,
        ),
    ),
    ListTile(
        title: Text("Salle Des Etudiants - Pates"),
        subtitle: Text(
            "- Penne carbo\n",
            maxLines: 10,
            overflow: TextOverflow.visible,
        ),
    ),
    ListTile(
        title: Text("Salle Des Personnels - Plat du Jour 1"),
        subtitle: Text(
            "- Nems et riz cantonais\n",
            maxLines: 10,
            overflow: TextOverflow.visible,
        ),
    ),
    ListTile(
        title: Text("Salle Des Personnels - Plat du Jour 2"),
        subtitle: Text(
            "- Chili aux lentilles et haricots rouges\n",
            maxLines: 10,
            overflow: TextOverflow.visible,
        ),
    ),
    ListTile(
        title: Text("Salle Des Personnels - Suggestion du Jour"),
        subtitle: Text(
            "- Emincé de porc sauce champignon\n",
            maxLines: 10,
            overflow: TextOverflow.visible,
        ),
    ),
    ListTile(
        title: Text("Origines De Nos Viandes Du Jour"),
        subtitle: Text(
            "- France et union européenne\n",
            maxLines: 10,
            overflow: TextOverflow.visible,
        ),
    )
];

class _MenuPageState extends State<MenuPage> with TickerProviderStateMixin {
    late final TabController _tabController;

    @override
    void initState() {
        super.initState();
        _tabController = TabController(length: 2, vsync: this);
    }

    @override
    void dispose() {
        _tabController.dispose();
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
                                        "Resto U' Illkirch",
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
            body: Column(
                children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                            IconButton(
                                tooltip: 'Jour précédent',
                                icon: const Icon(Icons.chevron_left),
                                onPressed: () => {},
                            ),
                            TextButton.icon(
                                onPressed: () => {},
                                label: Text("lundi 12 octobre 2026"),
                            ),
                            IconButton(
                                tooltip: 'Jour suivant',
                                icon: const Icon(Icons.chevron_right),
                                onPressed: () => {},
                            ),
                        ],
                    ),
                    TabBar(
                        controller: _tabController,
                        tabs: [
                            Tab(text: "Midi"),
                            Tab(text: "Soir")
                        ]
                    ),
                    Expanded(
                        child: TabBarView(
                            controller: _tabController,
                            children: [
                                ListView(children: placeholderMenu),
                                ListView(children: placeholderMenu),
                            ],
                        ),
                    ),
                    /* Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                            child: Text(
                                "Midi",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                ),
                            ),
                        ),
                    ),
                    Divider(),

                    Divider(),
                    Center(
                        child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                                "Soir",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                ),
                            ),
                        )
                    ),
                    Divider(),
                    ListTile(
                        title: Text("Cafétéria"),
                        subtitle: Text(
                            "- Sandwich en formule étudiant à 1€ (maraîcher ou parisien)\n"
                            "- Divers sandwich (thon mayo, indien, etc.)\n"
                            "- Moricette garni\n"
                            "- Café, viennoiserie, pâtisserie américaine",
                            maxLines: 10,
                            overflow: TextOverflow.visible,
                        ),
                    ),
                    ListTile(
                        title: Text("Salle Des Etudiants - Barbecue"),
                        subtitle: Text(
                            "- Emincé de porc sauce champignon\n",
                            maxLines: 10,
                            overflow: TextOverflow.visible,
                        ),
                    ),
                    ListTile(
                        title: Text("Salle Des Etudiants - Plat du Jour 1"),
                        subtitle: Text(
                            "- Chili aux lentilles et haricots rouges\n",
                            maxLines: 10,
                            overflow: TextOverflow.visible,
                        ),
                    ),
                    ListTile(
                        title: Text("Salle Des Etudiants - Plat du Jour 2"),
                        subtitle: Text(
                            "- Nem et riz cantonais\n",
                            maxLines: 10,
                            overflow: TextOverflow.visible,
                        ),
                    ),
                    ListTile(
                        title: Text("Salle Des Etudiants - Pates"),
                        subtitle: Text(
                            "- Penne carbo\n",
                            maxLines: 10,
                            overflow: TextOverflow.visible,
                        ),
                    ),
                    ListTile(
                        title: Text("Salle Des Personnels - Plat du Jour 1"),
                        subtitle: Text(
                            "- Nems et riz cantonais\n",
                            maxLines: 10,
                            overflow: TextOverflow.visible,
                        ),
                    ),
                    ListTile(
                        title: Text("Salle Des Personnels - Plat du Jour 2"),
                        subtitle: Text(
                            "- Chili aux lentilles et haricots rouges\n",
                            maxLines: 10,
                            overflow: TextOverflow.visible,
                        ),
                    ),
                    ListTile(
                        title: Text("Salle Des Personnels - Suggestion du Jour"),
                        subtitle: Text(
                            "- Emincé de porc sauce champignon\n",
                            maxLines: 10,
                            overflow: TextOverflow.visible,
                        ),
                    ),
                    ListTile(
                        title: Text("Origines De Nos Viandes Du Jour"),
                        subtitle: Text(
                            "- France et union européenne\n",
                            maxLines: 10,
                            overflow: TextOverflow.visible,
                        ),
                        ), */
                ],
            ),
        );
    }

    Future<void> openSelector(BuildContext context) async {
        showModalBottomSheet<void>(
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
                                children: [
                                    ListTile(
                                        leading: Icon(Icons.restaurant_outlined),
                                        title: Text("Resto U' Illkirch"),
                                        selected: true,
                                        trailing: Icon(
                                            Icons.check_circle,
                                            color: Theme.of(context)
                                                .colorScheme.primary,
                                        ),
                                    ),
                                    ListTile(
                                        leading: Icon(Icons.restaurant_outlined),
                                        title: Text("Resto U' Esplanade"),
                                        selected: false,
                                    ),
                                    ListTile(
                                        leading: Icon(Icons.restaurant_outlined),
                                        title: Text("Resto U' Gallia"),
                                        selected: false,
                                    ),
                                    ListTile(
                                        leading: Icon(Icons.restaurant_outlined),
                                        title: Text("Resto U' Paul Appell"),
                                        selected: false,
                                    ),
                                ],
                            ),
                        ),
                    ],
                );
            }
        );
    }
}
