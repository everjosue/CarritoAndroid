import 'package:flutter/material.dart';
import 'firebase_service.dart';
import 'main.dart'; // Import your Product class

class EditProductScreen extends StatefulWidget {
  final String documentId;
  final Product productData;

  const EditProductScreen({Key? key, required this.documentId, required this.productData}) : super(key: key);

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nombreController;
  late TextEditingController descripcionController;
  late TextEditingController marcaController;
  late TextEditingController modeloController;
  late TextEditingController imgprincipalController;
  late TextEditingController precioController;

  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController(text: widget.productData.name);
    descripcionController = TextEditingController(text: widget.productData.description);
    marcaController = TextEditingController(text: widget.productData.brand);
    modeloController = TextEditingController(text: widget.productData.model);
    imgprincipalController = TextEditingController(text: widget.productData.imageUrl);
    precioController = TextEditingController(text: widget.productData.price.toString());
  }

  @override
  void dispose() {
    nombreController.dispose();
    descripcionController.dispose();
    marcaController.dispose();
    modeloController.dispose();
    imgprincipalController.dispose();
    precioController.dispose();
    super.dispose();
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        Map<String, dynamic> updatedProductData = {
          'nombre': nombreController.text,
          'descripcion': descripcionController.text,
          'marca': marcaController.text,
          'modelo': modeloController.text,
          'imgprincipal': imgprincipalController.text,
          'precio': double.parse(precioController.text),
        };

        await updateProduct(widget.documentId, updatedProductData);

        // Mostrar un snackbar de éxito y retroceder
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Producto actualizado correctamente')),
        );
        Navigator.of(context).pop(true); // Return true to indicate a product was edited
      } catch (e) {
        // Mostrar un snackbar de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar el producto')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Producto'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: nombreController,
                    decoration: InputDecoration(
                      labelText: 'Nombre',
                      prefixIcon: Icon(Icons.label),
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el nombre del producto';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: descripcionController,
                    decoration: InputDecoration(
                      labelText: 'Descripción',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa la descripción del producto';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: marcaController,
                    decoration: InputDecoration(
                      labelText: 'Marca',
                      prefixIcon: Icon(Icons.branding_watermark),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa la marca del producto';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: modeloController,
                    decoration: InputDecoration(
                      labelText: 'Modelo',
                      prefixIcon: Icon(Icons.model_training),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el modelo del producto';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: imgprincipalController,
                    decoration: InputDecoration(
                      labelText: 'URL de la imagen',
                      prefixIcon: Icon(Icons.image),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa la URL de la imagen';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: precioController,
                    decoration: InputDecoration(
                      labelText: 'Precio',
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el precio del producto';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Por favor ingresa un valor numérico';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                    child: Text('Guardar Cambios'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
