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
      body: GridView.count(
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
    );
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
