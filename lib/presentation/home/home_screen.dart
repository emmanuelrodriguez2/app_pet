import 'dart:ui';

import 'package:dog_center/presentation/nutrition/nutrition_screen.dart';
import 'package:dog_center/presentation/profile/profile_screen.dart';
import 'package:dog_center/presentation/sync/sync_screen.dart';
import 'package:dog_center/presentation/vision/vision_screen.dart';
import 'package:flutter/material.dart';

enum HomeAction { home, vision, nutrition, sync, profile, quickDispense }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedBottomIndex = 0;

  static const _background = Color(0xFFFBF9F4);

  void _handleAction(HomeAction action) {
    if (!mounted) return;
    switch (action) {
      case HomeAction.home:
        break;
      case HomeAction.vision:
        Navigator.pushNamed(context, VisionScreen.routeName);
        break;
      case HomeAction.nutrition:
        Navigator.pushNamed(context, NutritionScreen.routeName);
        break;
      case HomeAction.sync:
        Navigator.pushNamed(context, SyncScreen.routeName);
        break;
      case HomeAction.profile:
        Navigator.pushNamed(context, ProfileScreen.routeName);
        break;
      case HomeAction.quickDispense:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const SyncScreen(runQuickDispense: true),
          ),
        );
        break;
    }
  }

  void _onBottomTap(int index) {
    setState(() => selectedBottomIndex = index);
    final actions = [
      HomeAction.home,
      HomeAction.vision,
      HomeAction.nutrition,
      HomeAction.sync,
    ];
    _handleAction(actions[index]);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;
    final isTablet = width >= 768;

    return Scaffold(
      backgroundColor: _background,
      body: Stack(
        children: [
          Positioned(
            right: -80,
            bottom: -80,
            child: IgnorePointer(
              child: Icon(
                Icons.pets,
                size: 300,
                color: const Color(0xFF1B1C19).withValues(alpha: 0.04),
              ),
            ),
          ),
          Column(
            children: [
              _TopBar(
                isTablet: isTablet,
                onTapHome: () => _handleAction(HomeAction.home),
                onTapVision: () => _handleAction(HomeAction.vision),
                onTapNutrition: () => _handleAction(HomeAction.nutrition),
                onTapSync: () => _handleAction(HomeAction.sync),
                onTapProfile: () => _handleAction(HomeAction.profile),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(24, 28, 24, isTablet ? 24 : 120),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _HeroSection(isDesktop: isDesktop),
                          const SizedBox(height: 18),
                          _FeatureGrid(
                            isDesktop: isDesktop,
                            isTablet: isTablet,
                            onOpenVision:
                                () => _handleAction(HomeAction.vision),
                            onOpenNutrition:
                                () => _handleAction(HomeAction.nutrition),
                            onOpenSync: () => _handleAction(HomeAction.sync),
                          ),
                          const SizedBox(height: 12),
                          _QuickArduinoAction(
                            onQuickDispense:
                                () => _handleAction(HomeAction.quickDispense),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar:
          isTablet
              ? null
              : _BottomNav(
                onTap: _onBottomTap,
                selectedIndex: selectedBottomIndex,
              ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.isTablet,
    required this.onTapHome,
    required this.onTapVision,
    required this.onTapNutrition,
    required this.onTapSync,
    required this.onTapProfile,
  });

  final bool isTablet;
  final VoidCallback onTapHome;
  final VoidCallback onTapVision;
  final VoidCallback onTapNutrition;
  final VoidCallback onTapSync;
  final VoidCallback onTapProfile;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: const Color(0xFFF0EEE9).withValues(alpha: 0.92),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                const Icon(Icons.pets, color: Color(0xFF2AB6D1), size: 28),
                const SizedBox(width: 8),
                const Text(
                  'DogCenter',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF865228),
                    letterSpacing: -0.2,
                  ),
                ),
                const Spacer(),
                if (isTablet) ...[
                  _TopLink(label: 'Home', selected: true, onTap: onTapHome),
                  _TopLink(
                    label: 'Vision',
                    selected: false,
                    onTap: onTapVision,
                  ),
                  _TopLink(
                    label: 'Nutrition',
                    selected: false,
                    onTap: onTapNutrition,
                  ),
                  _TopLink(label: 'Sync', selected: false, onTap: onTapSync),
                  const SizedBox(width: 8),
                ],
                GestureDetector(
                  onTap: onTapProfile,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF2AB6D1),
                        width: 1.8,
                      ),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuAUZOpxUjjAN-11dEvwEo7l3Fm0JAUThYD9kx3FmVpptyoPAV3FJnKLeXgEI3YSMzlgI4eHXHLkfr_RyBZohik-eNLYQS7Yqtjh01I_n8ieGrshLks0TsPtnupP5lc1_hpy_zP3m_Ji5C8kzrGww8nrxjhIvABkLjzdYM56QjMDV0aM5egeYfmHNJkqD9GyiMXVxLRjseWO9MR3G7a3S8yiplj9hLtZxPRXJtBDUdEMuU-2ryupwin-GBZdjFN4f-bHXQ5Dwr1dqH28',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopLink extends StatelessWidget {
  const _TopLink({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: selected ? const Color(0xFF2AB6D1) : const Color(0xFF865228),
          ),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.isDesktop});

  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            child: _BlurCircle(
              size: isDesktop ? 200 : 150,
              color: const Color(0xFF2AB6D1).withValues(alpha: 0.28),
              blur: 80,
            ),
          ),
          Positioned(
            right: 50,
            top: 55,
            child: _BlurCircle(
              size: isDesktop ? 110 : 80,
              color: const Color(0xFFFC8837).withValues(alpha: 0.25),
              blur: 60,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: isDesktop ? 560 : 500,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Hola, Usuario.',
                    style: TextStyle(
                      fontSize: 48,
                      height: 1.1,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1B1C19),
                      letterSpacing: -1,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Aqui tienes el panel de tu mascota.',
                    style: TextStyle(
                      fontSize: 22,
                      color: Color(0xFF865228),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlurCircle extends StatelessWidget {
  const _BlurCircle({
    required this.size,
    required this.color,
    required this.blur,
  });

  final double size;
  final Color color;
  final double blur;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: blur, spreadRadius: 4)],
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid({
    required this.isDesktop,
    required this.isTablet,
    required this.onOpenVision,
    required this.onOpenNutrition,
    required this.onOpenSync,
  });

  final bool isDesktop;
  final bool isTablet;
  final VoidCallback onOpenVision;
  final VoidCallback onOpenNutrition;
  final VoidCallback onOpenSync;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardSpacing = 18.0;

        if (!isTablet) {
          return Column(
            children: [
              _HealthCard(onTap: onOpenVision),
              const SizedBox(height: 18),
              _FoodCard(onTap: onOpenNutrition),
              const SizedBox(height: 18),
              _SyncCard(onTap: onOpenSync),
            ],
          );
        }

        if (isDesktop) {
          final cardWidth = (constraints.maxWidth - (2 * cardSpacing)) / 3;
          return Wrap(
            spacing: cardSpacing,
            runSpacing: cardSpacing,
            children: [
              SizedBox(
                width: cardWidth,
                child: _HealthCard(onTap: onOpenVision),
              ),
              SizedBox(
                width: cardWidth,
                child: _FoodCard(onTap: onOpenNutrition),
              ),
              SizedBox(width: cardWidth, child: _SyncCard(onTap: onOpenSync)),
            ],
          );
        }

        final cardWidth = (constraints.maxWidth - cardSpacing) / 2;
        return Wrap(
          spacing: cardSpacing,
          runSpacing: cardSpacing,
          children: [
            SizedBox(width: cardWidth, child: _HealthCard(onTap: onOpenVision)),
            SizedBox(
              width: cardWidth,
              child: _FoodCard(onTap: onOpenNutrition),
            ),
            SizedBox(
              width: constraints.maxWidth,
              child: _SyncCard(onTap: onOpenSync),
            ),
          ],
        );
      },
    );
  }
}

