import 'package:flutter/material.dart';

class FirstAidScreen extends StatelessWidget {
  const FirstAidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Primeros Auxilios')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildFirstAidCard(
            title: 'Mordedura de Serpiente',
            steps: [
              'Mantenga la calma y limite el movimiento',
              'Quite anillos, relojes u objetos que puedan comprimir',
              'Limpie la herida con agua y jabón',
              'No aplique torniquete',
              'No succione el veneno',
              'Busque atención médica inmediatamente',
            ],
            icon: Icons.dangerous,
          ),
          const SizedBox(height: 16.0),
          _buildFirstAidCard(
            title: 'Picadura de Araña',
            steps: [
              'Lave el área con agua y jabón',
              'Aplique compresas frías',
              'Eleve la extremidad afectada',
              'Tome foto del animal si es posible',
              'Busque atención médica si hay reacción',
            ],
            icon: Icons.pest_control,
          ),
          const SizedBox(height: 16.0),
          _buildFirstAidCard(
            title: 'Picadura de Escorpión',
            steps: [
              'Lave la zona afectada',
              'Aplique hielo para reducir el dolor',
              'Mantenga el área afectada inmóvil',
              'Monitoree los síntomas',
              'Busque atención médica',
            ],
            icon: Icons.warning,
          ),
          const SizedBox(height: 16.0),
          _buildEmergencyContacts(),
        ],
      ),
    );
  }

  Widget _buildFirstAidCard({
    required String title,
    required List<String> steps,
    required IconData icon,
  }) {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 24.0),
                const SizedBox(width: 8.0),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            ...steps.map(
              (step) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 16.0)),
                    Expanded(
                      child: Text(step, style: const TextStyle(fontSize: 16.0)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContacts() {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.emergency, color: Colors.red),
                SizedBox(width: 8.0),
                Text(
                  'Contactos de Emergencia',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            _buildEmergencyContact('Emergencias', '911', Icons.phone_in_talk),
            _buildEmergencyContact(
              'Centro Toxicológico',
              '(555) 123-4567',
              Icons.local_hospital,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContact(String title, String number, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20.0, color: Colors.red),
          const SizedBox(width: 8.0),
          Text(
            '$title: ',
            style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
          ),
          Text(
            number,
            style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
