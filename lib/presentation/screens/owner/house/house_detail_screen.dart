import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rentpilotpro/presentation/screens/owner/house/house_form_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
             if (house.imageUrl != null)
               Padding(
                 padding: const EdgeInsets.only(bottom: 24.0),
                 child: Hero(
                   tag: 'house_${house.id}',
                   child: ClipRRect(
                     borderRadius: BorderRadius.circular(20),
                     child: CachedNetworkImage(
                       imageUrl: house.imageUrl!,
                       height: 200,
                       width: double.infinity,
                       fit: BoxFit.cover,
                       placeholder: (context, url) => Container(height: 200, color: Colors.grey[200], child: const Center(child: CircularProgressIndicator())),
                       errorWidget: (context, url, error) => Container(height: 200, color: Colors.grey[200], child: const Icon(Icons.broken_image, color: Colors.grey)),
                     ),
                   ),
                 ),
               ),

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
                              color: Colors.grey.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                       ),
                       child: ListTile(
                         contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                         title: Text(unit.nameOrNumber, style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                         subtitle: Text('Default Due Day: ${unit.defaultDueDay}', style: GoogleFonts.outfit(color: Colors.grey)),
                         trailing: Row(
                           mainAxisSize: MainAxisSize.min,
                           children: [
                              IconButton(
                                icon: Icon(Icons.bolt, color: Colors.orange[400]),
                                onPressed: () => context.push('/owner/readings/${unit.id}', extra: {'unitName': unit.nameOrNumber}),
                              ),
                              PopupMenuButton(
                                icon: Icon(Icons.more_vert, color: Colors.grey[400]),
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    child: const Text('Edit'),
                                    onTap: () {
                                      // context.push('/owner/units/edit/${unit.id}'); // TODO: Implement Route
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edit Unit coming soon')));
                                    },
                                  ),
                                  PopupMenuItem(
                                    child: const Text('Delete'),
                                    onTap: () {
                                      // Confirm Dialog?
                                      ref.read(houseControllerProvider.notifier).deleteUnit(unit.id);
                                    },
                                  ),
                                ],
                              ),
                           ],
                         ),
                         onTap: () {
                            // Maybe navigate to unit details or readings? readings is already on trailing bolt.
                            // keeping tap empty or redundant for now.
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
             Text(house.notes!, style: GoogleFonts.outfit(color: Colors.white.withValues(alpha: 0.9), fontSize: 13, fontStyle: FontStyle.italic)),
          ],
        ],
      )
    );
  }
}
