import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _emailNotifs = true;
  bool _pushNotifs = true;
  bool _rentDueReminders = true;
  bool _paymentReceived = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Ideally use ref.read(notificationServiceProvider) but require Consumer
    // For now create new instance is safe as it wraps singleton plugins internally or is stateless wrapper
    final enabled = await NotificationService().areNotificationsEnabled;
    if (mounted) {
      setState(() {
        _pushNotifs = enabled;
        _rentDueReminders = enabled; 
        _isLoading = false;
      });
    }
  }

  Future<void> _updateSettings(bool value) async {
    setState(() => _pushNotifs = value);
    await NotificationService().setNotificationsEnabled(value);
    setState(() => _rentDueReminders = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Notifications', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: theme.iconTheme,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader('Channels', theme),
          _buildSwitch(context, 'Push Notifications', 'Receive alerts on your device', _pushNotifs, (v) => _updateSettings(v)),
          _buildSwitch(context, 'Email Notifications', 'Receive updates via email', _emailNotifs, (v) => setState(() => _emailNotifs = v)),
          
          Divider(height: 32, color: theme.dividerColor),
          
          _buildSectionHeader('Alert Types', theme),
          _buildSwitch(context, 'Rent Due Reminders', 'Notify when rent is due', _rentDueReminders, (v) {
             // For now just toggle UI, but realistically if master is off, this shouldn't work
             setState(() => _rentDueReminders = v);
          }),
          _buildSwitch(context, 'Payment Received', 'Notify when a tenant pays', _paymentReceived, (v) => setState(() => _paymentReceived = v)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: theme.hintColor)),
    );
  }

  Widget _buildSwitch(BuildContext context, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: SwitchListTile(
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w500, color: theme.textTheme.bodyLarge?.color)),
        subtitle: Text(subtitle, style: GoogleFonts.outfit(fontSize: 12, color: theme.textTheme.bodySmall?.color)),
        value: value,
        onChanged: onChanged,
        activeThumbColor: theme.colorScheme.primary,
      ),
    );
  }
}
