
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

// Representa un archivo seleccionado por el usuario.
class DocumentoArchivo {
  const DocumentoArchivo({
    required this.bytes,
    required this.nombre,
    required this.mimeType,
  });

  final Uint8List bytes;
  final String nombre;
  final String mimeType;
}

class DocumentoArchivoService {
  final ImagePicker _imagePicker = ImagePicker();

  // Selecciona un archivo PDF.
  Future<DocumentoArchivo?> seleccionarPdf() async {
    final archivo = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (archivo == null) {
      return null;
    }

    final bytes = await archivo.readAsBytes();

    if (bytes.isEmpty) {
      throw Exception('El archivo PDF está vacío.');
    }

    return DocumentoArchivo(
      bytes: bytes,
      nombre: archivo.name,
      mimeType: 'application/pdf',
    );
  }

  // Selecciona una fotografía de la galería.
  Future<DocumentoArchivo?> seleccionarFotografia() async {
    final imagen = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (imagen == null) {
      return null;
    }

    return _convertirImagen(imagen);
  }

  // Toma una fotografía utilizando la cámara.
  Future<DocumentoArchivo?> tomarFotografia() async {
    final imagen = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (imagen == null) {
      return null;
    }

    return _convertirImagen(imagen);
  }

  // Convierte la imagen seleccionada en datos binarios.
  Future<DocumentoArchivo> _convertirImagen(XFile imagen) async {
    final bytes = await imagen.readAsBytes();
    final nombre = imagen.name;
    final extension = nombre.split('.').last.toLowerCase();

    String mimeType;

    switch (extension) {
      case 'png':
        mimeType = 'image/png';
        break;
      case 'webp':
        mimeType = 'image/webp';
        break;
      case 'gif':
        mimeType = 'image/gif';
        break;
      default:
        mimeType = 'image/jpeg';
    }

    return DocumentoArchivo(
      bytes: bytes,
      nombre: nombre,
      mimeType: mimeType,
    );
  }
}
