import 'package:flutter/material.dart';
import '../../../../domain/entities/house.dart';

class HouseFormScreen extends StatelessWidget {
  final House? house;
  const HouseFormScreen({super.key, this.house});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(house == null ? 'Add Property' : 'Edit Property')),
      body: const Center(child: Text('Property Form Placeholder')),
    );
  }
}
