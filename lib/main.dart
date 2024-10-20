import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'product_details_screen.dart';
import 'account_options_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'firebase_service.dart';
import 'add_product_screen.dart';  // Importa la pantalla de agregar producto
import 'edit_product_screen.dart'; // Importa la pantalla de editar producto
import 'carrito_compras.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class Product {

  final String id;
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
      id: json['documentId'],
      name: json['nombre'],
      brand: json['marca'],
      model: json['modelo'],
      price: json['precio'] is String ? double.tryParse(json['precio']) ?? 0.0 : json['precio'],
      description: json['descripcion'],
      imageUrl: json['imgprincipal'],
    );
  }
}




class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const MyHomePage(title: 'Carrito'),
      routes: {
        '/login': (context) => LoginScreen(),
        '/accountOptions': (context) => AccountOptionsScreen(),
      },
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
  late List<Product> products = [];
  late List<Product> filteredProducts = [];
  int _selectedIndex = 0;
  String? _userRole;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final List<Map<String, dynamic>> responseData = await getProducts();
      setState(() {
        products = responseData.map((data) => Product.fromJson(data)).toList();
        filteredProducts = products;  // Initialize filteredProducts with all products
      });
    } catch (e) {
      print('Error al obtener productos: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 2) { // Verificar si se seleccionó el ícono del carrito
        _navigateToCart(); // Navegar a la pantalla del carrito
      } else if (_selectedIndex == 1) {
        _navigateToAccountOptions(); // Navegar a la pantalla de opciones de cuenta
      }
    });
  }


  void _onProductSelected(Product product) async {
    String? documentId = await product.id;

    if (documentId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailsScreen(
            documentId: documentId,
            productName: product.name,
            productDescription: product.description,
            productImageUrl: product.imageUrl,
            productBrand: product.brand,
            productModel: product.model,
            productPrice: product.price,
          ),
        ),
      );
    } else {
      // Manejar el caso en que no se puede encontrar el ID del documento
      print('Error: No se pudo encontrar el ID del documento para el producto');
    }
  }



  void _navigateToAccountOptions() async {
    final role = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AccountOptionsScreen()),
    );

    if (role != null) {
      setState(() {
        _userRole = role;
      });
    }
  }

  void _navigateToCart() async {
    // Navegar a la pantalla del carrito y esperar el resultado
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ShoppingCartScreen(userId: 'someUserId')), // Reemplaza 'someUserId' con el ID de usuario adecuado
    );

    // Si el resultado no es nulo, actualiza el estado del usuario
    if (result != null) {
      setState(() {
        _userRole = result;
      });
    }
  }


  void _filterProducts(String query) {
    setState(() {
      _searchQuery = query;
      filteredProducts = products.where((product) {
        return product.name.toLowerCase().contains(query.toLowerCase()) ||
            product.description.toLowerCase().contains(query.toLowerCase()) ||
            product.brand.toLowerCase().contains(query.toLowerCase()) ||
            product.model.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> _navigateToAddProduct() async {
    bool? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddProductScreen()),
    );

    if (result == true) {
      fetchProducts();
    }
  }

  Future<void> _navigateToEditProduct(String documentId, Product productData) async {
    bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductScreen(documentId: documentId, productData: productData),
      ),
    );

    if (result == true) {
      fetchProducts();
    }
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
                          decoration: const InputDecoration(
                            hintText: 'Buscar productos...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                          onChanged: (value) {
                            _filterProducts(value);  // Filtrar productos a medida que se escribe
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          _filterProducts(_searchQuery);  // Filtrar productos cuando se presiona el botón de búsqueda
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
      body: filteredProducts.isNotEmpty
          ? GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 0.75,
        ),
        itemCount: filteredProducts.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              _onProductSelected(filteredProducts[index]);
            },
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4.0),
                        topRight: Radius.circular(4.0),
                      ),
                      child: FadeInImage(
                        placeholder: const AssetImage('assets/placeholder.webp'),
                        image: NetworkImage(filteredProducts[index].imageUrl),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          filteredProducts[index].name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          filteredProducts[index].description,
                          maxLines: 2, // Limitar a 2 líneas
                          overflow: TextOverflow.ellipsis, // Mostrar puntos suspensivos
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      )
          : const Center(child: CircularProgressIndicator()),
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
      floatingActionButton: _userRole == 'admin'
          ? FloatingActionButton(
        onPressed: _navigateToAddProduct,
        child: Icon(Icons.add),
      )
          : null,
    );
  }
}
