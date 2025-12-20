import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'fade_in_up.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final Widget? customImage; // allow custom image widget

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.subtitle = '',
    this.icon,
    this.buttonText,
    this.onButtonPressed,
    this.customImage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: FadeInUp(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // prevent taking full height in some scrolls
            children: [
              if (customImage != null)
                customImage!
              else if (icon != null)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: isDark ? theme.colorScheme.surfaceContainerHighest : Colors.grey[50], // surfaceContainerHighest is better for M3
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon, 
                    size: 64, 
                    color: theme.colorScheme.primary.withValues(alpha: 0.5)
                  ),
                ),
              
              const SizedBox(height: 32),
              
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
              
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
              
              if (buttonText != null && onButtonPressed != null) ...[
                const SizedBox(height: 40),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: onButtonPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      shadowColor: theme.colorScheme.primary.withValues(alpha: 0.4),
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                    ),
                    child: Text(
                      buttonText!,
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
