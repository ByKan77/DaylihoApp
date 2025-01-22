import 'dart:convert';
import 'package:http/http.dart' as http;

class Utilisateur {
  static Future<List> getAllUser() async {
    final response =
        await http.get(Uri.parse('http://localhost:1234/user/getUsers'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur lors du chargement des utilisateurs');
    }
  }
}
