import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

// Obtener productos


// Obtener roles de todos los usuarios
Future<Map<String, String>> getRoles() async {
  Map<String, String> roles = {};
  QuerySnapshot queryRoles = await db.collection('roles').get();
  queryRoles.docs.forEach((documento) {
    final dynamic roleData = documento.data();
    if (roleData != null && roleData.containsKey('role')) {
      roles[documento.id] = roleData['role'] as String;
    } else {
      roles[documento.id] = '';
    }
  });
  return roles;
}

// Obtener rol de un usuario específico
Future<String> getUserRole(String uid) async {
  DocumentSnapshot documentSnapshot = await db.collection('roles').doc(uid).get();
  if (documentSnapshot.exists) {
    Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
    return data['role'] ?? '';
  } else {
    return '';
  }
}

// Guardar productos en BD
Future<void> addProduct(Map<String, dynamic> productData) async {
  try {
    await db.collection('products').add(productData);
    print('Producto agregado correctamente');
  } catch (e) {
    print('Error al agregar el producto: $e');
  }
}


// Obtener productos
Future<List<Map<String, dynamic>>> getProducts() async {
  List<Map<String, dynamic>> products = [];
  try {
    QuerySnapshot querySnapshot = await db.collection('products').get();
    querySnapshot.docs.forEach((DocumentSnapshot document) {
      Map<String, dynamic> productData = Map<String, dynamic>.from(document.data() as Map<String, dynamic>);
      products.add({
        'documentId': document.id,  // Guardar el ID del documento
        'descripcion': productData['descripcion'] ?? '',
        'idproducto': productData['idproducto'] ?? 0,
        'imgprincipal': productData['imgprincipal'] ?? '',
        'marca': productData['marca'] ?? '',
        'modelo': productData['modelo'] ?? '',
        'nombre': productData['nombre'] ?? '',
        'precio': productData['precio'] ?? 0.0,
      });
    });
  } catch (e) {
    print('Error al obtener productos: $e');
  }
  return products;
}

// Actualizar producto en BD
Future<void> updateProduct(String documentId, Map<String, dynamic> productData) async {
  try {
    await db.collection('products').doc(documentId).update(productData);
    print('Producto actualizado correctamente');
  } catch (e) {
    print('Error al actualizar el producto: $e');
  }
}
// Guardar información del usuario en la colección 'users'
Future<void> addUser(String uid, String firstName, String lastName, String email) async {
  await db.collection('users').doc(uid).set({
    'uid': uid,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
  });
}

// Obtener el primer nombre de un usuario específico
Future<String> getUserFirstName(String uid) async {
  DocumentSnapshot documentSnapshot = await db.collection('users').doc(uid).get();
  if (documentSnapshot.exists) {
    Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
    return data['firstName'] ?? '';
  } else {
    return '';
  }
}

// Borrar producto en BD
Future<void> deleteProduct(String documentId) async {
  try {
    await db.collection('products').doc(documentId).delete();
    print('Producto borrado correctamente');
  } catch (e) {
    print('Error al borrar el producto: $e');
  }
}

// Crear un nuevo carrito y obtener su ID
Future<String> createCart(String userId) async {
  try {
    final docRef = await db.collection('carrito').add({
      'idusuario': userId,
      'idproductos': [],
    });
    print('Carrito creado correctamente con ID: ${docRef.id}');
    return docRef.id;
  } catch (e) {
    print('Error al crear el carrito: $e');
    return ''; // Devuelve un string vacío en caso de error
  }
}

// Obtener el carrito de un usuario específico
Future<Map<String, dynamic>?> getCart(String userId) async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('carrito').where('idusuario', isEqualTo: userId).limit(1).get();
    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot cartDocument = querySnapshot.docs.first;
      Map<String, dynamic> cartData = cartDocument.data() as Map<String, dynamic>;
      cartData['id'] = cartDocument.id; // Agregar el ID del documento al mapa de datos
      return cartData;
    } else {
      return null;
    }
  } catch (e) {
    print('Error al obtener el carrito: $e');
    return null;
  }
}

