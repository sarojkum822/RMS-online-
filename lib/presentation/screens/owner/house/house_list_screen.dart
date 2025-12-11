import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'house_controller.dart';

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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home_work_outlined, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No properties yet',
                    style: GoogleFonts.outfit(fontSize: 18, color: Colors.grey[500]),
                  ),
                ],
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
                      color: Colors.grey.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      // Navigate to details
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0F2F1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.apartment, color: Color(0xFF00897B)),
                              ),
                              PopupMenuButton(
                                icon: Icon(Icons.more_horiz, color: Colors.grey[400]),
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    child: const Text('Delete'),
                                    onTap: () {
                                      ref.read(houseControllerProvider.notifier).deleteHouse(house.id);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
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
