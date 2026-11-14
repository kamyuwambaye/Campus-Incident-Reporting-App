import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Horizontally scrolling single-select chips ("All", "Submitted", ...).
class FilterChipRow<T> extends StatelessWidget {
  const FilterChipRow({
    super.key,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
    this.allLabel = 'All',
    this.horizontalPadding = 20,
  });

  final List<T> options;
  final T? selected;
  final String Function(T option) labelOf;
  final ValueChanged<T?> onSelected;
  final String allLabel;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final entries = <MapEntry<T?, String>>[
      MapEntry(null, allLabel),
      for (final option in options) MapEntry(option, labelOf(option)),
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        itemCount: entries.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final entry = entries[index];
          final isSelected = entry.key == selected;
          return ChoiceChip(
            label: Text(entry.value),
            selected: isSelected,
            showCheckmark: false,
            onSelected: (_) => onSelected(entry.key),
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.surface,
            side: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          );
        },
      ),
    );
  }
}
