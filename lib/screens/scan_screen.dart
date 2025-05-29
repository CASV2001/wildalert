import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wildalert/services/animal_recognition_service.dart';
import 'package:wildalert/screens/animal_info_screen.dart';

/// Pantalla para escanear o seleccionar imagen y obtener predicción del modelo.
/// Usa WidgetsBindingObserver para pausar la cámara al perder foco y evitar
/// el spam de "Unable to acquire a buffer item".
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(
      cameras[0],
      ResolutionPreset.medium, // menor resolución = menos buffers
      enableAudio: false,
    );

    await _controller?.initialize();
    if (mounted) setState(() => _isCameraInitialized = true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _controller?.dispose();
      _controller = null;
      setState(() => _isCameraInitialized = false);
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _takePicture() async {
    if (!_isCameraInitialized || _isProcessing) return;

    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Se requiere permiso de cámara')),
        );
      }
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final XFile? picture = await _controller?.takePicture();
      if (picture != null) {
        final file = File(picture.path);
        debugPrint('📸 Foto tomada: ${file.path}');
        debugPrint('📤 Enviando al servidor...');

        final result = await AnimalRecognitionService().recognizeAnimal(file);
        if (mounted) {
          _showResultDialog(result);
        }
      }
    } catch (e) {
      debugPrint('❌ Error procesando imagen: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _pickFromGallery() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final file = File(image.path);
        debugPrint('📸 Imagen seleccionada: ${file.path}');
        debugPrint('📤 Enviando al servidor...');

        final result = await AnimalRecognitionService().recognizeAnimal(file);
        if (mounted) {
          _showResultDialog(result);
        }
      }
    } catch (e) {
      debugPrint('❌ Error procesando imagen: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showResultDialog(Map<String, double> result) {
    if (result.isEmpty) return;

    final sorted =
        result.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final topPrediction = sorted.first.key;
    final formatted = sorted
        .map((e) => '${e.key}: ${(e.value * 100).toStringAsFixed(2)}%')
        .join('\n');

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Predicción'),
            content: Text(formatted),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: const Text('Saber más'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => AnimalInfoScreen(animalName: topPrediction),
                    ),
                    (route) => route.isFirst,
                  );
                },
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Identificar Animal')),
      body:
          _isCameraInitialized
              ? Stack(
                children: [
                  Column(
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
                              heroTag: 'gallery',
                              onPressed:
                                  _isProcessing ? null : _pickFromGallery,
                              child: const Icon(Icons.photo_library),
                            ),
                            FloatingActionButton(
                              heroTag: 'camera',
                              onPressed: _isProcessing ? null : _takePicture,
                              child: const Icon(Icons.camera_alt),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_isProcessing)
                    Container(
                      color: Colors.black54,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
              )
              : const Center(child: CircularProgressIndicator()),
    );
  }
}
