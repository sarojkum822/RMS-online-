import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class ActiveSessionsScreen extends ConsumerWidget {
  const ActiveSessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock Data for now as we don't have backend session management yet
    final currentSession = _SessionInfo(
      deviceName: Platform.isAndroid ? 'Android Device' : 'iOS Device',
      ipAddress: '192.168.1.105', // Mock
      location: 'New Delhi, India', // Mock
      lastActive: DateTime.now(),
      isCurrent: true,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Active Sessions', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Current Session',
            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          _buildSessionItem(context, currentSession),
          
          const SizedBox(height: 32),
          Text(
            'Other Sessions',
            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          // Empty state for other sessions
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(Icons.devices_other, size: 48, color: Colors.grey),
                const SizedBox(height: 12),
                Text('No other active sessions', style: GoogleFonts.outfit(color: Colors.grey)),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logged out of all other sessions')));
              }, 
              child: const Text('Log Out of All Other Devices'),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSessionItem(BuildContext context, _SessionInfo session) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: session.isCurrent ? Border.all(color: Colors.green.withValues(alpha: 0.5)) : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: session.isCurrent ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Platform.isAndroid ? Icons.android : Icons.phone_iphone,
              color: session.isCurrent ? Colors.green : Colors.grey,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(session.deviceName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                    if (session.isCurrent) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('THIS DEVICE', style: GoogleFonts.outfit(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                      )
                    ]
                  ],
                ),
                const SizedBox(height: 4),
                Text('${session.location} • ${session.ipAddress}', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(
                  session.isCurrent ? 'Active now' : 'Last active: ${DateFormat.yMMMd().format(session.lastActive)}',
                  style: GoogleFonts.outfit(
                    fontSize: 12, 
                    color: session.isCurrent ? Colors.green : Colors.grey,
                    fontWeight: session.isCurrent ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionInfo {
  final String deviceName;
  final String ipAddress;
  final String location;
  final DateTime lastActive;
  final bool isCurrent;

  _SessionInfo({
    required this.deviceName,
    required this.ipAddress,
    required this.location,
    required this.lastActive,
    required this.isCurrent,
  });
}
