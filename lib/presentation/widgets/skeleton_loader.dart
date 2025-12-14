import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final ShapeBorder shapeBorder;

  const ShimmerLoading.rectangular({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.shapeBorder = const RoundedRectangleBorder(),
  });

  const ShimmerLoading.circular({
    super.key,
    required this.width,
    required this.height,
    this.shapeBorder = const CircleBorder(),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      period: const Duration(seconds: 2),
      child: Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(
          color: isDark ? Colors.grey[700]! : Colors.grey[400]!,
          shape: shapeBorder,
        ),
      ),
    );
  }
}

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: isDark ? Border.all(color: Colors.white12) : Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
             const ShimmerLoading.circular(width: 50, height: 50),
             const SizedBox(width: 16),
             Expanded(
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   const ShimmerLoading.rectangular(height: 16),
                   const SizedBox(height: 8),
                   ShimmerLoading.rectangular(height: 14, width: 150),
                 ],
               ),
             )
          ],
        ),
      ),
    );
  }
}

class ReportsSkeleton extends StatelessWidget {
  const ReportsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Financial Card
          const ShimmerLoading.rectangular(height: 200, width: double.infinity, shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24)))),
          const SizedBox(height: 24),
          // Expenses Row
          Row(
            children: [
              Expanded(child: const ShimmerLoading.rectangular(height: 100, shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))))),
              const SizedBox(width: 16),
              Expanded(child: const ShimmerLoading.rectangular(height: 100, shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))))),
            ],
          ),
          const SizedBox(height: 32),
          // Chart Title
          const ShimmerLoading.rectangular(height: 24, width: 200),
          const SizedBox(height: 16),
          // Chart
          const ShimmerLoading.rectangular(height: 300, width: double.infinity, shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24)))),
        ],
      ),
    );
  }
}
