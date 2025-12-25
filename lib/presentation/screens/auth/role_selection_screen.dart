import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:shared_preferences/shared_preferences.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  // Staggered animations for each element
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _subtitleFade;
  late Animation<Offset> _subtitleSlide;
  late Animation<double> _labelFade;
  late Animation<double> _ownerCardFade;
  late Animation<Offset> _ownerCardSlide;
  late Animation<double> _tenantCardFade;
  late Animation<Offset> _tenantCardSlide;
  late Animation<double> _footerFade;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Define staggered intervals for each element
    // Header: 0.0 - 0.3
    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.3, curve: Curves.easeOut)),
    );
    _headerSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.35, curve: Curves.easeOutCubic)),
    );

    // Subtitle: 0.1 - 0.4
    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.1, 0.4, curve: Curves.easeOut)),
    );
    _subtitleSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.1, 0.45, curve: Curves.easeOutCubic)),
    );

    // 'Continue as' label: 0.25 - 0.5
    _labelFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.25, 0.5, curve: Curves.easeOut)),
    );

    // Owner Card: 0.35 - 0.7
    _ownerCardFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.35, 0.7, curve: Curves.easeOut)),
    );
    _ownerCardSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.35, 0.75, curve: Curves.easeOutCubic)),
    );

    // Tenant Card: 0.5 - 0.85
    _tenantCardFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 0.85, curve: Curves.easeOut)),
    );
    _tenantCardSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 0.9, curve: Curves.easeOutCubic)),
    );

    // Footer: 0.7 - 1.0
    _footerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.7, 1.0, curve: Curves.easeOut)),
    );

    // Start the animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : Colors.white,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 64),
                          // Header Section (Animated)
                          FadeTransition(
                            opacity: _headerFade,
                            child: SlideTransition(
                              position: _headerSlide,
                              child: RichText(
                                text: TextSpan(
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 42,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    height: 1.1,
                                    letterSpacing: -1,
                                  ),
                                  children: [
                                    const TextSpan(text: 'Welcome to\n'),
                                    TextSpan(
                                      text: 'KirayaBook',
                                      style: GoogleFonts.playfairDisplay(
                                        color: isDark ? Colors.white : const Color(0xFF2563EB),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Subtitle (Animated)
                          FadeTransition(
                            opacity: _subtitleFade,
                            child: SlideTransition(
                              position: _subtitleSlide,
                              child: Text(
                                'Elevating your estate management experience.',
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  color: isDark ? Colors.white54 : const Color(0xFF64748B),
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 48),
                          
                          // 'Continue as' label (Animated)
                          FadeTransition(
                            opacity: _labelFade,
                            child: Text(
                              'Continue as',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white24 : Colors.grey.withValues(alpha: 0.5),
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Owner Card (Animated)
                          FadeTransition(
                            opacity: _ownerCardFade,
                            child: SlideTransition(
                              position: _ownerCardSlide,
                              child: _buildAuraRoleCard(
                                context,
                                title: 'Property Owner',
                                subtitle: 'Manage units, leases & finances',
                                color: const Color(0xFF2563EB),
                                icon: Icons.admin_panel_settings_rounded,
                                role: 'owner',
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Tenant Card (Animated)
                          FadeTransition(
                            opacity: _tenantCardFade,
                            child: SlideTransition(
                              position: _tenantCardSlide,
                              child: _buildAuraRoleCard(
                                context,
                                title: 'Resident Tenant',
                                subtitle: 'Pay rent & track requests',
                                color: const Color(0xFF10B981),
                                icon: Icons.person_rounded,
                                role: 'tenant',
                              ),
                            ),
                          ),
                          
                          const Spacer(),
                          const SizedBox(height: 40),
                          
                          // Footer (Animated)
                          FadeTransition(
                            opacity: _footerFade,
                            child: Center(
                              child: Column(
                                children: [
                                  Text(
                                    'Designed for Excellence',
                                    style: GoogleFonts.outfit(
                                      color: isDark ? Colors.white24 : Colors.grey.withValues(alpha: 0.3),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Icon(Icons.favorite_rounded, color: Colors.red, size: 14),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
          );
        },
      ),
    );
  }

  Widget _buildAuraRoleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required String role,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () async {
        // Save persist preference
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_role', role);
        
        if (context.mounted) {
          context.push('/login', extra: role);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: isDark ? Colors.white54 : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white24 : Colors.grey.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }
}
