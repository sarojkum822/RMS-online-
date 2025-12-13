import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'house_controller.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../../core/utils/dialog_utils.dart';

class HouseListScreen extends ConsumerWidget {
  const HouseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final housesAsync = ref.watch(houseControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('My Properties', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/owner/houses/add'),
        label: Text('Add Property', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFF00897B),
        elevation: 4,
      ),
      body: housesAsync.when(
        data: (houses) {
          if (houses.isEmpty) {
            return Center(
              child: EmptyStateWidget(
                title: 'No properties yet',
                subtitle: 'Add your first property to start managing\ntenants and rent collection.',
                icon: Icons.home_work_outlined,
                buttonText: 'Add Property',
                onButtonPressed: () => context.push('/owner/houses/add'),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: houses.length,
            itemBuilder: (context, index) {
              final house = houses[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      context.push('/owner/houses/${house.id}', extra: house);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                          if (house.imageUrl != null)
                             Hero(
                               tag: 'house_${house.id}',
                               child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                   child: CachedNetworkImage(
                                      imageUrl: house.imageUrl!,
                                      height: 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(height: 150, color: Colors.grey[200], child: const Center(child: CircularProgressIndicator())),
                                      errorWidget: (context, url, error) => Container(height: 150, color: Colors.grey[200], child: const Icon(Icons.broken_image, color: Colors.grey)),
                                   ),
                               ),
                             ),
                          
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      if (house.imageUrl == null)
                                         Container(
                                           padding: const EdgeInsets.all(10),
                                           decoration: BoxDecoration(
                                             color: const Color(0xFFE0F2F1),
                                             borderRadius: BorderRadius.circular(12),
                                           ),
                                           child: const Icon(Icons.apartment, color: Color(0xFF00897B)),
                                         ),
                                      const Spacer(), // Spacer if no icon
                                      PopupMenuButton(
                                        icon: Icon(Icons.more_horiz, color: Colors.grey[400]),
                                        itemBuilder: (context) => [
                                          PopupMenuItem(
                                            child: const Text('Edit'),
                                            onTap: () {
                                               context.push('/owner/houses/edit/${house.id}', extra: house);
                                            },
                                          ),
                                          PopupMenuItem(
                                            child: const Text('Delete'),
                                            onTap: () {
                                               showDialog(
                                                 context: context,
                                                 builder: (ctx) => AlertDialog(
                                                   title: const Text('Delete Property'),
                                                   content: Text('Are you sure you want to delete "${house.name}"? This will also remove all its units.'),
                                                   actions: [
                                                     TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                                     TextButton(
                                                       onPressed: () async {
                                                         Navigator.pop(ctx); // Close Dialog
                                                         try {
                                                           await DialogUtils.runWithLoading(context, () async {
                                                              await ref.read(houseControllerProvider.notifier).deleteHouse(house.id);
                                                           });
                                                           if (context.mounted) {
                                                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Property deleted')));
                                                           }
                                                         } catch (e) {
                                                           if (context.mounted) {
                                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e'), backgroundColor: Colors.red));
                                                           }
                                                         }
                                                       },
                                                       style: TextButton.styleFrom(foregroundColor: Colors.red),
                                                       child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                                     ),
                                                   ],
                                                 ),
                                               );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  if (house.imageUrl == null) const SizedBox(height: 16),
                                  Text(
                                    house.name,
                                    style: GoogleFonts.outfit(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[500]),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          house.address,
                                          style: GoogleFonts.outfit(
                                            fontSize: 14,
                                            color: const Color(0xFF64748B),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  const Divider(height: 1),
                                  const SizedBox(height: 12),
                                  Consumer(
                                    builder: (context, ref, child) {
                                      final statsValue = ref.watch(houseStatsProvider(house.id));
                                      return statsValue.when(
                                        data: (stats) {
                                          final occupiedCount = stats['occupiedCount'] as int;
                                          final occupancyRate = stats['occupancyRate'] as double;
                                          
                                          return Row(
                                            children: [
                                              _InfoBadge(
                                                icon: Icons.people_outline, 
                                                text: '$occupiedCount Occupied',
                                                color: Colors.blue[700],
                                              ),
                                              const SizedBox(width: 12),
                                              _InfoBadge(
                                                icon: Icons.pie_chart_outline, 
                                                text: '${(occupancyRate * 100).toInt()}% Full', 
                                                color: occupancyRate > 0.8 ? Colors.green : Colors.orange
                                              ),
                                            ],
                                          );
                                        },
                                        loading: () => const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                                        error: (e, s) => const Text('Error'),
                                      );
                                    },
                                  ),
                               ],
                            ),
                          ),
                       ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        error: (e, st) => Center(child: Text('Error: $e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ), // Closing parentheses for housesAsync.when
    ); // Closing parentheses for Scaffold
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  const _InfoBadge({required this.icon, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.grey[600];
    return Row(
      children: [
        Icon(icon, size: 16, color: c),
        const SizedBox(width: 6),
        Text(text, style: GoogleFonts.outfit(fontSize: 13, color: c, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
