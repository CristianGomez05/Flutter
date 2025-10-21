import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/item.dart';

// 🚨🚨 ¡MUY IMPORTANTE! REEMPLAZA ESTA URL CON TU URL REAL DE RENDER 
const String BASE_URL = 'https://mi-flutter-api.onrender.com/api/items'; 

class ItemService {
  
  // ==========================================================
  // 1. GET (READ)
  // ==========================================================
  Future<List<Item>> getItems() async {
    final response = await http.get(Uri.parse(BASE_URL));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((item) => Item.fromMap(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Fallo al cargar los ítems.');
    }
  }

  // ==========================================================
  // 2. POST (CREATE)
  // ==========================================================
  Future<Item> createItem(String name, String description) async {
    final newItemData = Item(name: name, description: description, createdAt: DateTime.now());
    
    final response = await http.post(
      Uri.parse(BASE_URL),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: newItemData.toJson(), // Usa el método toJson() del modelo
    );

    if (response.statusCode == 201) {
      return Item.fromJson(response.body); // Usa el constructor fromJson()
    } else {
      throw Exception('Fallo al crear el ítem. Status: ${response.statusCode}');
    }
  }
  
  // ==========================================================
  // 3. DELETE (DELETE)
  // ==========================================================
  Future<void> deleteItem(String id) async {
    final url = '$BASE_URL/$id'; 
    final response = await http.delete(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Fallo al eliminar el ítem. Status: ${response.statusCode}');
    }
  }
}

