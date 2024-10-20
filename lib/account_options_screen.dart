import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'firebase_service.dart'; // Import the firebase_service
import 'manage_products_screen.dart'; // Asegúrate de tener una pantalla para administrar productos

class AccountOptionsScreen extends StatefulWidget {
  @override
  _AccountOptionsScreenState createState() => _AccountOptionsScreenState();
}

class _AccountOptionsScreenState extends State<AccountOptionsScreen> {
  String? _firstName;
  String? _role;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid;
      String firstName = await getUserFirstName(uid);
      String role = await getUserRole(uid);
      setState(() {
        _firstName = firstName;
        _role = role;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Opciones de Cuenta'),
      ),
      body: ListView(
        children: [
          if (_firstName != null)
            ListTile(
              title: Text('Bienvenido $_firstName!'),
            ),
          ListTile(
            leading: Icon(Icons.login),
            title: Text('Iniciar sesión'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.app_registration),
            title: Text('Registrar'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegisterScreen()),
              );
            },
          ),
          if (_role == 'admin')
            ListTile(
              leading: Icon(Icons.admin_panel_settings),
              title: Text('Administrar Productos'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManageProductsScreen()),
                );
              },
            ),
          // Agrega más opciones según sea necesario
        ],
      ),
    );
  }
}
