import 'dart:convert';
import 'package:http/http.dart' as http;

class CheckAccount {
  static Future<List> checkUser() async {
    final response =
        await http.get(Uri.parse('http://localhost:1234/user/checkUser'));

    if (response.statusCode == 200) {
      print(response.body);
      return json.decode(response.body);
    } else {
      throw Exception('Erreur lors du chargement des utilisateurs');
    }
  }
}
