import 'dart:convert'; // NEW
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
// Removed unused import: image_picker
import '../../../../../domain/entities/house.dart';
import '../../../../../core/utils/dialog_utils.dart'; // NEW
import '../../../../providers/data_providers.dart';
import '../bhk_template_controller.dart';
import '../house_controller.dart';
import '../../rent/rent_controller.dart'; // For latestReadingProvider

class UnitListTile extends ConsumerStatefulWidget {
  final Unit unit;
  
  const UnitListTile({super.key, required this.unit});

  @override
  ConsumerState<UnitListTile> createState() => _UnitListTileState();
}

class _UnitListTileState extends ConsumerState<UnitListTile> {
  // Controllers
  late TextEditingController _baseRentCtrl;
  late TextEditingController _carpetAreaCtrl;
  late TextEditingController _parkingCtrl;
  late TextEditingController _meterCtrl;
  
  String? _selectedBhkTemplateId;
  String? _selectedBhkType;
  String? _furnishingStatus;
  
  bool _isExpanded = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _baseRentCtrl = TextEditingController(text: widget.unit.baseRent.toString());
    _carpetAreaCtrl = TextEditingController(text: widget.unit.carpetArea?.toString() ?? '');
    _parkingCtrl = TextEditingController(text: widget.unit.parkingSlot ?? '');
    _meterCtrl = TextEditingController(text: widget.unit.meterNumber ?? '');
    
