import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const routeName = '/profile';

  void _showPending(BuildContext context, String label) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label estara disponible pronto.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F4),
      body: Stack(
        children: [
          Positioned(
            top: -80,
            left: -100,
            child: _BlurOrb(
              size: 240,
              color: const Color(0xFF2AB6D1).withValues(alpha: 0.1),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -80,
            child: _BlurOrb(
              size: 280,
              color: const Color(0xFFFC8837).withValues(alpha: 0.08),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.menu, color: Color(0xFF006879)),
                      ),
                      const Expanded(
                        child: Text(
                          'DogCenter',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF006879),
                          ),
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF2AB6D1),
                            width: 1.6,
                          ),
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuApilPEJfEM1xDb4cKP7j7dqPbgJBcmeTqnROfC25TDW5WpDKQzL2-V0y30r2fmOuAefZRsYr9LYKGAO6eNLLatKJb5gdHvDUEkjc8qImVhbKwpsSsV8ZpPjE6MrzFKzEhepydM6wr3jTQ6PocZcmwJSL_HKit3p3D1MS_IBm-QGx6y-0-eBLVgFN3Ll5BkxZF-2XQ4CwNMRthX6a2uU8f_WMjJamSpx1OQ8aCbAyc2pyDf9FzEM-vo7rny-Spiwj6hOgSJz6qjaaia',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                    child: Column(
                      children: [
                        const _ProfileHeader(),
                        const SizedBox(height: 18),
                        const _StatsGrid(),
                        const SizedBox(height: 18),
                        _MenuPanel(
                          onModifyProfile:
                              () => _showPending(context, 'Modificar perfil'),
                          onSettings: () => _showPending(context, 'Ajustes'),
                          onUserData:
                              () => _showPending(context, 'Datos de usuario'),
                          onReport:
                              () => _showPending(context, 'Reportar problema'),
                          onLogout: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/login',
                              (route) => false,
                            );
                          },
                        ),
                        const SizedBox(height: 18),
                        _PremiumBanner(
                          onTap: () => _showPending(context, 'Ayuda premium'),
                        ),
                      ],
                    ),
                  ),
                ),
                const _ProfileBottomNav(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 130,
              height: 130,
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF006879), Color(0xFF2AB6D1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const CircleAvatar(
                backgroundImage: NetworkImage(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBt1RfYjdkjZS4XgK61CfaXc09E7ZoXja8C422qy9FSjqAA6Fd_hzqenzx8xI2iRJiSjCVrw_Xoih9BeFqn6Ks0eb9y92CAhAJjNMGa2_nSRplpk5Ca_bIsYHe9W1nHW7we2yvJXZQKCDhqGe7QfF08KKSdPwnmr6sFP6Yz4aRCu_DmlG-QH6mzAccBjxavLAjJDqxvlOePLgzNSMa91ZRnD-BIckxmf6eaW0bvGZTZdvwg_2DXf_jWoEjUiyFu-XX7tRTrukrfBgGF',
                ),
              ),
            ),
            Positioned(
              right: 2,
              bottom: 2,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFFC8837),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF994700).withValues(alpha: 0.22),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(Icons.edit, size: 18, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Text(
          'Usuario',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Color(0xFF865228),
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Socio desde Enero 2024',
          style: TextStyle(
            color: Color(0xFF3D494C),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _StatCard(
            icon: Icons.pets,
            value: '2',
            label: 'Mascotas',
            bg: Color(0xFFF5F3EE),
            accent: Color(0xFF006879),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.favorite,
            value: '12',
            label: 'Citas',
            bg: Color(0x1A2AB6D1),
            accent: Color(0xFF006879),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.bg,
    required this.accent,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color bg;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: Color(0xFF3D494C),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuPanel extends StatelessWidget {
  const _MenuPanel({
    required this.onModifyProfile,
    required this.onSettings,
    required this.onUserData,
    required this.onReport,
    required this.onLogout,
  });

  final VoidCallback onModifyProfile;
  final VoidCallback onSettings;
  final VoidCallback onUserData;
  final VoidCallback onReport;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B1C19).withValues(alpha: 0.08),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          _MenuItem(
            icon: Icons.person,
            iconBg: const Color(0xFFFFDCC5),
            iconColor: const Color(0xFF6A3B13),
            label: 'Modificar perfil',
            onTap: onModifyProfile,
          ),
          _MenuItem(
            icon: Icons.settings,
            iconBg: const Color(0xFFEAE8E3),
            iconColor: const Color(0xFF865228),
            label: 'Ajustes',
            onTap: onSettings,
          ),
          _MenuItem(
            icon: Icons.badge,
            iconBg: const Color(0xFFEAE8E3),
            iconColor: const Color(0xFF865228),
            label: 'Datos de usuario',
            onTap: onUserData,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: Color(0xFFE4E2DD)),
          ),
          _MenuItem(
            icon: Icons.report,
            iconBg: const Color(0xFFFFDBC8),
            iconColor: const Color(0xFF753400),
            label: 'Reportar problema',
            onTap: onReport,
          ),
          _MenuItem(
            icon: Icons.logout,
            iconBg: const Color(0xFFE4E2DD),
            iconColor: const Color(0xFFBA1A1A),
            label: 'Cerrar sesion',
            danger: true,
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final bool danger;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color:
                      danger
                          ? const Color(0xFFBA1A1A)
                          : const Color(0xFF1B1C19),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: danger ? const Color(0xFFBA1A1A) : const Color(0xFFBCC9CD),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumBanner extends StatelessWidget {
  const _PremiumBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFC8837),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          const Positioned(
            right: -12,
            bottom: -20,
            child: Icon(
              Icons.medical_services,
              size: 86,
              color: Color(0x33FFFFFF),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Necesitas ayuda premium?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Consulta con expertos 24/7',
                style: TextStyle(
                  color: Color(0xE6FFFFFF),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF994700),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: const Text(
                  'Saber mas',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileBottomNav extends StatelessWidget {
  const _ProfileBottomNav();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withValues(alpha: 0.86),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B1C19).withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _NavItem(icon: Icons.home, label: 'Home'),
          _NavItem(icon: Icons.pets, label: 'Pets'),
          _NavItem(icon: Icons.health_and_safety, label: 'Health'),
          _NavItem(icon: Icons.person, label: 'Profile', active: true),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    if (active) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: const LinearGradient(
            colors: [Color(0xFF2AB6D1), Color(0xFF006879)],
          ),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person, color: Colors.white),
            SizedBox(height: 2),
            Text(
              'Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    return Opacity(
      opacity: 0.7,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF865228)),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF865228),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BlurOrb extends StatelessWidget {
  const _BlurOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: 90, spreadRadius: 16)],
      ),
    );
  }
}
