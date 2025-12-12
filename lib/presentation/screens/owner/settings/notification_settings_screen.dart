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
    final enabled = await NotificationService().areNotificationsEnabled;
    if (mounted) {
      setState(() {
        _pushNotifs = enabled;
        // Logic: if push enabled, we assume Rent Due is enabled for now or align them
        _rentDueReminders = enabled; 
        _isLoading = false;
      });
    }
  }

  Future<void> _updateSettings(bool value) async {
    setState(() => _pushNotifs = value);
    await NotificationService().setNotificationsEnabled(value);
    // Also update sub-toggles to reflect the master switch visually
    setState(() => _rentDueReminders = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Notifications', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader('Channels'),
          _buildSwitch('Push Notifications', 'Receive alerts on your device', _pushNotifs, (v) => _updateSettings(v)),
          _buildSwitch('Email Notifications', 'Receive updates via email', _emailNotifs, (v) => setState(() => _emailNotifs = v)),
          
          const Divider(height: 32),
          
          _buildSectionHeader('Alert Types'),
          _buildSwitch('Rent Due Reminders', 'Notify when rent is due', _rentDueReminders, (v) {
             // For now just toggle UI, but realistically if master is off, this shouldn't work
             setState(() => _rentDueReminders = v);
          }),
          _buildSwitch('Payment Received', 'Notify when a tenant pays', _paymentReceived, (v) => setState(() => _paymentReceived = v)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }

  Widget _buildSwitch(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.black,
      ),
    );
  }
}
