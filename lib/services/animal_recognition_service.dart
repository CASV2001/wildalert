import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Servicio que envía una imagen al backend Flask (PyTorch)
/// y devuelve un mapa con las probabilidades por especie.
class AnimalRecognitionService {
  static final AnimalRecognitionService _instance =
      AnimalRecognitionService._internal();

  factory AnimalRecognitionService() => _instance;

  AnimalRecognitionService._internal();

  /// URLs para el servidor según el entorno
  static const String _emulatorUrl = 'http://10.0.2.2:5050/predict';
  static const String _deviceUrl = 'http://10.0.1.34:5050/predict';

  /// Selecciona la URL correcta según si estamos en emulador o dispositivo físico
  static String get _baseUrl {
    // Platform.isAndroid ya está importado desde dart:io
    if (Platform.isAndroid) {
      try {
        // Esta es una forma de detectar si estamos en el emulador
        File('/proc/sys/fs/binfmt_misc/WSLInterop').statSync();
        return _emulatorUrl;
      } catch (_) {
        return _deviceUrl;
      }
    }
    return _deviceUrl;
  }

  /// Envía [imageFile] al endpoint `/predict` y recibe las predicciones.
  /// Devuelve un `Map<label, confidence>`.
  Future<Map<String, double>> recognizeAnimal(File imageFile) async {
    final uri = Uri.parse(_baseUrl);

    // Construye la petición multipart con la imagen
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      final predictions = data['predictions'] as List;

      // Convierte la lista de predicciones a Map<String, double>
      return {
        for (var pred in predictions)
          pred['label'] as String: (pred['confidence'] as num).toDouble(),
      };
    } else {
      throw Exception('Error ${response.statusCode}: $responseBody');
    }
  }
}
