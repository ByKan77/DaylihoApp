import 'package:flutter/material.dart';
import 'package:myapp/services/callApi.dart';
import 'first_page.dart';

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
  late Future<List> _reservedSeances;
  int _currentPageIndex = 0;
  late String _password;

  @override
  void initState() {
    super.initState();
    _user = Utilisateur.getUserByEmail(widget.email);
    _seances = AllSeance.getAllSeance();
    _reservedSeances = GetSeance.getSeanceById(widget.userId);
  }

  Future<void> _reserverSeance(int idSeance) async {
    try {
      await BookSeance.reserverSeance(idSeance, widget.userId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Séance réservée avec succès!')),
      );
      _refreshReservedSeances();
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

  void _refreshReservedSeances() {
    setState(() {
      _reservedSeances = GetSeance.getSeanceById(widget.userId);
    });
  }

  Future<void> _annulerReservation(int idSeance) async {
    try {
      await BookSeance.annulerReservation(idSeance, widget.userId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Réservation annulée avec succès!')),
      );
      _refreshReservedSeances();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'annulation: $error')),
      );
    }
  }

  bool _isSeanceReserved(int idSeance, List reservedSeances) {
    for (var seance in reservedSeances) {
      if (seance['id'] == idSeance) {
        return true;
      }
    }
    return false;
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.orange, width: 2),
          ),
          child: Container(
            width: 250, // Réduction de la largeur
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Déconnexion', style: TextStyle(fontSize: 20)),
                SizedBox(height: 20),
                Text('Voulez-vous vous déconnecter ?'),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: Text('Non'),
                    ),
                    SizedBox(width: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => FirstPage()),
                          (route) => false,
                        );
                      },
                      style:
                          TextButton.styleFrom(foregroundColor: Colors.green),
                      child: Text('Oui'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
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
                  children: [
                    Text('Bienvenue ${user['prenom']} !',
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange)),
                    SizedBox(height: 20),
                    Icon(Icons.fitness_center, size: 100, color: Colors.orange),
                    SizedBox(height: 20),
                    Text(
                      'Accédez à vos séances et gérez vos réservations.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Erreur de chargement"));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      FutureBuilder<List>(
        future: _reservedSeances,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: snapshot.data?.length,
              itemBuilder: (context, i) {
                final seance = snapshot.data![i];
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 4,
                  child: ListTile(
                    title: Text(seance['titre'] ?? '',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(seance['description'] ?? ''),
                    trailing: IconButton(
                      icon: Icon(Icons.cancel, color: Colors.red),
                      onPressed: () => _annulerReservation(seance['id']),
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Erreur de chargement"));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      FutureBuilder<List>(
        future: _seances,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return FutureBuilder<List>(
              future: _reservedSeances,
              builder: (context, reservedSnapshot) {
                if (reservedSnapshot.hasData) {
                  return ListView.builder(
                    padding: EdgeInsets.all(10),
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, i) {
                      final seance = snapshot.data![i];
                      final titre = seance['titre'] ?? 'Titre non disponible';
                      final description =
                          seance['description'] ?? 'Description non disponible';
                      final lieu = seance['lieu'] ??
                          'Lieu non disponible'; // Extraction du lieu
                      final dateDebut = seance['dateDebut'] ?? '';
                      final dateFin = seance['dateFin'] ?? '';
                      final idSeance = seance['id'];

                      // Formater les heures
                      final heureDebut = dateDebut.isNotEmpty
                          ? DateTime.parse(dateDebut)
                              .toLocal()
                              .toString()
                              .substring(11, 16)
                          : 'N/A';
                      final heureFin = dateFin.isNotEmpty
                          ? DateTime.parse(dateFin)
                              .toLocal()
                              .toString()
                              .substring(11, 16)
                          : 'N/A';

                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        elevation: 4,
                        child: ListTile(
                          title: Text(titre,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(description),
                              SizedBox(height: 5),
                              Text('Lieu : $lieu',
                                  style: TextStyle(
                                      color: Colors.grey)), // Affichage du lieu
                              Text('🕒 $heureDebut - $heureFin',
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                          trailing: _isSeanceReserved(
                                  idSeance, reservedSnapshot.data!)
                              ? Text('Réservée',
                                  style: TextStyle(color: Colors.grey))
                              : ElevatedButton(
                                  onPressed: () => _reserverSeance(idSeance),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange),
                                  child: Text('Réserver',
                                      style: TextStyle(color: Colors.white))),
                        ),
                      );
                    },
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: Icon(Icons.logout, color: Colors.white),
          onPressed: _showLogoutConfirmationDialog,
        ),
        title: Text('Mon Espace', style: TextStyle(color: Colors.white)),
      ),
      body: pages[_currentPageIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        indicatorColor: Colors.orange.shade100,
        selectedIndex: _currentPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentPageIndex = index;
            if (index == 1) _refreshReservedSeances();
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Colors.orange),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_online_outlined),
            selectedIcon: Icon(Icons.book_online, color: Colors.orange),
            label: 'Réservations',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_month, color: Colors.orange),
            label: 'Séances',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_circle_outlined),
            selectedIcon: Icon(Icons.account_circle, color: Colors.orange),
            label: 'Compte',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label :", style: TextStyle(fontSize: 16)),
        SizedBox(height: 5),
        Text(value ?? 'Non disponible',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        SizedBox(height: 15),
      ],
    );
  }
}
