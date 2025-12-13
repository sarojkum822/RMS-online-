import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bhk_template_controller.dart';
import '../../../../domain/entities/bhk_template.dart';

class BhkTemplateListScreen extends ConsumerWidget {
  final int houseId;
  const BhkTemplateListScreen({super.key, required this.houseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(bhkTemplateControllerProvider(houseId));

    return Scaffold(
      appBar: AppBar(title: const Text('BHK Templates')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref, houseId),
        child: const Icon(Icons.add),
      ),
      body: templatesAsync.when(
        data: (templates) {
          if (templates.isEmpty) {
            return const Center(child: Text('No BHK Templates found. Create one to classify your units.'));
          }
          return ListView.builder(
            itemCount: templates.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final t = templates[index];
              return Card(
                child: ListTile(
                  title: Text(t.bhkType, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Base Rent: ₹${t.defaultRent}'),
                  trailing: const Icon(Icons.edit, size: 20),
                  onTap: () {
                     // TODO: Implement Edit
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Editing coming soon')));
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref, int houseId) {
    final bhkCtrl = TextEditingController();
    final rentCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add BHK Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: bhkCtrl, decoration: const InputDecoration(labelText: 'BHK Type (e.g. 2BHK)')),
            TextField(controller: rentCtrl, decoration: const InputDecoration(labelText: 'Default Rent'), keyboardType: TextInputType.number),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description (Optional)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (bhkCtrl.text.isNotEmpty && rentCtrl.text.isNotEmpty) {
                 await ref.read(bhkTemplateControllerProvider(houseId).notifier).addBhkTemplate(
                   houseId: houseId,
                   bhkType: bhkCtrl.text,
                   defaultRent: double.tryParse(rentCtrl.text) ?? 0,
                   description: descCtrl.text,
                 );
                 if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
