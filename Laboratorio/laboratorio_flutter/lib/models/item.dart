import 'dart:convert';

class Item {
  // Campos de la clase (ID, Nombre, Descripción, Fecha)
  final String? id; 
  final String name;
  final String description;
  final DateTime createdAt;

  Item({
    this.id,
    required this.name,
    required this.description,
    required this.createdAt,
  });

  // ----------------------------------------------------
  // 1. LECTURA (Recibir datos del servidor)
  // ----------------------------------------------------

  // Constructor para mapear el JSON (Map<String, dynamic>)
  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['_id'] as String?, // Usamos '_id' de MongoDB
      name: map['name'] as String,
      description: map['description'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
  
  // Constructor de conveniencia para decodificar la CADENA JSON cruda
  factory Item.fromJson(String source) => Item.fromMap(json.decode(source) as Map<String, dynamic>);

  // ----------------------------------------------------
  // 2. ESCRITURA (Enviar datos al servidor)
  // ----------------------------------------------------

  // Método para convertir el objeto Dart a un Map para enviar
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'description': description,
    };
  }
  
  // Método para convertir el Map a una CADENA JSON
  String toJson() => json.encode(toMap());
}

