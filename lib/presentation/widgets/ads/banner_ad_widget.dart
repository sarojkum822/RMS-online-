import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../core/services/ad_service.dart';

class BannerAdWidget extends ConsumerStatefulWidget {
  final AdSize? adSize; // Made nullable to support adaptive default
  const BannerAdWidget({super.key, this.adSize});

  @override
  ConsumerState<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends ConsumerState<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isLoading && !_isAdLoaded) {
      _loadAd();
    }
  }

  Future<void> _loadAd() async {
    _isLoading = true;
    final adService = ref.read(adServiceProvider);
    
    // Calculate adaptive size if no specific size is provided
    AdSize size;
    if (widget.adSize != null) {
      size = widget.adSize!;
    } else {
      // Use full width now as it is placed outside padding
      final width = MediaQuery.of(context).size.width.truncate();
      final adaptiveSize = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
      size = adaptiveSize ?? AdSize.banner;
    }

    _bannerAd = adService.createBannerAd(
      size: size,
      onLoaded: () {
        if (mounted) setState(() => _isAdLoaded = true);
      },
      onFail: (error) {
        if (mounted) setState(() => _isAdLoaded = false);
      }
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || _bannerAd == null) return const SizedBox.shrink();
    
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      width: double.infinity, 
      decoration: BoxDecoration(
         color: theme.cardColor,
         borderRadius: BorderRadius.circular(12),
         boxShadow: isDark ? [] : [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
         ],
         border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
           // Sponsored Label
           Padding(
             padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
             child: Row(
               children: [
                 Icon(Icons.info_outline, size: 10, color: theme.hintColor),
                 const SizedBox(width: 4),
                 Text('Sponsored', style: TextStyle(fontSize: 10, color: theme.hintColor, fontWeight: FontWeight.w500)),
               ],
             ),
           ),
           const Divider(height: 1, thickness: 0.5),
           const SizedBox(height: 12),
           // Ad Content
           Container(
             alignment: Alignment.center,
             height: _bannerAd!.size.height.toDouble(),
             width: _bannerAd!.size.width.toDouble(),
             constraints: BoxConstraints(
               minHeight: _bannerAd!.size.height.toDouble(),
             ),
             child: AdWidget(ad: _bannerAd!),
           ),
           const SizedBox(height: 12),
        ],
      ),
    );
  }
}

