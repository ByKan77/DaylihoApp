import 'package:flutter/material.dart';
import 'package:myapp/services/callApi.dart';

class SecondPage extends StatefulWidget {
  final String email;
  final int userId;

  const SecondPage({super.key, required this.email, required this.userId});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  late Future<List> _seances;
  late Future<Map<String, dynamic>> _user;
  int _currentPageIndex = 0;
  late String _password; // Champ pour le mot de passe récupéré

  @override
  void initState() {
    super.initState();
    _user = Utilisateur.getUserByEmail(widget.email);
    _seances = AllSeance.getAllSeance();
  }

  Future<void> _reserverSeance(int idSeance) async {
    try {
      await BookSeance.reserverSeance(idSeance, widget.userId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Séance réservée avec succès!')),
      );
    } catch (error) {
      String errorMessage = error.toString();

      if (errorMessage.contains("Cette séance est déjà réservée")) {
        errorMessage = "Vous avez déjà réservé cette séance.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final List<Widget> pages = [
      // ✅ Page d'accueil
      FutureBuilder<Map<String, dynamic>>(
        future: _user,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final user = snapshot.data!;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Bienvenue ${user['prenom']} !',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    Icon(Icons.home, size: 100, color: Colors.orange),
                    SizedBox(height: 20),
                    Text(
                      'Nous sommes heureux de vous voir. Naviguez à travers les sections pour gérer vos séances et informations personnelles.',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Erreur lors du chargement des données"));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),

      // ✅ Nouvelle Page Réservations
      Center(
        child: Text(
          "Page Réservations",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),

      // ✅ Page des séances
      FutureBuilder<List>(
        future: _seances,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (context, i) {
                final seance = snapshot.data?[i];
                final titre = seance?['titre'] ?? 'Titre non disponible';
                final description =
                    seance?['description'] ?? 'Description non disponible';
                final idSeance = seance?['id'];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text(titre),
                      subtitle: Text(description),
                      trailing: ElevatedButton(
                        onPressed: () {
                          if (idSeance != null) {
                            _reserverSeance(idSeance);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Réserver'),
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),

      // ✅ Page du compte utilisateur
      FutureBuilder<Map<String, dynamic>>(
        future: _user,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final user = snapshot.data!;
            _password = user['mot_de_passe'] ?? '';

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.orange,
                      child: Icon(Icons.account_circle,
                          size: 60, color: Colors.white),
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: 500,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.orange, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Nom:", style: TextStyle(fontSize: 16)),
                          SizedBox(height: 5),
                          Text(user['nom'] ?? 'Nom non disponible',
                              style: TextStyle(fontSize: 18)),
                          SizedBox(height: 15),
                          Text("Prénom:", style: TextStyle(fontSize: 16)),
                          SizedBox(height: 5),
                          Text(user['prenom'] ?? 'Prénom non disponible',
                              style: TextStyle(fontSize: 18)),
                          SizedBox(height: 15),
                          Text("Email:", style: TextStyle(fontSize: 16)),
                          SizedBox(height: 5),
                          Text(user['email'] ?? 'Email non disponible',
                              style: TextStyle(fontSize: 18)),
                          SizedBox(height: 20),
                          Text("Mot de passe:", style: TextStyle(fontSize: 16)),
                          SizedBox(height: 5),
                          Text(
                            '*' * (_password.length > 0 ? _password.length : 6),
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(),
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
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Accueil',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.book_online),
            icon: Icon(Icons.book_online_outlined),
            label: 'Réservations',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.calendar_month),
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Séances',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.account_circle),
            icon: Icon(Icons.account_circle_outlined),
            label: 'Compte',
          ),
        ],
      ),
    );
  }
}
