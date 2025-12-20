import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/bhk_template.dart';
import 'bhk_template_controller.dart';

class BhkTemplateListScreen extends ConsumerWidget {
  final String houseId;
  const BhkTemplateListScreen({super.key, required this.houseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(bhkTemplateControllerProvider(houseId));

    return Scaffold(
      appBar: AppBar(title: const Text('BHK Templates')),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_bhk',
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
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text('Base Rent: ₹${t.defaultRent}'),
                       const SizedBox(height: 4),
                       Row(
                         children: [
                           _buildDetailIcon(Icons.bed, '${t.roomCount}'),
                           const SizedBox(width: 8),
                           _buildDetailIcon(Icons.kitchen, '${t.kitchenCount}'),
                           const SizedBox(width: 8),
                           _buildDetailIcon(Icons.chair, '${t.hallCount}'),
                           if(t.hasBalcony) ...[
                             const SizedBox(width: 8),
                             _buildDetailIcon(Icons.balcony, '1'),
                           ]
                         ],
                       )
                    ],
                  ),
                  trailing: const Icon(Icons.edit, size: 20),
                  onTap: () => _showAddDialog(context, ref, houseId, template: t),
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

  void _showAddDialog(BuildContext context, WidgetRef ref, String houseId, {BhkTemplate? template}) {
    final bhkCtrl = TextEditingController(text: template?.bhkType);
    final rentCtrl = TextEditingController(text: template?.defaultRent.toString());
    final descCtrl = TextEditingController(text: template?.description);
    
    // Default Values
    int rooms = template?.roomCount ?? 1;
    int kitchens = template?.kitchenCount ?? 1;
    int halls = template?.hallCount ?? 1;
    bool balcony = template?.hasBalcony ?? false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(template == null ? 'Add BHK Type' : 'Edit BHK Type'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   TextField(controller: bhkCtrl, decoration: const InputDecoration(labelText: 'BHK Type', hintText: 'e.g. 2BHK', border: OutlineInputBorder())),
                   const SizedBox(height: 12),
                   TextField(controller: rentCtrl, decoration: const InputDecoration(labelText: 'Default Rent', border: OutlineInputBorder()), keyboardType: TextInputType.number),
                   const SizedBox(height: 12),
                   TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description (Optional)', border: OutlineInputBorder()), maxLines: 2),
                   const SizedBox(height: 16),
                   const Divider(),
                   _buildCounterRow('Rooms', rooms, (v) => setState(() => rooms = v)),
                   _buildCounterRow('Kitchens', kitchens, (v) => setState(() => kitchens = v)),
                   _buildCounterRow('Halls', halls, (v) => setState(() => halls = v)),
                   SwitchListTile(
                     title: const Text('Balcony'),
                     value: balcony,
                     onChanged: (v) => setState(() => balcony = v),
                     dense: true,
                     contentPadding: EdgeInsets.zero,
                   ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  if (bhkCtrl.text.isNotEmpty && rentCtrl.text.isNotEmpty) {
                     if (template == null) {
                       await ref.read(bhkTemplateControllerProvider(houseId).notifier).addBhkTemplate(
                         houseId: houseId,
                         bhkType: bhkCtrl.text,
                         defaultRent: double.tryParse(rentCtrl.text) ?? 0,
                         description: descCtrl.text,
                         roomCount: rooms,
                         kitchenCount: kitchens,
                         hallCount: halls,
                         hasBalcony: balcony,
                       );
                     } else {
                        await ref.read(bhkTemplateControllerProvider(houseId).notifier).updateBhkTemplate(
                         id: template.id,
                         houseId: houseId,
                         bhkType: bhkCtrl.text,
                         defaultRent: double.tryParse(rentCtrl.text) ?? 0,
                         description: descCtrl.text,
                         roomCount: rooms,
                         kitchenCount: kitchens,
                         hallCount: halls,
                         hasBalcony: balcony,
                       );
                     }
                     if (context.mounted) Navigator.pop(ctx);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildDetailIcon(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.grey[700]),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[800], fontWeight: FontWeight.bold)),
      ],
    );
  }
  Widget _buildCounterRow(String label, int value, Function(int) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                onPressed: () { if(value > 0) onChanged(value - 1); },
                visualDensity: VisualDensity.compact,
              ),
              Text('$value', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
                onPressed: () => onChanged(value + 1),
                visualDensity: VisualDensity.compact,
              ),
            ],
          )
        ],
      ),
    );
  }
}
