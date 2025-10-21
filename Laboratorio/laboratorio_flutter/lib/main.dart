import 'package:flutter/material.dart';
// Importamos los archivos del proyecto
import 'models/item.dart'; 
import 'services/item_service.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRUD Flutter & MongoDB',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      // Pantalla inicial para el registro/POST
      home: const UserInputScreen(), 
    );
  }
}

// ==========================================================
// PANTALLA 1: ENVÍO DE DATOS (POST)
// ==========================================================

class UserInputScreen extends StatefulWidget {
  const UserInputScreen({super.key});

  @override
  State<UserInputScreen> createState() => _UserInputScreenState();
}

class _UserInputScreenState extends State<UserInputScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController(); 
  final ItemService _itemService = ItemService(); 

  String _message = 'Ingresa el Nombre y la Descripción.';
  bool _isLoading = false; 

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  void _sendDataToApi() async {
    String nombre = _nameController.text.trim();
    String descripcion = _descriptionController.text.trim(); 

    if (nombre.isEmpty || descripcion.isEmpty) {
      setState(() {
        _message = '¡Error! Completa ambos campos.';
      });
      return; 
    }

    setState(() {
      _isLoading = true;
      _message = 'Enviando datos a Render...';
    });

    try {
      await _itemService.createItem(nombre, descripcion);

      setState(() {
        _message = '✅ ¡Éxito! Datos guardados en MongoDB.';
        _nameController.clear();
        _descriptionController.clear();
      });
      
      // Navegamos al listado al tener éxito
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ItemListScreen()),
      );

    } catch (e) {
      setState(() {
        _message = '❌ Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro (POST a API)'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Muestra el mensaje de estado
              Text(
                _message,
                style: TextStyle(fontSize: 16, color: _message.startsWith('❌') ? Colors.red : Colors.green),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _nameController,
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Nombre del Ítem'),
              ),
              const SizedBox(height: 15),

              TextField(
                controller: _descriptionController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Descripción'),
              ),
              const SizedBox(height: 30),

              // Botón de Acción
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _sendDataToApi,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      ),
                      child: const Text('ENVIAR A LA API (POST)'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================================
// PANTALLA 2: LISTADO Y ELIMINACIÓN (GET y DELETE)
// ==========================================================

class ItemListScreen extends StatefulWidget {
  const ItemListScreen({super.key});

  @override
  State<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  // El Future que guarda el estado de la petición GET
  late Future<List<Item>> _futureItems; 
  final ItemService _itemService = ItemService();

  @override
  void initState() {
    super.initState();
    _futureItems = _itemService.getItems(); 
  }

  // Recarga los datos (llamando a la API de nuevo)
  void _reloadData() {
    setState(() {
      _futureItems = _itemService.getItems();
    });
  }
  
  // Función para eliminar un ítem (DELETE)
  void _deleteItem(String id) async {
    try {
      await _itemService.deleteItem(id);
      _reloadData(); // Vuelve a cargar la lista para quitar el ítem eliminado
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ítem eliminado con éxito'))
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: ${e.toString()}'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listado de Ítems (GET desde API)'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reloadData,
          )
        ],
      ),
      body: FutureBuilder<List<Item>>( // El widget clave para datos asíncronos
        future: _futureItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final item = snapshot.data![index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text('ID: ${item.id} - Creado: ${item.createdAt.day}/${item.createdAt.month}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteItem(item.id!), // Llama a DELETE
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No hay ítems registrados.'));
          }
        },
      ),
      // Botón para volver a la pantalla de registro
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        child: const Icon(Icons.arrow_back),
      ),
    );
  }
}

