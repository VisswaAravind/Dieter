import 'dart:convert';
import 'package:http/http.dart' as http;

class ContFun {
  static Future<List<Map<String, dynamic>>> getRes(String findrecipe) async {
    String id = 'a5f8e5f6';
    String key = 'bd0682b03769c566127c7559c6eb617a';
    String api =
        'https://api.edamam.com/search?q=$findrecipe&app_id=$id&app_key=$key&health=alcohol-free';
    final response = await http.get(Uri.parse(api));
    List<Map<String, dynamic>> recipes = [];

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      if (data['hits'] != null) {
        for (var hit in data['hits']) {
          if (hit['recipe'] != null && hit['recipe']['healthLabels'] != null) {
            if (hit['recipe']['healthLabels'].contains('Vegetarian')) {
              recipes.add(hit['recipe']);
            }
          }
        }
      }
    } else {
      print('Failed to load recipes: ${response.statusCode}');
    }
    return recipes;
  }
}
