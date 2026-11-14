import 'package:flutter/material.dart';

/// Kinds of campus issues a student can report. `id` is what Firestore stores.
enum IncidentCategory {
  facilities('facilities', 'Facilities', Icons.apartment_rounded),
  water('water', 'Water', Icons.water_drop_rounded),
  electricity('electricity', 'Electricity', Icons.bolt_rounded),
  furniture('furniture', 'Furniture', Icons.chair_rounded),
  sanitation('sanitation', 'Sanitation', Icons.delete_outline_rounded),
  safety('safety', 'Safety', Icons.shield_outlined);

  const IncidentCategory(this.id, this.label, this.icon);

  final String id;
  final String label;
  final IconData icon;

  static IncidentCategory fromId(String? id) {
    for (final category in values) {
      if (category.id == id) return category;
    }
    return IncidentCategory.facilities;
  }
}
