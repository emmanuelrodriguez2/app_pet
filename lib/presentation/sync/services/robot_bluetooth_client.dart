import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:bluetooth_classic/models/device.dart';
import 'package:flutter/foundation.dart';

enum RobotConnectionState { disconnected, connecting, connected }

class RobotScanDevice {
  const RobotScanDevice({required this.device, required this.isPaired});

  final Device device;
  final bool isPaired;

  String get id => device.address.toUpperCase();
  String get name =>
      id == RobotBluetoothClient.orionAddress
          ? 'Orion'
          : (device.name?.trim().isNotEmpty == true
              ? device.name!.trim()
              : 'Robot sin nombre');
  int get rssi => 0;
  bool get connectable => true;
}

class RobotDriveConfig {
  const RobotDriveConfig({
    required this.maxSpeed,
    required this.acceleration,
    required this.rotationSpeed,
    required this.balanceFactor,
  });

  final int maxSpeed;
  final int acceleration;
  final double rotationSpeed;
  final double balanceFactor;

  RobotDriveConfig copyWith({
    int? maxSpeed,
    int? acceleration,
    double? rotationSpeed,
    double? balanceFactor,
  }) => RobotDriveConfig(
    maxSpeed: maxSpeed ?? this.maxSpeed,
    acceleration: acceleration ?? this.acceleration,
    rotationSpeed: rotationSpeed ?? this.rotationSpeed,
    balanceFactor: balanceFactor ?? this.balanceFactor,
  );
}

class RobotBluetoothClient {
  RobotBluetoothClient() {
    _discoverySubscription = _bluetooth.onDeviceDiscovered().listen(
      (device) => _addDevice(device, isPaired: false),
    );
    _statusSubscription = _bluetooth.onDeviceStatusChanged().listen((status) {
      _connected = status == Device.connected;
      _connectionStateController.add(
        _connected
            ? RobotConnectionState.connected
            : RobotConnectionState.disconnected,
      );
    });
    _inputSubscription = _bluetooth.onDeviceDataReceived().listen((bytes) {
      final message = utf8.decode(bytes, allowMalformed: true).trim();
      if (message.isNotEmpty) _messageController.add(message);
    });
  }

  static const orionAddress = '00:4B:12:3E:21:5A';
  static const sppUuid = '00001101-0000-1000-8000-00805f9b34fb';

  final BluetoothClassic _bluetooth = BluetoothClassic();
  final _devicesController =
      StreamController<List<RobotScanDevice>>.broadcast();
  final _isScanningController = StreamController<bool>.broadcast();
  final _connectionStateController =
      StreamController<RobotConnectionState>.broadcast();
  final _messageController = StreamController<String>.broadcast();
  final Map<String, RobotScanDevice> _devices = {};

  StreamSubscription<Device>? _discoverySubscription;
  StreamSubscription<int>? _statusSubscription;
  StreamSubscription<Uint8List>? _inputSubscription;
  bool _connected = false;

  Stream<List<RobotScanDevice>> get scanResults => _devicesController.stream;
  Stream<bool> get isScanning => _isScanningController.stream;
  Stream<RobotConnectionState> get connectionState =>
      _connectionStateController.stream;
  Stream<String> get messages => _messageController.stream;
  bool get isConnected => _connected;

  Future<void> prepare() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      throw UnsupportedError(
        'Bluetooth Serial/SPP de Orion solo esta disponible en Android.',
      );
    }
    await _bluetooth.initPermissions();
  }

  Future<void> startScan() async {
    await prepare();
    _devices.clear();
    final paired = await _bluetooth.getPairedDevices();
    for (final device in paired) {
      _addDevice(device, isPaired: true);
    }
    _isScanningController.add(true);
    await _bluetooth.startScan();
  }

  Future<void> stopScan() async {
    try {
      await _bluetooth.stopScan();
    } finally {
      _isScanningController.add(false);
    }
  }

  void _addDevice(Device device, {required bool isPaired}) {
    final id = device.address.toUpperCase();
    final previous = _devices[id];
    _devices[id] = RobotScanDevice(
      device: device,
      isPaired: isPaired || (previous?.isPaired ?? false),
    );
    final sorted =
        _devices.values.toList()..sort((a, b) {
          if (a.id == orionAddress) return -1;
          if (b.id == orionAddress) return 1;
          if (a.isPaired != b.isPaired) return a.isPaired ? -1 : 1;
          return b.rssi.compareTo(a.rssi);
        });
    _devicesController.add(sorted);
  }

  Future<void> connect(RobotScanDevice robot) async {
    await prepare();
    await stopScan();
    await disconnect();
    _connectionStateController.add(RobotConnectionState.connecting);
    try {
      await _bluetooth.connect(robot.id, sppUuid);
      _connected = true;
      _connectionStateController.add(RobotConnectionState.connected);
      await _sendDrivePacket(0, 0);
    } catch (_) {
      _connected = false;
      _connectionStateController.add(RobotConnectionState.disconnected);
      rethrow;
    }
  }

  Future<void> disconnect() async {
    if (_connected) {
      await _bluetooth.disconnect();
    }
    _connected = false;
    _connectionStateController.add(RobotConnectionState.disconnected);
  }

  int _red = 0;
  int _green = 255;
  int _blue = 255;

  Future<void> move({required int x, required int y}) async {
    final forward = y.clamp(-100, 100).toInt();
    final turn = x.clamp(-100, 100).toInt();
    final leftMotor = (forward + turn).clamp(-100, 100).toInt();
    final rightMotor = (forward - turn).clamp(-100, 100).toInt();
    await _sendDrivePacket(leftMotor, rightMotor);
  }

  Future<void> stop() async {
    if (_connected) await _sendDrivePacket(0, 0);
  }

  Future<void> setLedColor({
    required int red,
    required int green,
    required int blue,
  }) async {
    _red = red.clamp(0, 255).toInt();
    _green = green.clamp(0, 255).toInt();
    _blue = blue.clamp(0, 255).toInt();
    if (_connected) await _sendDrivePacket(0, 0);
  }

  Future<void> sendConfig(RobotDriveConfig config) async {}

  Future<void> _sendDrivePacket(int leftMotor, int rightMotor) =>
      _write('$leftMotor,$rightMotor,$_red,$_green,$_blue\n');

  Future<void> _write(String command) async {
    if (!_connected) throw Exception('Conecta Orion primero.');
    debugPrint('Bluetooth TX: ${command.trim()}');
    await _bluetooth.write(command);
  }

  Future<void> dispose() async {
    await stopScan();
    await disconnect();
    await _discoverySubscription?.cancel();
    await _statusSubscription?.cancel();
    await _inputSubscription?.cancel();
    await _devicesController.close();
    await _isScanningController.close();
    await _connectionStateController.close();
    await _messageController.close();
  }
}
