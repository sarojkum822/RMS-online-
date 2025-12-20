import 'dart:convert'; // NEW
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'house_controller.dart';
import '../../../../domain/entities/house.dart';
import '../settings/owner_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../../../widgets/ads/banner_ad_widget.dart';

class HouseListScreen extends ConsumerWidget {
  const HouseListScreen({super.key});

  static const List<String> _kRandomHouseImages = [
    'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800&q=80',
    'https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=800&q=80',
    'https://images.unsplash.com/photo-1554995207-c18c203602cb?w=800&q=80',
    'https://images.unsplash.com/photo-1600596542815-2a4d04774c13?w=800&q=80',
    'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800&q=80',
    'https://images.unsplash.com/photo-1600566753086-00f18fb6b3ea?w=800&q=80',
    'https://images.unsplash.com/photo-1600573472550-8090b5e0745e?w=800&q=80',
    'https://images.unsplash.com/photo-1600047509807-ba8f99d2cdde?w=800&q=80',
    'https://images.unsplash.com/photo-1512918760383-eda273e280ec?w=800&q=80',
    'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800&q=80',  
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final housesAsync = ref.watch(houseControllerProvider);
    final isFreePlan = ref.watch(ownerControllerProvider).valueOrNull?.subscriptionPlan == 'free';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('properties.title'.tr(), 
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold, 
            fontSize: 28, 
            color: theme.textTheme.titleLarge?.color
          )
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: theme.iconTheme,
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_house',
        onPressed: () => context.push('/owner/houses/add'),
        label: Text('properties.add_btn'.tr(), style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color(0xFF2563EB),
        elevation: 4,
      ),
      body: housesAsync.when(
        data: (houses) {
          if (houses.isEmpty) {
            return Center(
              child: EmptyStateWidget(
                title: 'properties.empty_title'.tr(),
                subtitle: 'properties.empty_subtitle'.tr(),
                icon: Icons.home_work_outlined,
                buttonText: 'properties.add_btn'.tr(),
                onButtonPressed: () => context.push('/owner/houses/add'),
              ),
            );
          }
          return CustomScrollView(
            slivers: [
              // Full-width Ad
              if (isFreePlan)
              const SliverToBoxAdapter(
                 child: Padding(
                   padding: EdgeInsets.symmetric(vertical: 16.0),
                   child: BannerAdWidget(),
                 ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final house = houses[index];
                      // Add spacing between items manually since we removed separatorBuilder
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: ModernPropertyCard(house: house, isDark: isDark, theme: theme, ref: ref),
                      );
                    },
                    childCount: houses.length,
                  ),
                ),
              ),
              // Bottom padding
              const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
            ],
          );
        },
        error: (e, st) => Center(child: Text('Error: $e', style: TextStyle(color: theme.textTheme.bodyMedium?.color))),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class ModernPropertyCard extends StatelessWidget {
  final House house;
  final bool isDark;
  final ThemeData theme;
  final WidgetRef ref;

  const ModernPropertyCard({
    required this.house,
    required this.isDark,
    required this.theme,
    required this.ref,
  });

  Widget _buildImageWidget() {
    if (house.imageBase64 != null) {
      return Image.memory(
        base64Decode(house.imageBase64!),
        fit: BoxFit.cover,
        errorBuilder: (_,__,___) => Container(color: Colors.grey[800], child: const Icon(Icons.broken_image)),
      );
    } else if (house.imageUrl != null && house.imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: house.imageUrl!, 
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(color: isDark ? Colors.grey[800] : Colors.grey[200]),
        errorWidget: (context, url, error) => Container(color: Colors.grey[800], child: const Icon(Icons.broken_image)),
      );
    } else {
      return Image.network(
        HouseListScreen._kRandomHouseImages[house.id.hashCode.abs() % HouseListScreen._kRandomHouseImages.length],
        fit: BoxFit.cover,
        errorBuilder: (_,__,___) => Container(color: Colors.grey[800]),
      );
    }
  }

  static const List<String> _kRandomHouseImages = [
    'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800&q=80',
    'https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=800&q=80',
    'https://images.unsplash.com/photo-1554995207-c18c203602cb?w=800&q=80',
    'https://images.unsplash.com/photo-1600596542815-2a4d04774c13?w=800&q=80',
    'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800&q=80',
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/owner/houses/${house.id}', extra: house),
      child: Container(
        height: 280, // Immersive height
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.black12,
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Background Image
              Hero(
                tag: 'house_${house.id}',
                child: _buildImageWidget(),
              ),
              
              // 2. Gradient Overlay for Text Readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.2), // Slight dark top
                      Colors.black.withValues(alpha: 0.8), // Strong dark bottom
                    ],
                    stops: const [0.5, 0.7, 1.0],
                  ),
                ),
              ),

              // 3. Content Overlay (Glassmorphism Vibe)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         crossAxisAlignment: CrossAxisAlignment.end,
                         children: [
                           Expanded(
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                  Text(
                                    house.name,
                                    style: GoogleFonts.outfit(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2))],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, color: Colors.white70, size: 14),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          house.address,
                                          style: GoogleFonts.outfit(
                                            fontSize: 14,
                                            color: Colors.white70,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                               ],
                             ),
                           ),
                           // Stats Pills
                           Consumer(
                              builder: (context, ref, _) {
                                final statsValue = ref.watch(houseStatsProvider(house.id));
                                return statsValue.when(
                                  data: (stats) {
                                    final occupancyRate = stats['occupancyRate'] as double;
                                    final isFull = occupancyRate >= 1.0;
                                    
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isFull ? Colors.green.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isFull ? Colors.green.withValues(alpha: 0.5) : Colors.orange.withValues(alpha: 0.5),
                                          width: 1,
                                        ),
                                        boxShadow: [BoxShadow(color: (isFull ? Colors.green : Colors.orange).withValues(alpha: 0.1), blurRadius: 10)],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            isFull ? Icons.check_circle : Icons.pie_chart, 
                                            size: 14, 
                                            color: isFull ? Colors.greenAccent : Colors.orangeAccent
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            isFull ? 'Full' : '${(occupancyRate * 100).toInt()}%',
                                            style: TextStyle(
                                              color: isFull ? Colors.greenAccent : Colors.orangeAccent,
                                              fontSize: 12, 
                                              fontWeight: FontWeight.bold
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  loading: () => const SizedBox(),
                                  error: (_, __) => const SizedBox(),
                                );
                              }
                           ),
                         ],
                       ),
                    ],
                  ),
                ),
              ),
              
              // 4. Floating Menu Button (Top Right)
              Positioned(
                top: 16,
                right: 16,
                child: Material(
                  color: Colors.black26, // Semi-transparent darkness
                  shape: const CircleBorder(),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: () {}, // Handled by popup
                    child: PopupMenuButton(
                      icon: const Icon(Icons.more_horiz, color: Colors.white),
                      color: theme.cardColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: Row(children: [Icon(Icons.edit, size: 18, color: theme.iconTheme.color), SizedBox(width: 12), Text('properties.edit'.tr())]),
                          onTap: () => context.push('/owner/houses/edit/${house.id}', extra: house),
                        ),
                        PopupMenuItem(
                          child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 12), Text('properties.delete'.tr(), style: TextStyle(color: Colors.red))]),
                          onTap: () {
                             Future.delayed(const Duration(seconds: 0), () {
                               if (context.mounted) _confirmDelete(context, ref, house);
                             });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _confirmDelete(BuildContext context, WidgetRef ref, dynamic house) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('properties.delete_title'.tr()),
        content: Text('properties.delete_msg'.tr(args: [house.name])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('properties.cancel'.tr())),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await DialogUtils.runWithLoading(context, () async {
                 await ref.read(houseControllerProvider.notifier).deleteHouse(house.id);
              });
            },
            child: Text('properties.delete'.tr()),
          ),
        ],
      ),
    );
  }
}

class InfoBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  const InfoBadge({required this.icon, required this.text, this.color});

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
