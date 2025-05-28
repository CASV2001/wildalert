import 'package:flutter/material.dart';
import 'package:wildalert/services/chat_gpt_service.dart';
import 'package:url_launcher/url_launcher.dart';

class AnimalInfoScreen extends StatefulWidget {
  final String animalName;
  const AnimalInfoScreen({super.key, required this.animalName});

  @override
  State<AnimalInfoScreen> createState() => _AnimalInfoScreenState();
}

class _AnimalInfoScreenState extends State<AnimalInfoScreen>
    with SingleTickerProviderStateMixin {
  late final Future<_AnimalInfo> _infoFuture;
  late final AnimationController _fadeCtrl;
  final _chat = ChatGPTService();

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _infoFuture = _fetchAnimalInfo();
  }

  Future<_AnimalInfo> _fetchAnimalInfo() async {
    final prompt = '''
Proporcióname una ficha informativa sobre ${widget.animalName} con los siguientes campos (1 línea por ítem):

🕷️ Nombre común:
🔬 Nombre científico:
🌍 Hábitat:
⚠️ Peligrosidad:
💡 Consejo para evitar encuentros:
🚨 Qué hacer ante un encuentro:
🩹 Primeros auxilios:
📚 Wikipedia: URL directa (sin corchetes)

Responde en español.
''';

    final raw = await _chat.getChatResponse(prompt);
    debugPrint('🔍 ChatGPT response:\n$raw');

    final lines = raw.trim().split(RegExp(r'\n+'));
    final wikiLine = lines.firstWhere((l) => l.startsWith('📚'), orElse: () => '');
    final wikiUrl = wikiLine.replaceFirst('📚 Wikipedia:', '').trim();

    final infoLines =
    lines.where((l) => !l.startsWith('📚')).toList(growable: false);

    return _AnimalInfo(lines: infoLines, wikiUrl: wikiUrl);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Información: ${widget.animalName}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEFF9F5), Color(0xFFCEEBE5)],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<_AnimalInfo>(
            future: _infoFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || snapshot.data == null) {
                return Center(
                  child: Text(
                    'No se pudo cargar la información.',
                    style: theme.textTheme.bodyLarge,
                  ),
                );
              }

              _fadeCtrl.forward();
              final info = snapshot.data!;

              return FadeTransition(
                opacity:
                CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 28, horizontal: 22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final line in info.lines)
                                Padding(
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    line,
                                    style: theme.textTheme.bodyLarge
                                        ?.copyWith(height: 1.5),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (info.wikiUrl.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        TextButton.icon(
                          icon: const Icon(Icons.language),
                          label: const Text('Ver más en Wikipedia'),
                          onPressed: () async {
                            final url = Uri.parse(info.wikiUrl);

                            // Siempre intenta abrirlo en WebView primero
                            try {
                              final launched = await launchUrl(
                                url,
                                mode: LaunchMode.inAppWebView,
                              );
                              if (!launched) _showLaunchError();
                            } catch (e) {
                              debugPrint('❌ Error abriendo URL: $e');
                              _showLaunchError();
                            }
                          },
                        ),
                      ]
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showLaunchError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No se pudo abrir el enlace.')),
    );
  }
}

class _AnimalInfo {
  final List<String> lines;
  final String wikiUrl;
  _AnimalInfo({
    required this.lines,
    required this.wikiUrl,
  });
}