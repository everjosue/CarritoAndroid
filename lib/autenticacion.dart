import 'package:flutter/material.dart';
import 'usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';


class autenticacion {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Registrar usuario con correo electrónico y contraseña
  Future<Usuario> registrarUsuarioConCorreoElectronicoYContrasena({
    required String nombre,
    required String apellido,
    required String correoElectronico,
    required String contrasena,
  }) async {
    // Crea un usuario en Firebase Authentication
    final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: correoElectronico,
      password: contrasena,
    );

    // Obtiene la información del usuario y crea un objeto Usuario
    final String uid = userCredential.user!.uid;
    final Usuario usuario = Usuario(
      uid: uid,
      nombre: nombre,
      apellido: apellido,
      correoElectronico: correoElectronico,
    );

    return usuario;
  }

  // Iniciar sesión con correo electrónico y contraseña
  Future<Usuario> iniciarSesionConCorreoElectronicoYContrasena({
    required String correoElectronico,
    required String contrasena,
  }) async {
    // Inicia sesión en Firebase Authentication
    final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: correoElectronico,
      password: contrasena,
    );

    // Obtiene la información del usuario y crea un objeto Usuario
    final String uid = userCredential.user!.uid;
    final Usuario usuario = Usuario(
      uid: uid,
      nombre: '', // Nombre no disponible desde la instancia de usuario de inicio de sesión
      apellido: '', // Apellido no disponible desde la instancia de usuario de inicio de sesión
      correoElectronico: correoElectronico,
    );

    return usuario;
  }

  // Obtener usuario actual (si está iniciado sesión)
  Usuario? obtenerUsuarioActual() {
    final User? usuarioActual = _auth.currentUser;
    if (usuarioActual != null) {
      return Usuario(
        uid: usuarioActual.uid,
        nombre: usuarioActual.displayName ?? '', // Nombre de pantalla, si está disponible
        apellido: '', // Apellido no disponible desde la instancia de usuario actual
        correoElectronico: usuarioActual.email!,
      );
    } else {
      return null;
    }
  }

  // Cerrar sesión
  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }
}
