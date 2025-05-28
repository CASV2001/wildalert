import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WildAlert'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return RadialGradient(
                    center: Alignment.center,
                    radius: 0.8,
                    colors: [Colors.white, Colors.white.withOpacity(0.3)],
                    stops: const [0.7, 1.0],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/app_icon.png',
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: GridView.count(
              padding: const EdgeInsets.all(16.0),
              crossAxisCount: 2,
              mainAxisSpacing: 16.0,
              crossAxisSpacing: 16.0,
              children: [
                _buildFeatureCard(
                  context,
                  'Identificar Animal',
                  Icons.camera_alt,
                  () => Navigator.pushNamed(context, '/scan'),
                ),
                _buildFeatureCard(
                  context,
                  'Mapa de Riesgo',
                  Icons.map,
                  () => Navigator.pushNamed(context, '/map'),
                ),
                _buildFeatureCard(
                  context,
                  'Primeros Auxilios',
                  Icons.medical_services,
                  () => Navigator.pushNamed(context, '/first-aid'),
                ),
                _buildFeatureCard(
                  context,
                  'Reportar Avistamiento',
                  Icons.warning,
                  () => Navigator.pushNamed(context, '/report'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.history),
                      const SizedBox(width: 8),
                      Text(
                        'Reportes Recientes',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    children: [
                      _buildReportItem(context, 'Viuda Negra', DateTime.now()),
                      _buildReportItem(
                        context,
                        'Violinista',
                        DateTime.now().subtract(const Duration(hours: 2)),
                      ),
                      _buildReportItem(
                        context,
                        'Viuda Negra',
                        DateTime.now().subtract(const Duration(days: 1)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportItem(
    BuildContext context,
    String animalName,
    DateTime date,
  ) {
    return Card(
      elevation: 0,
      child: ListTile(
        leading: const Icon(Icons.notifications),
        title: Text(animalName),
        subtitle: Text(_formatDate(date)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO: Implementar navegación al detalle del reporte
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} minutos';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} horas';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4.0,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48.0,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8.0),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
