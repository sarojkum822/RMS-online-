import 'package:intl/intl.dart';

class ReportRange {
  final DateTime start;
  final DateTime end;
  final String label;

  ReportRange({
    required this.start,
    required this.end,
    required this.label,
  });

  factory ReportRange.thisMonth() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return ReportRange(
      start: firstDay,
      end: lastDay,
      label: DateFormat('MMMM yyyy').format(now),
    );
  }

  factory ReportRange.lastMonth() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month - 1, 1);
    final lastDay = DateTime(now.year, now.month, 0, 23, 59, 59);
    return ReportRange(
      start: firstDay,
      end: lastDay,
      label: DateFormat('MMMM yyyy').format(firstDay),
    );
  }

  factory ReportRange.last3Months() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month - 2, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0, 23, 59, 59); // End of current month
    return ReportRange(
      start: firstDay,
      end: lastDay,
      label: 'Last 3 Months',
    );
  }

  factory ReportRange.last6Months() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month - 5, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return ReportRange(
      start: firstDay,
      end: lastDay,
      label: 'Last 6 Months',
    );
  }

  factory ReportRange.custom(DateTime start, DateTime end) {
    if (start.year == end.year && start.month == end.month) {
       return ReportRange(
         start: start,
         end: end,
         label: DateFormat('MMMM yyyy').format(start),
       );
    }
    return ReportRange(
      start: start,
      end: end,
      label: '${DateFormat('MMM dd').format(start)} - ${DateFormat('MMM dd, yyyy').format(end)}',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportRange &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}
