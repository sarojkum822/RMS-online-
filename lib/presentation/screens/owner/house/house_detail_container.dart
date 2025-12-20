
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../domain/entities/house.dart';
import 'house_controller.dart';
import 'house_detail_screen.dart';

class HouseDetailContainer extends ConsumerWidget {
  final String houseId;
  final House? house;

  const HouseDetailContainer({
    super.key, 
    required this.houseId, 
    this.house
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (house != null) {
      return HouseDetailScreen(house: house!);
    }

    // Fetch by ID if house object is missing (Deep Link)
    // We assume houseControllerProvider loads all houses or we can fetch individually.
    // Let's rely on houseControllerProvider list first for simplicity and speed.
    final housesAsync = ref.watch(houseControllerProvider);

    return housesAsync.when(
      data: (houses) {
         try {
           final fetchedHouse = houses.firstWhere(
              (h) => h.id == houseId,
           );
           return HouseDetailScreen(house: fetchedHouse);
         } catch (e) {
           return Scaffold(
             appBar: AppBar(title: const Text('Property Not Found')),
             body: Center(child: Text("Property with ID $houseId not found.", style: GoogleFonts.outfit())),
           );
         }
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
    );
  }
}
