import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'data_providers.dart';

part 'revenue_provider.g.dart';

@Riverpod(keepAlive: true)
Future<List<Map<String, dynamic>>> revenueTrend(RevenueTrendRef ref) async {
  // Fetch last 6 months
  return ref.watch(rentRepositoryProvider).getMonthlyRevenue(6);
}
