import 'dart:convert';
import 'package:http/http.dart' as http;

class Utilisateur {
  static String baseUrl = 'http://localhost:1234';
  static Future<Map<String, dynamic>> getUserByEmail(String email) async {
    final response =
        await http.get(Uri.parse("$baseUrl/user/getUserByEmail?email=$email"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception("Échec de la récupération des données");
    }
  }
}

class CheckAccounts {
  static String baseUrl = 'http://localhost:1234';

  static Future<Map<String, dynamic>> checkUser(
      String email, String password) async {
    try {
      var res = await http.post(
        Uri.parse("$baseUrl/user/checkUser"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'mot_de_passe': password}),
      );
      if (res.statusCode == 201) {
        return jsonDecode(res.body);
      } else if (res.statusCode == 401) {
        throw Exception("Email ou mot de passe incorrect.");
      } else {
        throw Exception("Erreur serveur : ${res.statusCode}");
      }
    } catch (err) {
      throw Exception("Erreur réseau : $err");
    }
  }
}

class AllSeance {
  static String baseUrl = 'http://localhost:1234';

  static Future<List<dynamic>> getAllSeance() async {
    try {
      var res = await http.get(
        Uri.parse("$baseUrl/video/getVideos"),
        headers: {'Content-Type': 'application/json'},
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        throw Exception("Erreur serveur : ${res.statusCode}");
      }
    } catch (err) {
      throw Exception("Erreur réseau : $err");
    }
  }
}

class BookSeance {
  static String baseUrl = 'http://localhost:1234';

  static Future<Map<String, dynamic>> reserverSeance(
      int idSeance, int idUtilisateur) async {
    try {
      var res = await http.post(
        Uri.parse("$baseUrl/video/bookSeance/$idUtilisateur/$idSeance"),
        headers: {'Content-Type': 'application/json'},
      );

      if (res.statusCode == 201) {
        return jsonDecode(res.body); // Réservation réussie
      } else if (res.statusCode == 409) {
        throw Exception("Cette séance est déjà réservée.");
      } else {
        throw Exception("Erreur serveur : ${res.statusCode}");
      }
    } catch (err) {
      throw Exception("Erreur réseau : $err");
    }
  }

  static Future<void> annulerReservation(
      int idSeance, int idUtilisateur) async {
    try {
      var res = await http.delete(
        Uri.parse("$baseUrl/video/deleteReservation/$idUtilisateur/$idSeance"),
        headers: {'Content-Type': 'application/json'},
      );

      if (res.statusCode != 200) {
        throw Exception("Erreur serveur : ${res.statusCode}");
      }
    } catch (err) {
      throw Exception("Erreur réseau : $err");
    }
  }
}

class GetSeance {
  static String baseUrl = 'http://localhost:1234';

  static Future<List<dynamic>> getSeanceById(int idUtilisateur) async {
    try {
      var res = await http.get(
        Uri.parse("$baseUrl/video/getBookedSeances/$idUtilisateur"),
        headers: {'Content-Type': 'application/json'},
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body) as List<dynamic>;
      } else {
        throw Exception("Erreur serveur : ${res.statusCode}");
      }
    } catch (err) {
      throw Exception("Erreur réseau : $err");
    }
  }
}
