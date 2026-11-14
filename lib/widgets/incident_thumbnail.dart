import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/incident.dart';

/// Square preview: the attached photo, or the category icon when none.
class IncidentThumbnail extends StatelessWidget {
  const IncidentThumbnail({
    super.key,
    required this.incident,
    this.size = 56,
    this.radius = 12,
  });

  final Incident incident;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      color: AppColors.primaryLight,
      child: Icon(
        incident.category.icon,
        color: AppColors.primary,
        size: size * 0.45,
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: size,
        height: size,
        child: incident.hasPhoto
            ? Image.network(
                incident.photoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => placeholder,
                loadingBuilder: (_, child, progress) =>
                    progress == null ? child : placeholder,
              )
            : placeholder,
      ),
    );
  }
}
