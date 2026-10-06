import 'package:dog_center/presentation/sync/bluetooth_robot_panel.dart';
import 'package:dog_center/presentation/sync/services/roblex_wifi_client.dart';
import 'package:flutter/material.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key, this.runQuickDispense = false});

  static const routeName = '/sync';

  final bool runQuickDispense;

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  final _ipController = TextEditingController(text: '192.168.4.1');
  final _rawCmdController = TextEditingController();
  final _schedule1Controller = TextEditingController(text: '07:00');
  final _schedule2Controller = TextEditingController(text: '18:00');
  final _gramsController = TextEditingController(text: '80');
  final _client = const RoblexWifiClient();

  bool _connected = false;
  bool _loading = false;
  int _red = 120;
  int _green = 80;
  int _blue = 180;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.runQuickDispense) {
        _dispenseNow();
      }
    });
  }

  @override
  void dispose() {
    _ipController.dispose();
    _rawCmdController.dispose();
    _schedule1Controller.dispose();
    _schedule2Controller.dispose();
    _gramsController.dispose();
    super.dispose();
  }

  int get _grams {
    final parsed = int.tryParse(_gramsController.text.trim());
    if (parsed == null) return 80;
    return parsed.clamp(1, 500);
  }

  bool _validateWifiHost() {
    final host = _ipController.text.trim();
    final isBluetoothMac = RegExp(
      r'^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$',
    ).hasMatch(host);

    if (isBluetoothMac) {
      _toast(
        '00:4B:12:3E:21:5A es una direccion Bluetooth. '
        'Conecta Orion desde el panel BLE de arriba.',
      );
      return false;
    }

    if (host.isEmpty) {
      _toast('Escribe una IP WiFi, por ejemplo 192.168.4.1');
      return false;
    }

    return true;
  }

  Future<void> _testConnection() async {
    if (!_validateWifiHost()) return;
    setState(() => _loading = true);
    try {
      final ok = await _client.testConnection(_ipController.text);
      if (!mounted) return;
      setState(() => _connected = ok);
      _toast(ok ? 'Conexion exitosa con ROBLEX' : 'No se pudo conectar');
    } catch (e) {
      if (!mounted) return;
      setState(() => _connected = false);
      _toast('Error de conexion: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendRgb() async {
    setState(() => _loading = true);
    try {
      await _client.sendRgb(
        host: _ipController.text,
        red: _red,
        green: _green,
        blue: _blue,
      );
      if (!mounted) return;
      setState(() => _connected = true);
      _toast('Color enviado a ROBLEX');
    } catch (e) {
      if (!mounted) return;
      _toast('No se pudo enviar color: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _dispenseNow() async {
    setState(() => _loading = true);
    try {
      await _client.dispenseNow(host: _ipController.text, grams: _grams);
      if (!mounted) return;
      setState(() => _connected = true);
      _toast('Dispensacion enviada ($_grams g)');
    } catch (e) {
      if (!mounted) return;
      _toast('No se pudo dispensar: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _programSchedules() async {
    final slot1 = _schedule1Controller.text.trim();
    final slot2 = _schedule2Controller.text.trim();

    if (!_isValidHHMM(slot1) || !_isValidHHMM(slot2)) {
      _toast('Usa formato HH:MM (ej. 07:00)');
      return;
    }

    setState(() => _loading = true);
    try {
      await _client.setSchedule(
        host: _ipController.text,
        slot: 1,
        hhmm: slot1,
        grams: _grams,
      );
      await _client.setSchedule(
        host: _ipController.text,
        slot: 2,
        hhmm: slot2,
        grams: _grams,
      );
      if (!mounted) return;
      _toast('Horarios programados en ROBLEX');
    } catch (e) {
      if (!mounted) return;
      _toast('No se pudieron programar horarios: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendRaw() async {
    final cmd = _rawCmdController.text.trim();
    if (cmd.isEmpty) {
      _toast('Escribe un comando');
      return;
    }

    setState(() => _loading = true);
    try {
      await _client.sendRawCommand(host: _ipController.text, command: cmd);
      if (!mounted) return;
      _toast('Comando enviado');
    } catch (e) {
      if (!mounted) return;
      _toast('No se pudo enviar comando: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _isValidHHMM(String value) {
    final match = RegExp(r'^([01]\\d|2[0-3]):([0-5]\\d)$').hasMatch(value);
    return match;
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F4),
      appBar: AppBar(
        title: const Text('Sincronizacion Arduino / ROBLEX'),
        backgroundColor: const Color(0xFFF0EEE9),
      ),
      body: SingleChildScrollView(
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
              'Integracion ROBLEX por comandos HTTP. Base firmware: cmd=dispense:GRAMOS y cmd=schedule:SLOT:HH:MM:GRAMOS.',
              style: TextStyle(color: Color(0xFF3D494C)),
            ),
            const SizedBox(height: 18),
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
                      _connected
                          ? 'Dispositivo conectado'
                          : 'Dispositivo desconectado',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (_loading)
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const BluetoothRobotPanel(),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Conexion WiFi / HTTP (solo IP)',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _ipController,
                      decoration: const InputDecoration(
                        labelText: 'IP o host ROBLEX',
                        hintText: '192.168.4.1',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _loading ? null : _testConnection,
                        icon: const Icon(Icons.wifi_tethering),
                        label: const Text('Probar conexion'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Alimentacion',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _gramsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Gramos por porcion',
                        hintText: '80',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _loading ? null : _dispenseNow,
                        icon: const Icon(Icons.restaurant),
                        label: const Text('Dispensar ahora'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Comando enviado: cmd=dispense:GRAMOS',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6D797D)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Horarios',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _schedule1Controller,
                      decoration: const InputDecoration(
                        labelText: 'Horario 1 (HH:MM)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _schedule2Controller,
                      decoration: const InputDecoration(
                        labelText: 'Horario 2 (HH:MM)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _loading ? null : _programSchedules,
                        icon: const Icon(Icons.schedule_send),
                        label: const Text('Programar horarios'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Comandos enviados: cmd=schedule:1:HH:MM:GRAMOS y cmd=schedule:2:HH:MM:GRAMOS',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6D797D)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enviar color RGB',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text('R: $_red'),
                    Slider(
                      min: 0,
                      max: 255,
                      value: _red.toDouble(),
                      onChanged: (v) => setState(() => _red = v.round()),
                      activeColor: Colors.red,
                    ),
                    Text('G: $_green'),
                    Slider(
                      min: 0,
                      max: 255,
                      value: _green.toDouble(),
                      onChanged: (v) => setState(() => _green = v.round()),
                      activeColor: Colors.green,
                    ),
                    Text('B: $_blue'),
                    Slider(
                      min: 0,
                      max: 255,
                      value: _blue.toDouble(),
                      onChanged: (v) => setState(() => _blue = v.round()),
                      activeColor: Colors.blue,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _loading ? null : _sendRgb,
                        icon: const Icon(Icons.palette_outlined),
                        label: const Text('Enviar color'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Comando personalizado',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _rawCmdController,
                      decoration: const InputDecoration(
                        labelText: 'Comando',
                        hintText: 'ej: ping',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _loading ? null : _sendRaw,
                        icon: const Icon(Icons.send),
                        label: const Text('Enviar comando'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estado interno',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _client.buildRoblexInfo(
                        host: _ipController.text.trim(),
                        connected: _connected,
                      ),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nota iOS: el ejemplo BL_esclavo usa Bluetooth clasico (SPP). iOS no soporta SPP generico sin MFi; por eso usamos WiFi HTTP.',
              style: TextStyle(fontSize: 12, color: Color(0xFF6D797D)),
            ),
          ],
        ),
      ),
    );
  }
}
