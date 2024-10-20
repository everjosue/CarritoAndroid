import 'package:flutter/material.dart';
import 'firebase_service.dart';

class ShoppingCartScreen extends StatefulWidget {
  final String userId;

  const ShoppingCartScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _ShoppingCartScreenState createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  late Future<List<Map<String, dynamic>>?> _futureCartProducts;

  @override
  void initState() {
    super.initState();
    _futureCartProducts = _loadCartDetails();
  }

  Future<List<Map<String, dynamic>>?> _loadCartDetails() async {
    return getCartProductsDetails(); // No es necesario pasar userId aquí
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carrito de Compras'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>?>(
        future: _futureCartProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay productos en el carrito'));
          } else {
            List<Map<String, dynamic>> cartProductsDetails = snapshot.data!;
            return ListView.builder(
              itemCount: cartProductsDetails.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 3,
                    child: ListTile(
                      leading: SizedBox(
                        width: 60,
                        height: 60,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            cartProductsDetails[index]['imgprincipal'],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      title: Text(cartProductsDetails[index]['nombre']),
                      subtitle: Text(cartProductsDetails[index]['descripcion']),
                      trailing: IconButton(
                        icon: Icon(Icons.remove_shopping_cart),
                        onPressed: () async {
                          final productId = cartProductsDetails[index]['id'];
                          final userId = await getCurrentUserId(); // Obtener el ID de usuario actual
                          if (userId != null) {
                            // Eliminar el producto del carrito
                            await removeProductFromCart(userId, productId);
                            setState(() {
                              _futureCartProducts = _loadCartDetails(); // Volver a cargar los datos del carrito
                            });
                          } else {
                            // Manejar el caso en que no se pueda obtener el ID de usuario
                            print('Error: No se pudo obtener el ID del usuario');
                          }
                        },
                      ),
                    ),
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
