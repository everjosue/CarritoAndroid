import 'package:flutter/material.dart';
import 'firebase_service.dart'; // Importa el servicio de Firebase
import 'add_product_screen.dart';
import 'edit_product_screen.dart';
import 'main.dart'; // Importa la definición de la clase Product

class ManageProductsScreen extends StatefulWidget {
  @override

  _ManageProductsScreenState createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  late Future<List<Map<String, dynamic>>> _futureProducts;

  @override
  void initState() {
    super.initState();
    _futureProducts = getProducts();
  }

  void _refreshProducts() {
    setState(() {
      _futureProducts = getProducts();
    });
  }

  void _deleteProduct(String documentId) async {
    await deleteProduct(documentId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Producto eliminado correctamente')),
    );
    _refreshProducts(); // Llama a _refreshProducts() después de eliminar el producto
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Administrar Productos'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Acción para crear un nuevo producto
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => AddProductScreen()),
              ).then((_) => _refreshProducts());
            },
          ),
          IconButton(
            icon: Icon(Icons.supervised_user_circle),
            onPressed: () {
              // Acción para administrar roles
              print('Administrando roles');
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Map<String, dynamic>> products = snapshot.data!;
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (BuildContext context, int index) {
                final productMap = products[index];
                final product = Product.fromJson(productMap); // Convierte el mapa a un objeto Product
                return ListTile(
                  leading: SizedBox(
                    width: 50,
                    height: 50,
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(product.name),
                  subtitle: Text(product.description),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          // Navegar a la pantalla de edición con los datos del producto actual
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProductScreen(
                                documentId: productMap['documentId'], // Asegúrate de que 'documentId' esté en el mapa
                                productData: product,
                              ),
                            ),
                          ).then((_) => _refreshProducts());
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          // Confirmar la eliminación del producto
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Confirmar eliminación'),
                                content: Text('¿Estás seguro de que deseas eliminar ${product.name}?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _deleteProduct(productMap['documentId']); // Asegúrate de que 'documentId' esté en el mapa
                                    },
                                    child: Text('Eliminar'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
