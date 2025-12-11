
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../domain/entities/house.dart';
import 'house_controller.dart';

class HouseDetailScreen extends ConsumerWidget {
  final House house;

  const HouseDetailScreen({super.key, required this.house});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unitsAsync = ref.watch(houseUnitsProvider(house.id));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(house.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black), 
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             _HouseInfoCard(house: house),
             const SizedBox(height: 24),
             Text('Units', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
             const SizedBox(height: 12),
             unitsAsync.when(
               data: (units) {
                 if (units.isEmpty) return const Text('No units found.');
                 return ListView.separated(
                   shrinkWrap: true,
                   physics: const NeverScrollableScrollPhysics(),
                   itemCount: units.length,
                   separatorBuilder: (c, i) => const SizedBox(height: 12),
                   itemBuilder: (context, index) {
                     final unit = units[index];
                     return Container(
                       decoration: BoxDecoration(
                         color: Colors.white,
                         borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                       ),
                       child: ListTile(
                         contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                         title: Text(unit.nameOrNumber, style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                         subtitle: Text('Default Due Day: ${unit.defaultDueDay}', style: GoogleFonts.outfit(color: Colors.grey)),
                         trailing: Icon(Icons.bolt, color: Colors.orange[400]),
                         onTap: () {
                           context.push('/owner/readings/${unit.id}', extra: {'unitName': unit.nameOrNumber});
                         },
                       ),
                     );
                   },
                 );
               },
               loading: () => const Center(child: CircularProgressIndicator()),
               error: (e, s) => Text('Error: $e'),
             ),
          ],
        ),
      ),
    );
  }
}

class _HouseInfoCard extends StatelessWidget {
  final House house;
  const _HouseInfoCard({required this.house});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00897B), Color(0xFF4DB6AC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text(house.address, style: GoogleFonts.outfit(color: Colors.white, fontSize: 14)),
            ],
          ),
          if (house.notes != null) ...[
            const SizedBox(height: 12),
             Text(house.notes!, style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.9), fontSize: 13, fontStyle: FontStyle.italic)),
          ],
        ],
      )
    );
  }
}