    _selectedBhkTemplateId = widget.unit.bhkTemplateId;
    _selectedBhkType = widget.unit.bhkType;
    _furnishingStatus = widget.unit.furnishingStatus;
  }

  @override
  void didUpdateWidget(covariant UnitListTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.unit != widget.unit) {
       // Sync if closed, or maybe just sync always? 
       // If user is editing, we shouldn't overwrite unless they saved.
       // But if we just saved, we receive new props.
       if (!_isExpanded) {
          _baseRentCtrl.text = widget.unit.baseRent.toString();
          _carpetAreaCtrl.text = widget.unit.carpetArea?.toString() ?? '';
          _parkingCtrl.text = widget.unit.parkingSlot ?? '';
          _meterCtrl.text = widget.unit.meterNumber ?? '';
          
          _selectedBhkTemplateId = widget.unit.bhkTemplateId;
          _selectedBhkType = widget.unit.bhkType;
          _furnishingStatus = widget.unit.furnishingStatus;
       }
    }
  }

  @override
  void dispose() {
    _baseRentCtrl.dispose();
    _carpetAreaCtrl.dispose();
    _parkingCtrl.dispose();
    _meterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bhkTemplatesAsync = ref.watch(bhkTemplateControllerProvider(widget.unit.houseId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Watch latest meter reading for this unit
    final latestReadingAsync = ref.watch(latestReadingProvider(widget.unit.id));

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? [] : [
          BoxShadow(
             color: Colors.grey.withValues(alpha: 0.05),
             blurRadius: 10, offset: const Offset(0, 4),
          ),
        ],
        border: isDark ? Border.all(color: Colors.white10) : null,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: const Border(), // Remove borders when expanded
          leading: _buildLeadingPreview(context), // Thumbnail
          title: Text(widget.unit.nameOrNumber, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: theme.textTheme.titleMedium?.color)),
          subtitle: Text(
            '₹${widget.unit.baseRent.toStringAsFixed(0)}',
            style: GoogleFonts.outfit(color: theme.textTheme.bodySmall?.color, fontSize: 13),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Occupied/Vacant Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.unit.isOccupied 
                      ? const Color(0xFFE8F5E9) // Light green
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.unit.isOccupied 
                        ? const Color(0xFF4CAF50) 
                        : Colors.grey.shade400,
                    width: 1,
                  ),
                ),
                child: Text(
                  widget.unit.isOccupied ? 'Occupied' : 'Vacant',
                  style: GoogleFonts.outfit(
                    color: widget.unit.isOccupied 
                        ? const Color(0xFF2E7D32) 
                        : Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          onExpansionChanged: (expanded) {
            setState(() => _isExpanded = expanded);
          },
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          children: [
            Divider(color: theme.dividerColor),
            const SizedBox(height: 10),
            
            // --- EDIT FORM ---
            
            // BHK Dropdown
            bhkTemplatesAsync.when(
              data: (templates) => DropdownButtonFormField<String>(
                   value: _selectedBhkTemplateId,
                   dropdownColor: theme.cardColor,
                   decoration: const InputDecoration(
                     labelText: 'BHK Type',
                     contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                     border: OutlineInputBorder(),
                   ),
                   items: templates.map((t) => DropdownMenuItem<String>(
                     value: t.id,
                     child: Text('${t.bhkType} (₹${t.defaultRent})', style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
                   )).toList(),
                   onChanged: (val) {
                     if (val != null) {
                       final t = templates.firstWhere((e) => e.id == val);
                       setState(() {
                         _selectedBhkTemplateId = val;
                         _selectedBhkType = t.bhkType;
                         _baseRentCtrl.text = t.defaultRent.toString();
                       });
                     }
                   },
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => const Text('Error loading templates'),
            ),
            
            const SizedBox(height: 12),
            
            // Rent & Area Row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _baseRentCtrl,
                    decoration: const InputDecoration(labelText: 'Rent', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _carpetAreaCtrl,
                    decoration: const InputDecoration(labelText: 'Area (sqft)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),

            // Parking & Meter Row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _parkingCtrl,
                    decoration: const InputDecoration(labelText: 'Parking Slot', border: OutlineInputBorder()),
                    style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _meterCtrl,
                    decoration: const InputDecoration(labelText: 'Meter Number', border: OutlineInputBorder()),
                    style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Last Meter Reading Display
            latestReadingAsync.when(
              data: (reading) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.amber.withValues(alpha: 0.1) : Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.flash_on, color: Colors.amber.shade700, size: 20),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Last Meter Reading', style: GoogleFonts.outfit(fontSize: 12, color: theme.hintColor)),
                          Text(
                            reading != null ? '${reading.toStringAsFixed(1)} units' : 'N/A', 
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: theme.textTheme.bodyLarge?.color),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            
            const SizedBox(height: 12),
            
            // Furnishing
            DropdownButtonFormField<String>(
              value: _furnishingStatus,
              dropdownColor: theme.cardColor,
              decoration: const InputDecoration(labelText: 'Furnishing', border: OutlineInputBorder()),
              items: ['Unfurnished', 'Semi-Furnished', 'Fully-Furnished']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s, style: TextStyle(fontSize: 13, color: theme.textTheme.bodyLarge?.color)))).toList(),
              onChanged: (v) => setState(() => _furnishingStatus = v),
            ),
            
            const SizedBox(height: 16),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary, 
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isSaving 
                   ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                   : const Text('Save Changes'),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Duplicate & Delete Unit Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _duplicateUnit(context),
                    icon: Icon(Icons.copy, size: 18, color: theme.colorScheme.primary),
                    label: Text('Duplicate Unit', style: GoogleFonts.outfit(color: theme.colorScheme.primary, fontWeight: FontWeight.w500)),
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _deleteUnit(context),
                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                    label: Text('Delete Unit', style: GoogleFonts.outfit(color: Colors.red, fontWeight: FontWeight.w500)),
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _duplicateUnit(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Duplicate Unit'),
        content: Text('Create a copy of "${widget.unit.nameOrNumber}" with the same settings?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Duplicate'),
          ),
        ],
      ),
    );
    
    if (confirm == true && mounted) {
      try {
        await DialogUtils.runWithLoading(context, () async {
          // Get existing units using the provider
          final existingUnits = ref.read(houseUnitsProvider(widget.unit.houseId)).valueOrNull ?? [];
          
          // Generate new unit name (append copy number)
          final baseName = widget.unit.nameOrNumber.replaceAll(RegExp(r'\s*\(Copy.*\)'), '');
          int copyNum = 1;
          String newName = '$baseName (Copy)';
          while (existingUnits.any((u) => u.nameOrNumber == newName)) {
            copyNum++;
            newName = '$baseName (Copy $copyNum)';
          }
          
          // Create duplicate unit (without occupied status)
          await ref.read(houseControllerProvider.notifier).addUnit(
            widget.unit.houseId,
            newName,
            baseRent: widget.unit.baseRent,
            bhkTemplateId: widget.unit.bhkTemplateId,
            bhkType: widget.unit.bhkType,
          );
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unit duplicated successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }
  
  Future<void> _deleteUnit(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Unit'),
        content: Text('Are you sure you want to delete "${widget.unit.nameOrNumber}"? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirm == true && mounted) {
      try {
        await DialogUtils.runWithLoading(context, () async {
          await ref.read(houseControllerProvider.notifier).deleteUnit(widget.unit.id);
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unit deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  // Note: Subtitle is now inline in the build method

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final repo = ref.read(propertyRepositoryProvider);
      
      final updatedUnit = widget.unit.copyWith(
        baseRent: double.tryParse(_baseRentCtrl.text) ?? 0.0,
        bhkTemplateId: _selectedBhkTemplateId,
        bhkType: _selectedBhkType,
        furnishingStatus: _furnishingStatus,
        carpetArea: double.tryParse(_carpetAreaCtrl.text),
        parkingSlot: _parkingCtrl.text.trim().isEmpty ? null : _parkingCtrl.text.trim(),
        meterNumber: _meterCtrl.text.trim().isEmpty ? null : _meterCtrl.text.trim(),
      );
      
      await repo.updateUnit(updatedUnit);
      ref.invalidate(houseUnitsProvider(widget.unit.houseId));
      
      if(mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unit updated'), duration: Duration(seconds: 1)));
         // Optional: Collapse tile?
         // setState(() => _isExpanded = false); // Can't easily collapse expansion tile programmatically without key/controller tricks.
      }
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if(mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildLeadingPreview(BuildContext context) {
    // Show first image or placeholder
    String? previewData;
    if (widget.unit.imagesBase64.isNotEmpty) {
      previewData = widget.unit.imagesBase64.first;
    } else if (widget.unit.imageUrls.isNotEmpty) {
      previewData = widget.unit.imageUrls.first;
    }

    return GestureDetector(
      onTap: () => _showImageGallery(context),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        clipBehavior: Clip.antiAlias,
        child: previewData != null
            ? _buildImage(previewData)
            : Icon(Icons.add_photo_alternate_outlined, size: 20, color: Theme.of(context).primaryColor),
      ),
    );
  }

  Widget _buildImage(String data) {
      if (data.startsWith('http')) {
         return Image.network(data, fit: BoxFit.cover);
      } else {
         try {
           return Image.memory(base64Decode(data), fit: BoxFit.cover);
         } catch (e) {
           return const Icon(Icons.error, size: 16);
         }
      }
  }

  void _showImageGallery(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _UnitImagesDialog(unit: widget.unit),
    );
  }
}

class _UnitImagesDialog extends ConsumerStatefulWidget {
  final Unit unit;
  const _UnitImagesDialog({required this.unit});

  @override
  ConsumerState<_UnitImagesDialog> createState() => _UnitImagesDialogState();
}

class _UnitImagesDialogState extends ConsumerState<_UnitImagesDialog> {
  late List<String> _images;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    // Prioritize Base64 images, fallback to URLs for backward compatibility
    if (widget.unit.imagesBase64.isNotEmpty) {
      _images = List.from(widget.unit.imagesBase64);
    } else {
      _images = List.from(widget.unit.imageUrls);
    }
  }

  Future<void> _uploadImage() async {
    if (_images.length >= 4) return;
    
    final storage = ref.read(storageServiceProvider);
    
    // Pick & Compress & Upload
    setState(() => _isUploading = true);
    try {
      // NEW: Base64 Logic - Multi Select
      final files = await storage.pickMultiImage();
      if (files.isEmpty) {
         setState(() => _isUploading = false);
         return;
      }
      
      for (final file in files) {
         // Check limit inside loop
         if (_images.length >= 4) break;

         final compressedFile = await storage.compressImage(file, minWidth: 512, quality: 60);
         if (compressedFile != null) {
           final bytes = await compressedFile.readAsBytes();
           final base64String = base64Encode(bytes);
           setState(() => _images.add(base64String));
         }
      }
      await _saveImages();

      // Removed old url check
      // if (url != null) {
      //   setState(() => _images.add(url));
      //   await _saveImages();
      // }
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      if(mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _deleteImage(String url) async {
    setState(() => _images.remove(url));
    await _saveImages();
  }

  Future<void> _saveImages() async {
    final repo = ref.read(propertyRepositoryProvider);
    // Determine if we are saving Base64 or URLs. 
    // Since we only add Base64 now, we assume _images contains Base64 strings.
    // For mixed backward compatibility, we'll just save to imagesBase64 field if they look like base64, 
    // but simplified: We are moving to Base64 only for new edits.
    final updatedUnit = widget.unit.copyWith(imagesBase64: _images);
    await repo.updateUnit(updatedUnit);
    ref.invalidate(houseUnitsProvider(widget.unit.houseId));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Flat Photos', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          Text('${_images.length}/4', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 14)),
        ],
      ),
      content: SizedBox(
        width: 300, // Fixed standard width to avoid being "too big"
        child: _images.isEmpty && !_isUploading
          ? Center(
              child: GestureDetector(
                onTap: _uploadImage,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_a_photo_outlined, size: 48, color: Theme.of(context).primaryColor),
                      const SizedBox(height: 16),
                      Text('No photos added yet.\nClick here to add.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], decoration: TextDecoration.underline)),
                    ],
                  ),
                ),
              ),
            )
          : GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, 
                crossAxisSpacing: 8, 
                mainAxisSpacing: 8,
                childAspectRatio: 1.0,
              ),
              itemCount: _images.length + (_images.length < 4 ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _images.length) {
                  // Add Button
                  return GestureDetector(
                    onTap: _isUploading ? null : _uploadImage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                      ),
                      child: _isUploading 
                        ? const Center(child: CircularProgressIndicator()) 
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_circle_outline, size: 32, color: Theme.of(context).primaryColor),
                              const SizedBox(height: 4),
                              Text('Add Photo', style: TextStyle(fontSize: 12, color: Theme.of(context).primaryColor)),
                            ],
                          ),
                    ),
                  );
                }
                
                final imgUrl = _images[index];
                return GestureDetector(
                   onTap: () => DialogUtils.showImageDialog(context, imgUrl),
                   child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _buildImage(imgUrl),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _deleteImage(imgUrl),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                            child: const Icon(Icons.close, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
      ],
    );
  }
  Widget _buildImage(String data) {
    // Basic heuristic to check if simple URL or Base64
    if (data.startsWith('http')) {
       return Image.network(data, fit: BoxFit.cover);
    } else {
       try {
         return Image.memory(base64Decode(data), fit: BoxFit.cover);
       } catch (e) {
         return Container(color: Colors.grey, child: const Icon(Icons.error));
       }
    }
  }
}
