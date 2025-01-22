import 'package:flutter/material.dart';
import 'package:myapp/services/callApi.dart';

class SecondPage extends StatefulWidget {
  final String firstValue;
  final String user;
  const SecondPage({super.key, required this.firstValue, required this.user});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  late Future<List> _user;
  late Future<List> _seances;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _user = Utilisateur.getAllUser();
    _seances = AllSeance.getAllSeance();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    // Contenu pour les différentes pages
    final List<Widget> pages = [
      /// Première page : Liste des utilisateurs
      FutureBuilder<List>(
        future: _user,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (context, i) {
                final nom = snapshot.data?[i]['nom'] ?? 'Nom non disponible';
                final prenom =
                    snapshot.data?[i]['prenom'] ?? 'Prénom non disponible';
                return Card(
                  child: ListTile(
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(nom, style: const TextStyle(fontSize: 20)),
                        Text(prenom, style: const TextStyle(fontSize: 20)),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: Text("Pas de données"),
            );
          }
        },
      ),

      /// Deuxième page : Liste des séances
      FutureBuilder<List>(
        future: _seances, // Future qui retourne la liste des séances
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount:
                  snapshot.data?.length, // Nombre d'éléments dans la liste
              itemBuilder: (context, i) {
                final titre =
                    snapshot.data?[i]['titre'] ?? 'Titre non disponible';
                final description = snapshot.data?[i]['description'] ??
                    'Description non disponible';

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0), // Padding général
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment
                              .start, // Alignement du texte avec l'image
                          children: [
                            // Image à gauche, réduite
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'lib/assets/image/images.jpg', // Assurez-vous que le chemin est correct
                                height: 80, // Taille réduite de l'image
                                width: 80, // Largeur réduite de l'image
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(
                                width:
                                    12), // Espacement entre l'image et le texte
                            // Texte à droite de l'image
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Titre de la séance
                                  Text(
                                    titre,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                      height:
                                          6), // Espacement entre le titre et la description
                                  // Description de la séance
                                  Text(
                                    description,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(
                                      height: 10), // Espacement avant le bouton
                                  // Bouton de réservation
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: SizedBox(
                                      height:
                                          32, // Réduction de la hauteur du bouton
                                      width:
                                          100, // Réduction de la largeur du bouton
                                      child: ElevatedButton(
                                        onPressed: () {
                                          print(
                                              'Réservation effectuée pour la séance : $titre');
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Séance "$titre" réservée !'),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                        ),
                                        child: const Text(
                                          'Réserver',
                                          style: TextStyle(
                                              fontSize:
                                                  12), // Réduction de la taille du texte du bouton
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(widget.firstValue),
      ),
      body: pages[_currentPageIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        selectedIndex: _currentPageIndex,
        indicatorColor: Colors.amber,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.people),
            icon: Icon(Icons.people_outline),
            label: 'Utilisateurs',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.calendar_month),
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Séances',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.message),
            icon: Icon(Icons.message_outlined),
            label: 'Messages',
          ),
        ],
      ),
    );
  }
}
