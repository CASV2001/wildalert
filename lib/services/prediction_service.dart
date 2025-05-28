import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart';

class PredictionService {
  static final String baseUrl =
      Platform.isAndroid
          ? 'http://10.0.2.2:5050' // Special IP for Android emulator to access host machine
          : 'http://localhost:5050';

  Process? _serverProcess;
  bool _isStarting = false;

  Future<List<Map<String, dynamic>>> predictImage(File imageFile) async {
    try {
      // Asegurarse de que el servidor esté iniciado
      final serverStarted = await startPythonServer();
      if (!serverStarted) {
        throw Exception('No se pudo iniciar el servidor Python');
      }

      // Crear la solicitud multipart
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/predict'),
      );

      // Añadir la imagen al request
      var imageStream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();
      var multipartFile = http.MultipartFile(
        'image',
        imageStream,
        length,
        filename: path.basename(imageFile.path),
      );
      request.files.add(multipartFile);

      // Enviar la solicitud
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['predictions']);
      } else {
        throw Exception('Error en la predicción: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al procesar la imagen: $e');
    }
  }

  Future<bool> startPythonServer() async {
    if (_serverProcess != null) {
      return true; // Server already running
    }

    if (_isStarting) {
      // Esperar hasta que el servidor termine de iniciar
      await Future.delayed(const Duration(seconds: 1));
      return _serverProcess != null;
    }

    _isStarting = true;
    try {
      // Usar la ruta absoluta al directorio del backend
      final serverDir = r'c:\Users\pukil\Desktop\wildalert\wildalert\backend';
      print('Checking server directory: $serverDir');

      // Verificar si el directorio y archivo existen
      final dir = Directory(serverDir);
      if (!await dir.exists()) {
        print('Error: Directory not found: $serverDir');
        return false;
      }

      final serverFile = path.join(serverDir, 'server.py');
      if (!await File(serverFile).exists()) {
        print('Error: Server file not found: $serverFile');
        return false;
      }
      print('Starting Python server from: $serverFile');

      // Iniciar el servidor Python
      _serverProcess = await Process.start(
        'python',
        ['-u', serverFile], // -u para output sin buffering
        workingDirectory: serverDir,
        mode: ProcessStartMode.inheritStdio,
      );

      // Mostrar el PID del proceso
      print('Server process started with PID: ${_serverProcess?.pid}');

      // Esperar un poco para que el servidor se inicie
      await Future.delayed(const Duration(seconds: 2));

      // Verificar si el servidor sigue vivo
      if (_serverProcess == null || !await isServerResponding()) {
        print('Error: Server failed to start or is not responding');
        await dispose();
        return false;
      }

      return true;
    } catch (e) {
      print('Error starting Python server: $e');
      return false;
    } finally {
      _isStarting = false;
    }
  }

  Future<bool> isServerResponding() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/predict'));
      return response.statusCode ==
          404; // 404 significa que el endpoint existe pero requiere POST
    } catch (e) {
      return false;
    }
  }

  Future<void> dispose() async {
    if (_serverProcess != null) {
      _serverProcess!.kill();
      _serverProcess = null;
    }
  }
}
