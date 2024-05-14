// main.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'product_details_screen.dart';

void main() {
  runApp(MyApp());
}

class Product {
  final int id;
  final String name;
  final String brand;
  final String model;
  final double price;
  final String description;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.model,
    required this.price,
    required this.description,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['idproducto'],
      name: json['nombre'],
      brand: json['marca'],
      model: json['modelo'],
      price: json['precio'].toDouble(),
      description: json['descripcion'],
      imageUrl: json['imgprincipal'],
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: MyHomePage(title: 'Carrito'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<Product> products = []; // Inicializa la lista como una lista vacía
  int _selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final response = await http.get(Uri.parse('https://jgg2pllk-5251.use.devtunnels.ms/Api/Productos'));
    print(response.body);

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      setState(() {
        products = responseData.map((data) => Product.fromJson(data)).toList();
      });
    } else {
      throw Exception('Failed to load products');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onProductSelected(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(
          productName: product.name, // Pasamos el nombre del producto
          productDescription: product.description, // Pasamos la descripción del producto
          productImageUrl: product.imageUrl,
          productBrand: product.brand,
          productModel: product.model,
          productPrice: product.price,

        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(widget.title),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Buscar productos...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                          onChanged: (value) {
                            // Aquí puedes manejar los cambios en el texto de búsqueda
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          // Acción cuando se presiona el botón de búsqueda
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      body: products.isNotEmpty // Verifica si la lista de productos no está vacía
          ? GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Mostrar dos tarjetas por fila
          crossAxisSpacing: 8.0, // Espaciado horizontal entre las tarjetas
          mainAxisSpacing: 8.0, // Espaciado vertical entre las tarjetas
          childAspectRatio: 0.75, // Relación de aspecto para mantener el tamaño de las tarjetas
        ),
        itemCount: products.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              _onProductSelected(products[index]);
            },
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInImage(
                    placeholder: AssetImage('assets/placeholder.webp'), // Imagen de carga mientras se carga la imagen real
                    image: NetworkImage(products[index].imageUrl),
                    fit: BoxFit.cover, // Ajusta la imagen para cubrir el contenedor
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          products[index].name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(products[index].description),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      )
          : Center(child: CircularProgressIndicator()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Cuenta',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Carrito',
          ),
        ],
      ),
    );
  }
}