//obtener los datos del carrito
Future<List<Map<String, dynamic>>?> getCartProductsDetails() async {
  try {
    List<Map<String, dynamic>> cartProductsDetails = [];

    // Obtener el ID del usuario actualmente autenticado
    final userId = await getCurrentUserId();

    // Obtener el carrito del usuario actual
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('carrito').where('idusuario', isEqualTo: userId).limit(1).get();
    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot cartDocument = querySnapshot.docs.first;
      Map<String, dynamic> cartData = cartDocument.data() as Map<String, dynamic>;

      // Verificar si hay productos en el carrito
      if (cartData.containsKey('idproductos') && cartData['idproductos'] != null && cartData['idproductos'] is List) {
        List<dynamic> productIds = cartData['idproductos'];

        // Recorrer cada ID de producto en el carrito
        for (dynamic productId in productIds) {
          // Obtener los detalles del producto con el ID correspondiente
          DocumentSnapshot productDocument = await FirebaseFirestore.instance.collection('products').doc(productId).get();
          if (productDocument.exists) {
            Map<String, dynamic> productData = productDocument.data() as Map<String, dynamic>;
            productData['id'] = productDocument.id; // Agregar el ID del documento al mapa de datos del producto
            cartProductsDetails.add(productData); // Agregar los detalles del producto al carrito
          }
        }
      }
    }

    return cartProductsDetails;
  } catch (e) {
    print('Error al obtener los detalles del carrito: $e');
    return null;
  }
}



// Agregar un producto al carrito
// Agregar un producto al carrito
Future<void> addProductToCart(String productId) async {
  try {
    // Obtener el ID del usuario actualmente autenticado
    final userId = await getCurrentUserId();

    // Verificar si ya existe un carrito para el usuario actual
    final cartQuerySnapshot = await FirebaseFirestore.instance
        .collection('carrito')
        .where('idusuario', isEqualTo: userId)
        .limit(1)
        .get();

    if (cartQuerySnapshot.docs.isNotEmpty) {
      // Si existe un carrito, obtener su ID
      final cartId = cartQuerySnapshot.docs.first.id;

      // Agregar el producto al carrito existente
      final cartRef = FirebaseFirestore.instance.collection('carrito').doc(cartId);
      await cartRef.update({
        'idproductos': FieldValue.arrayUnion([productId]),
      });
      print('Producto agregado al carrito existente correctamente');
    } else {
      // Si no existe un carrito, crear uno nuevo
      final newCartRef = FirebaseFirestore.instance.collection('carrito').doc();
      print('carrito creado ');

      // Agregar el usuario y el producto al nuevo carrito
      await newCartRef.set({
        'idusuario': userId,
        'idproductos': [productId],
      });
      print('Carrito creado y producto agregado correctamente');
    }
  } catch (e) {
    print('Error al agregar producto al carrito: $e');
  }
}



// Eliminar un producto del carrito
Future<void> removeProductFromCart(String userId, String productId) async {
  try {
    // Obtener el carrito del usuario actual
    final cartQuerySnapshot = await FirebaseFirestore.instance
        .collection('carrito')
        .where('idusuario', isEqualTo: userId)
        .limit(1)
        .get();

    if (cartQuerySnapshot.docs.isNotEmpty) {
      // Si existe un carrito para el usuario, obtener su ID
      final cartId = cartQuerySnapshot.docs.first.id;

      // Referencia al documento del carrito
      final cartRef = FirebaseFirestore.instance.collection('carrito').doc(cartId);

      // Eliminar el producto del array en el carrito
      await cartRef.update({
        'idproductos': FieldValue.arrayRemove([productId]),
      });

      print('Producto eliminado del carrito correctamente');
    } else {
      // Manejar el caso en que no se encuentre el carrito del usuario
      print('No se encontró un carrito para el usuario');
    }
  } catch (e) {
    print('Error al eliminar producto del carrito: $e');
  }
}



// Obtener el ID del usuario actualmente autenticado
Future<String?> getCurrentUserId() async {
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user = auth.currentUser;
  return user?.uid;
}


Future<String?> getProductDocumentId(int productId) async {
  try {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await db
        .collection('products')
        .where('idproducto', isEqualTo: productId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id;
    } else {
      print('Producto no encontrado en la base de datos');
      return null;
    }
  } catch (e) {
    print('Error al buscar el producto en la base de datos: $e');
    return null;
  }
}
