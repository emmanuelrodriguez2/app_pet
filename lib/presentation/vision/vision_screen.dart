import 'package:flutter/material.dart';

class VisionScreen extends StatelessWidget {
  const VisionScreen({super.key});

  static const routeName = '/vision';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F4),
      appBar: AppBar(
        title: const Text('Vision y camara'),
        backgroundColor: const Color(0xFFF0EEE9),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Camara de salud',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFF865228),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Captura una imagen para analizar porciones y comportamiento alimenticio.',
              style: TextStyle(color: Color(0xFF3D494C)),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 240,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFBCC9CD).withOpacity(0.35)),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_camera, size: 54, color: Color(0xFF006879)),
                  SizedBox(height: 10),
                  Text('Previsualizacion de camara', style: TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.upload),
                    label: const Text('Subir imagen'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Abrir camara'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2AB6D1),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
