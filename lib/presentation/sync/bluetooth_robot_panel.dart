import 'dart:async';
import 'dart:math' as math;

import 'package:dog_center/presentation/sync/services/robot_bluetooth_client.dart';
import 'package:flutter/material.dart';

class BluetoothRobotPanel extends StatefulWidget {
  const BluetoothRobotPanel({super.key});

  @override
  State<BluetoothRobotPanel> createState() => _BluetoothRobotPanelState();
}

class _BluetoothRobotPanelState extends State<BluetoothRobotPanel> {
  final _client = RobotBluetoothClient();

  StreamSubscription<List<RobotScanDevice>>? _devicesSubscription;
  StreamSubscription<bool>? _scanSubscription;
  StreamSubscription<RobotConnectionState>? _connectionSubscription;
  StreamSubscription<String>? _messageSubscription;
  Timer? _driveTimer;

  List<RobotScanDevice> _devices = const [];
  String? _selectedDeviceId;
  String? _lastMessage;
  bool _isScanning = false;
  bool _isConnected = false;
  bool _isBusy = false;
  double _x = 0;
  double _y = 0;

  @override
  void initState() {
    super.initState();
    _devicesSubscription = _client.scanResults.listen((devices) {
      if (mounted) setState(() => _devices = devices);
    });
    _scanSubscription = _client.isScanning.listen((isScanning) {
      if (mounted) setState(() => _isScanning = isScanning);
    });
    _connectionSubscription = _client.connectionState.listen((state) {
      if (!mounted) return;
      setState(() {
        _isConnected = state == RobotConnectionState.connected;
        if (!_isConnected) {
          _x = 0;
          _y = 0;
        }
      });
    });
    _messageSubscription = _client.messages.listen((message) {
      if (mounted) setState(() => _lastMessage = message);
    });
  }

  @override
  void dispose() {
    _driveTimer?.cancel();
    unawaited(_devicesSubscription?.cancel());
    unawaited(_scanSubscription?.cancel());
    unawaited(_connectionSubscription?.cancel());
    unawaited(_messageSubscription?.cancel());
    unawaited(_client.dispose());
    super.dispose();
  }

  Future<void> _scan() async {
    if (_isScanning) {
      await _client.stopScan();
      return;
    }

    setState(() {
      _devices = const [];
      _isBusy = true;
    });
    try {
      await _client.startScan();
    } catch (error) {
      _showError('No se pudo buscar el ESP32: ' + error.toString());
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _connect(RobotScanDevice robot) async {
    if (!robot.connectable) {
      _showError('El dispositivo no admite conexión Bluetooth Serial/SPP.');
      return;
    }

    setState(() {
      _isBusy = true;
      _selectedDeviceId = robot.id;
    });
    try {
      await _client.connect(robot);
      if (mounted) {
        setState(() => _isConnected = true);
        _showMessage('Conectado con ' + robot.name);
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _selectedDeviceId = null;
          _isConnected = false;
        });
      }
      _showError('No se pudo conectar: ' + error.toString());
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _disconnect() async {
    setState(() => _isBusy = true);
    try {
      await _stopMovement();
      await _client.disconnect();
      if (mounted) {
        setState(() {
          _selectedDeviceId = null;
          _isConnected = false;
        });
      }
    } catch (error) {
      _showError('No se pudo desconectar: ' + error.toString());
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _updateJoystick(Offset position, double size) {
    final center = size / 2;
    var x = ((position.dx - center) / center) * 100;
    var y = ((center - position.dy) / center) * 100;
    final magnitude = math.sqrt((x * x) + (y * y));
    if (magnitude > 100) {
      x = x * 100 / magnitude;
      y = y * 100 / magnitude;
    }
    if (x.abs() < 8) x = 0;
    if (y.abs() < 8) y = 0;

    setState(() {
      _x = x;
      _y = y;
    });
    if (_driveTimer?.isActive != true) {
      _driveTimer = Timer(const Duration(milliseconds: 70), _sendMovement);
    }
  }

  Future<void> _sendMovement() async {
    if (!_isConnected) return;

    final x = _x.round().clamp(-100, 100).toInt();
    final y = _y.round().clamp(-100, 100).toInt();

    try {
      if (x == 0 && y == 0) {
        await _client.stop();
      } else {
        await _client.move(x: x, y: y);
      }
    } catch (error) {
      _showError('Error enviando movimiento: ' + error.toString());
    }
  }

  Future<void> _stopMovement() async {
    _driveTimer?.cancel();
    if (mounted) {
      setState(() {
        _x = 0;
        _y = 0;
      });
    }
    if (_isConnected) await _client.stop();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isConnected ? Icons.bluetooth_connected : Icons.bluetooth,
                  color: _isConnected ? Colors.green : const Color(0xFF006879),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isConnected
                        ? 'ESP32 conectado'
                        : 'Control ESP32 por Bluetooth clásico',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                if (_isBusy || _isScanning)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            if (!_isConnected) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isBusy ? null : _scan,
                  icon: Icon(_isScanning ? Icons.stop : Icons.search),
                  label: Text(
                    _isScanning ? 'Detener busqueda' : 'Buscar ESP32',
                  ),
                ),
              ),
              if (_devices.isEmpty && !_isScanning)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    'Se muestran primero los dispositivos Bluetooth clásicos emparejados. Orion (00:4B:12:3E:21:5A) tendrá prioridad; si aún no aparece, emparéjalo primero desde Ajustes de Android.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6D797D)),
                  ),
                ),
              if (_devices.isNotEmpty)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 240),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _devices.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final robot = _devices[index];
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(robot.name),
                        subtitle: Text(
                          'RSSI ' + robot.rssi.toString() + ' · ' + robot.id,
                        ),
                        trailing: FilledButton(
                          onPressed: _isBusy ? null : () => _connect(robot),
                          child: Text(
                            _isBusy && _selectedDeviceId == robot.id
                                ? 'Conectando...'
                                : 'Conectar',
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ] else ...[
              Center(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart:
                      (details) => _updateJoystick(details.localPosition, 220),
                  onPanUpdate:
                      (details) => _updateJoystick(details.localPosition, 220),
                  onPanEnd: (_) => _stopMovement(),
                  onPanCancel: _stopMovement,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE7F4F6),
                      border: Border.all(
                        color: const Color(0xFF006879),
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.add,
                          size: 150,
                          color: Color(0x33006879),
                        ),
                        Transform.translate(
                          offset: Offset(_x * 0.75, -_y * 0.75),
                          child: const DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF006879),
                            ),
                            child: SizedBox(width: 48, height: 48),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'X: ' +
                      _x.round().toString() +
                      '   Y: ' +
                      _y.round().toString(),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _stopMovement,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      icon: const Icon(Icons.stop),
                      label: const Text('DETENER'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: _isBusy ? null : _disconnect,
                    child: const Text('Desconectar'),
                  ),
                ],
              ),
              if (_lastMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  'ESP32: ' + _lastMessage!,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
