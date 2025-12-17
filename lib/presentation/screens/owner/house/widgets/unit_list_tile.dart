import 'dart:convert'; // NEW
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart'; // NEW
import '../../../../../domain/entities/house.dart';
import '../../../../../core/utils/dialog_utils.dart'; // NEW
import '../../../../providers/data_providers.dart';
import '../bhk_template_controller.dart';
import '../house_controller.dart';

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
  
  int? _selectedBhkTemplateId;
  String? _selectedBhkType;
  String? _furnishingStatus;
  
  bool _isExpanded = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _baseRentCtrl = TextEditingController(text: widget.unit.baseRent.toString());
    _carpetAreaCtrl = TextEditingController(text: widget.unit.carpetArea?.toString() ?? '');
    
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bhkTemplatesAsync = ref.watch(bhkTemplateControllerProvider(widget.unit.houseId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
          leading: _buildLeadingPreview(context), // NEW: Thumbnail
          title: Text(widget.unit.nameOrNumber, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: theme.textTheme.titleMedium?.color)),
          subtitle: _buildSubtitle(theme),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit, size: 20, color: theme.iconTheme.color),
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
              data: (templates) => DropdownButtonFormField<int>(
                   initialValue: _selectedBhkTemplateId,
                   dropdownColor: theme.cardColor,
                   decoration: const InputDecoration(
                     labelText: 'BHK Type',
                     contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                     border: OutlineInputBorder(),
                   ),
                   items: templates.map((t) => DropdownMenuItem(
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
            
            // Furnishing
            DropdownButtonFormField<String>(
              initialValue: _furnishingStatus,
              dropdownColor: theme.cardColor,
              decoration: const InputDecoration(labelText: 'Furnishing', border: OutlineInputBorder()),
              items: ['Unfurnished', 'Semi-Furnished', 'Fully-Furnished']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s, style: TextStyle(fontSize: 13, color: theme.textTheme.bodyLarge?.color)))).toList(),
              onChanged: (v) => setState(() => _furnishingStatus = v),
            ),
            
            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: Colors.white),
                child: _isSaving 
                   ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                   : const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtitle(ThemeData theme) {
    final parts = [
      if(widget.unit.bhkType != null) widget.unit.bhkType!,
      if(widget.unit.furnishingStatus != null) widget.unit.furnishingStatus!,
      '₹${widget.unit.baseRent.toStringAsFixed(0)}',
    ];
    return Text(parts.join(' • '), style: GoogleFonts.outfit(color: theme.textTheme.bodySmall?.color, fontSize: 13));
  }

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
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
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
