import 'package:flutter/material.dart';
import 'package:health_asistants/core/utils/constants/colors.dart';
import 'package:health_asistants/core/utils/constants/spacing.dart';
import 'dart:math' as math;

class FabMenuItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const FabMenuItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class CustomFabMenu extends StatefulWidget {
  final List<FabMenuItem> items;

  const CustomFabMenu({super.key, required this.items});

  @override
  State<CustomFabMenu> createState() => _CustomFabMenuState();
}

class _CustomFabMenuState extends State<CustomFabMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotateAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: _isOpen ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    // Açılma (genişleme) animasyonu
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      parent: _controller,
    );

    // İkon dönme animasyonu (Çarpı olması için)
    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(curve: Curves.easeInOut, parent: _controller));
  }

  void _toggleMenu() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          _buildTapToCloseFab(),

          // --- MENÜ BUTONLARI ---
          ...widget.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final itemCount = widget.items.length;

            // Açıları eşit dağıt (180-270 arası = sol üst kadran)
            final startAngle = 180.0;
            final endAngle = 270.0;
            final angleStep = itemCount > 1
                ? (endAngle - startAngle) / (itemCount - 1)
                : 0.0;
            final angle = itemCount > 1
                ? startAngle + (angleStep * index)
                : 225.0;

            return _buildActionButton(
              title: item.title,
              icon: item.icon,
              color: item.color,
              angle: angle,
              distance: 80,
              onTap: item.onTap,
            );
          }),

          // --- ANA FAB BUTONU ---
          _buildTapToOpenFab(),
        ],
      ),
    );
  }

  Widget _buildTapToCloseFab() {
    return SizedBox(
      width: 56,
      height: 56,
      child: Center(
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4,
          child: InkWell(
            onTap: _toggleMenu,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(Icons.close, color: Theme.of(context).primaryColor),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTapToOpenFab() {
    return Transform.rotate(
      angle: _rotateAnimation.value * math.pi,
      child: FloatingActionButton(
        onPressed: _toggleMenu,
        backgroundColor: _isOpen
            ? AppColors.emergencyRed
            : AppColors.primaryBlue,
        shape: const CircleBorder(),
        child: Icon(
          _isOpen ? Icons.close : Icons.grid_view_rounded,
          color: AppColors.white,
          size: AppSpacing.iconLg,
        ),
      ),
    );
  }

  // Animasyonlu küçük butonları oluşturan yardımcı metot
  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required double
    angle, // Derece cinsinden açı (0 = sağ, 90 = aşağı, 180 = sol, 270 = yukarı)
    required double distance,
    required VoidCallback onTap,
  }) {
    final double rad = angle * (math.pi / 180.0);
    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        final double progress = _expandAnimation.value;
        final double offset = distance * progress;
        return Transform.translate(
          offset: Offset.fromDirection(rad, offset),
          child: Transform.scale(
            scale: progress, // Açılırken büyüsün
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          _toggleMenu(); // Tıklanınca menüyü kapat
          onTap();
        },
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}