class _QuickArduinoAction extends StatelessWidget {
  const _QuickArduinoAction({required this.onQuickDispense});

  final VoidCallback onQuickDispense;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFDBC8).withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFDB885), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFFFC8837),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.restaurant, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Accion Rapida Arduino',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF652C00),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Dispensa una porcion ahora mismo.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF78461D),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onQuickDispense,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF994700),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: const Text(
              'Dispensar',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCardShell extends StatelessWidget {
  const _FeatureCardShell({
    required this.child,
    required this.gradient,
    required this.onTap,
  });

  final Widget child;
  final Gradient? gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: gradient == null ? const Color(0xFFFFFFFF) : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(24),
          border:
              gradient == null
                  ? Border.all(
                    color: const Color(0xFFBCC9CD).withValues(alpha: 0.3),
                  )
                  : null,
          boxShadow: [
            BoxShadow(
              color: const Color(
                0xFF1B1C19,
              ).withValues(alpha: gradient == null ? 0.08 : 0.12),
              blurRadius: 34,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class _HealthCard extends StatelessWidget {
  const _HealthCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _FeatureCardShell(
      onTap: onTap,
      gradient: null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _IconCircle(
            icon: Icons.photo_camera,
            iconColor: Color(0xFF006879),
            bgColor: Color(0xFFF5F3EE),
          ),
          const SizedBox(height: 20),
          const Text(
            'Camara de Salud',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w800,
              color: Color(0xFF865228),
              height: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Analiza las porciones de comida y el comportamiento alimenticio de tu mascota mediante vision artificial.',
            style: TextStyle(
              fontSize: 14.5,
              height: 1.4,
              color: Color(0xFF3D494C),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(height: 1, color: Color(0xFFF0EEE9)),
          const SizedBox(height: 16),
          const _CardFooter(
            label: 'Abrir camara',
            labelColor: Color(0xFF006879),
            icon: Icons.arrow_forward,
            iconBg: Color(0xFF2AB6D1),
            iconColor: Colors.white,
          ),
        ],
      ),
    );
  }
}

class _FoodCard extends StatelessWidget {
  const _FoodCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _FeatureCardShell(
      onTap: onTap,
      gradient: null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _IconCircle(
            icon: Icons.calculate,
            iconColor: Color(0xFF994700),
            bgColor: Color(0xFFFDB885),
          ),
          const SizedBox(height: 20),
          const Text(
            'Calculadora de Alimento',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w800,
              color: Color(0xFF865228),
              height: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Optimiza la nutricion diaria basada en la raza, peso y nivel de actividad especifica de tu companero.',
            style: TextStyle(
              fontSize: 14.5,
              height: 1.4,
              color: Color(0xFF3D494C),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(height: 1, color: Color(0xFFF0EEE9)),
          const SizedBox(height: 16),
          const _CardFooter(
            label: 'Calcular ahora',
            labelColor: Color(0xFF994700),
            icon: Icons.arrow_forward,
            iconBg: Color(0xFFFC8837),
            iconColor: Colors.white,
          ),
        ],
      ),
    );
  }
}

class _SyncCard extends StatelessWidget {
  const _SyncCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _FeatureCardShell(
      onTap: onTap,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF006879), Color(0xFF2AB6D1)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _IconCircle(
            icon: Icons.sync,
            iconColor: Colors.white,
            bgColor: Colors.white24,
          ),
          SizedBox(height: 20),
          Text(
            'Sincronizacion Arduino',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Gestiona la conexion con el dispensador inteligente y programa los horarios de alimentacion.',
            style: TextStyle(
              fontSize: 14.5,
              height: 1.4,
              color: Color(0xFFAAEDFF),
            ),
          ),
          SizedBox(height: 24),
          Divider(height: 1, color: Colors.white24),
          SizedBox(height: 16),
          _CardFooter(
            label: 'Conectar dispositivo',
            labelColor: Colors.white,
            icon: Icons.settings,
            iconBg: Colors.white,
            iconColor: Color(0xFF006879),
          ),
        ],
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  const _IconCircle({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });

  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Icon(icon, color: iconColor, size: 28),
    );
  }
}

