import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  @override
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : Colors.white,
      body: LayoutBuilder(
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
                      // Header Section
                      RichText(
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
                      const SizedBox(height: 16),
                      Text(
                         'Elevating your estate management experience.',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          color: isDark ? Colors.white54 : const Color(0xFF64748B),
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 48),
                      
                      Text(
                        'Continue as',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white24 : Colors.grey.withValues(alpha: 0.5),
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Aura Cards Section
                      _buildAuraRoleCard(
                        context,
                        title: 'Property Owner',
                        subtitle: 'Manage units, leases & finances',
                        color: const Color(0xFF2563EB),
                        icon: Icons.admin_panel_settings_rounded,
                        role: 'owner',
                      ),
                      const SizedBox(height: 16),
                      _buildAuraRoleCard(
                        context,
                        title: 'Resident Tenant',
                        subtitle: 'Pay rent & track requests',
                        color: const Color(0xFF10B981),
                        icon: Icons.person_rounded,
                        role: 'tenant',
                      ),
                      
                      const Spacer(),
                      const SizedBox(height: 40),
                      
                      Center(
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
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
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
      onTap: () => context.push('/login', extra: role),
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
