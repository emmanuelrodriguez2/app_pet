import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VisionScreen extends StatefulWidget {
  const VisionScreen({super.key});

  static const routeName = '/vision';

  @override
  State<VisionScreen> createState() => _VisionScreenState();
}

class _VisionScreenState extends State<VisionScreen> {
  VideoPlayerController? _videoController;
  bool _isOpeningCamera = false;

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _openCamera() async {
    if (_isOpeningCamera) return;

    final currentController = _videoController;
    if (currentController != null) {
      await currentController.play();
      return;
    }

    setState(() => _isOpeningCamera = true);

    final controller = VideoPlayerController.asset('assets/video/video1.mp4');

    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0);
      await controller.play();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _videoController = controller;
        _isOpeningCamera = false;
      });
    } catch (_) {
      await controller.dispose();

      if (!mounted) return;

      setState(() => _isOpeningCamera = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir la camara')),
      );
    }
  }

  Future<void> _closeCamera() async {
    final controller = _videoController;

    setState(() => _videoController = null);

    await controller?.pause();
    await controller?.dispose();
  }

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
            _CameraPreview(
              controller: _videoController,
              isOpeningCamera: _isOpeningCamera,
              onClose: _closeCamera,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.mic),
                    label: const Text('Hablar por microfono'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isOpeningCamera ? null : _openCamera,
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

class _CameraPreview extends StatelessWidget {
  const _CameraPreview({
    required this.controller,
    required this.isOpeningCamera,
    required this.onClose,
  });

  final VideoPlayerController? controller;
  final bool isOpeningCamera;
  final VoidCallback onClose;

  bool get _isLive => controller?.value.isInitialized ?? false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 240,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _isLive ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFBCC9CD).withValues(alpha: 0.35),
        ),
      ),
      child:
          _isLive
              ? _LiveCameraFeed(controller: controller!, onClose: onClose)
              : _CameraPlaceholder(isOpeningCamera: isOpeningCamera),
    );
  }
}

class _LiveCameraFeed extends StatelessWidget {
  const _LiveCameraFeed({required this.controller, required this.onClose});

  final VideoPlayerController controller;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final aspectRatio =
        controller.value.aspectRatio == 0
            ? 16 / 9
            : controller.value.aspectRatio;

    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: VideoPlayer(controller),
          ),
        ),
        const Positioned(top: 12, left: 12, child: _LiveBadge()),
        Positioned(
          top: 8,
          right: 8,
          child: Material(
            color: Colors.black54,
            shape: const CircleBorder(),
            child: IconButton(
              onPressed: onClose,
              tooltip: 'Cerrar transmision',
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFD71920),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'EN VIVO',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _CameraPlaceholder extends StatelessWidget {
  const _CameraPlaceholder({required this.isOpeningCamera});

  final bool isOpeningCamera;

  @override
  Widget build(BuildContext context) {
    if (isOpeningCamera) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF006879)),
          SizedBox(height: 12),
          Text(
            'Abriendo camara...',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      );
    }

    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.photo_camera, size: 54, color: Color(0xFF006879)),
        SizedBox(height: 10),
        Text(
          'Previsualizacion de camara',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
