import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wildalert/services/animal_recognition_service.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  CameraController? _controller;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(cameras[0], ResolutionPreset.high);
    await _controller?.initialize();
    if (mounted) {
      setState(() => _isCameraInitialized = true);
    }
  }

  Future<void> _takePicture() async {
    if (!_isCameraInitialized) return;

    try {
      final XFile? picture = await _controller?.takePicture();
      if (picture != null) {
        final file = File(picture.path);
        final result = await AnimalRecognitionService().recognizeAnimal(file);
        debugPrint('Resultado del modelo (foto cámara): $result');
        _showResultDialog(result);
      }
    } catch (e) {
      debugPrint('Error taking picture: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final file = File(image.path);
      final result = await AnimalRecognitionService().recognizeAnimal(file);
      debugPrint('Resultado del modelo (galería): $result');
      _showResultDialog(result);
    }
  }

  /// Muestra un diálogo con las predicciones formateadas.
  void _showResultDialog(Map<String, double> result) {
    final formatted = result.entries
        .map((e) => '${e.key}: ${(e.value * 100).toStringAsFixed(2)}%')
        .join('\n');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Predicción'),
        content: Text(formatted),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Identificar Animal')),
      body: Column(
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: CameraPreview(_controller!),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  onPressed: _pickFromGallery,
                  heroTag: 'gallery',
                  child: const Icon(Icons.photo_library),
                ),
                FloatingActionButton(
                  onPressed: _takePicture,
                  heroTag: 'camera',
                  child: const Icon(Icons.camera),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}