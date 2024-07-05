import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<Map<String, dynamic>>> fetchRecipeSuggestions(String query) async {
  final String id = '35e6c1a6';
  final String key = '0fcbe4287daeced4e21b0fbfa00d48a7';
  final String apiUrl =
      'https://api.edamam.com/api/food-database/v2/parser?app_id=$id&app_key=$key&q=$query'; /*&nutrition-type=cooking*/

  final response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    final List<Map<String, dynamic>> suggestions = [];

    if (data.containsKey('hints')) {
      final List<dynamic> hints = data['hints'];

      for (var hint in hints) {
        if (hint.containsKey('food')) {
          final Map<String, dynamic> food = hint['food'];
          if (food.containsKey('label')) {
            suggestions.add({
              'label': food['label'],
              'image': food['image'] ?? null,
              'calories': food['nutrients']['ENERC_KCAL']?.toDouble() ?? null,
              'protein': food['nutrients']['PROCNT']?.toDouble() ?? null,
              'fat': food['nutrients']['FAT']?.toDouble() ?? null,
              'carbs': food['nutrients']['CHOCDF']?.toDouble() ?? null,
            });
          }
        }
      }
    }

    return suggestions;
  } else {
    throw Exception('Failed to fetch suggestions');
  }
}
