import 'package:flutter/material.dart';
import '../../domain/entities/maintenance_request.dart';

extension MaintenanceStatusExtensions on MaintenanceStatus {
  Color get color {
    switch (this) {
      case MaintenanceStatus.pending:
        return Colors.orange;
      case MaintenanceStatus.inProgress:
        return Colors.blue;
      case MaintenanceStatus.completed:
        return Colors.green;
      case MaintenanceStatus.rejected:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case MaintenanceStatus.pending:
        return Icons.pending_actions_rounded;
      case MaintenanceStatus.inProgress:
        return Icons.engineering_rounded;
      case MaintenanceStatus.completed:
        return Icons.check_circle_rounded;
      case MaintenanceStatus.rejected:
        return Icons.cancel_rounded;
    }
  }

  String get label {
    switch (this) {
      case MaintenanceStatus.pending:
        return 'Pending';
      case MaintenanceStatus.inProgress:
        return 'In Progress';
      case MaintenanceStatus.completed:
        return 'Completed';
      case MaintenanceStatus.rejected:
        return 'Rejected';
    }
  }

  String get description {
    switch (this) {
      case MaintenanceStatus.pending:
        return 'Your request has been received and is waiting for review.';
      case MaintenanceStatus.inProgress:
        return 'A technician or contractor has been assigned to fix this.';
      case MaintenanceStatus.completed:
        return 'This issue has been successfully resolved.';
      case MaintenanceStatus.rejected:
        return 'This request could not be fulfilled at this time.';
    }
  }
}

extension MaintenanceCategoryExtensions on String {
  IconData get maintenanceCategoryIcon {
    final cat = toLowerCase();
    if (cat.contains('plumb')) return Icons.water_drop_rounded;
    if (cat.contains('electr')) return Icons.electric_bolt_rounded;
    if (cat.contains('appliance')) return Icons.kitchen_rounded;
    if (cat.contains('carpentry')) return Icons.chair_rounded;
    if (cat.contains('cleaning')) return Icons.cleaning_services_rounded;
    if (cat.contains('paint')) return Icons.format_paint_rounded;
    return Icons.build_rounded;
  }
}
