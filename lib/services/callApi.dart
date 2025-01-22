import 'dart:convert';
import 'package:http/http.dart' as http;

class Utilisateur {
  static String baseUrl = 'http://localhost:1234';

  static Future<List> getAllUser() async {
    try {
      var res = await http.get(Uri.parse("$baseUrl/user/getUsers"));
      if (res.statusCode == 200) {
        print("testfddddddddddddddddddddddddddddd");
        print(res.body);
        return jsonDecode(res.body);
      } else {
        return Future.error("erreur serveur");
      }
    } catch (err) {
      return Future.error(err);
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
