import 'package:flutter/material.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  static const routeName = '/sync';

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  bool connected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F4),
      appBar: AppBar(
        title: const Text('Sincronizacion Arduino'),
        backgroundColor: const Color(0xFFF0EEE9),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dispensador inteligente',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFF865228),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Gestiona la conexion y programa horarios de alimentacion.',
              style: TextStyle(color: Color(0xFF3D494C)),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF006879), Color(0xFF2AB6D1)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.sync, color: Colors.white, size: 32),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      connected ? 'Dispositivo conectado' : 'Dispositivo desconectado',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ),
                  Switch.adaptive(
                    value: connected,
                    onChanged: (value) => setState(() => connected = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Card(
              child: ListTile(
                leading: Icon(Icons.schedule),
                title: Text('Horario 1: 07:00 AM'),
                subtitle: Text('Comida de la manana'),
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.schedule),
                title: Text('Horario 2: 06:00 PM'),
                subtitle: Text('Comida de la tarde'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