class _CardFooter extends StatelessWidget {
  const _CardFooter({
    required this.label,
    required this.labelColor,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });

  final String label;
  final Color labelColor;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(shape: BoxShape.circle, color: iconBg),
          child: Icon(icon, color: iconColor, size: 18),
        ),
      ],
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.onTap, required this.selectedIndex});

  final void Function(int) onTap;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 92,
          decoration: BoxDecoration(
            color: const Color(0xFFFBF9F4).withValues(alpha: 0.86),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1B1C19).withValues(alpha: 0.06),
                blurRadius: 30,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _BottomItem(
                  icon: Icons.home,
                  label: 'Home',
                  active: selectedIndex == 0,
                  onTap: () => onTap(0),
                ),
                _BottomItem(
                  icon: Icons.visibility,
                  label: 'Vision',
                  active: selectedIndex == 1,
                  onTap: () => onTap(1),
                ),
                _BottomItem(
                  icon: Icons.restaurant,
                  label: 'Nutrition',
                  active: selectedIndex == 2,
                  onTap: () => onTap(2),
                ),
                _BottomItem(
                  icon: Icons.sync,
                  label: 'Sync',
                  active: selectedIndex == 3,
                  onTap: () => onTap(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  const _BottomItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = active ? Colors.white : const Color(0xFF865228);
    final bg = active ? const Color(0xFF2AB6D1) : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: fg, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
