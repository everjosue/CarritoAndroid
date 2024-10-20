import 'autenticacion.dart';
class Usuario {
  String uid; // Identificador único de usuario (proporcionado por Firebase)
  String nombre;
  String apellido;
  String correoElectronico;

  Usuario({
    required this.uid,
    required this.nombre,
    required this.apellido,
    required this.correoElectronico,
  });
}
