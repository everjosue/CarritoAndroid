import 'package:flutter/material.dart';
import 'firebase_service.dart'; // Importa el servicio de Firebase
import 'package:firebase_auth/firebase_auth.dart';

class ProductDetailsScreen extends StatelessWidget {
  final String documentId; // Define documentId como un atributo de la clase
  final String productName;
  final String productDescription;
  final String productImageUrl;
  final String productBrand;
  final String productModel;
  final double productPrice;

  const ProductDetailsScreen({
    Key? key,
    required this.documentId, // Agrega documentId al constructor
    required this.productName,
    required this.productDescription,
    required this.productImageUrl,
    required this.productBrand,
    required this.productModel,
    required this.productPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalles del Producto"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 300, // Altura de la imagen
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  image: DecorationImage(
                    image: NetworkImage(productImageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                productName,
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                "Marca:",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                productBrand,
                style: const TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 8.0),
              const Text(
                "Modelo:",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                productModel,
                style: const TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 8.0),
              const Text(
                "Precio:",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                productPrice.toString(),
                style: const TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 8.0),
              const Text(
                "Descripción:",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                productDescription,
                style: const TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  final userId = FirebaseAuth.instance.currentUser?.uid;

                  if (userId != null) {
                    await addProductToCart(documentId);
                    // Muestra una notificación indicando que el producto se ha agregado correctamente
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Producto agregado al carrito correctamente'),
                      ),
                    );
                  } else {
                    // Si el usuario no está autenticado, muestra un SnackBar con un mensaje
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Necesitas iniciar sesión para agregar productos al carrito'),
                      ),
                    );
                  }
                },
                child: const Text("Agregar al Carrito"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
