import 'package:flutter/material.dart';

/// Time range filter widget for dashboard statistics
class TimeRangeFilter extends StatefulWidget {
  final int selectedDays;
  final ValueChanged<int> onChanged;

  const TimeRangeFilter({
    super.key,
    required this.selectedDays,
    required this.onChanged,
  });

  @override
  State<TimeRangeFilter> createState() => _TimeRangeFilterState();
}

class _TimeRangeFilterState extends State<TimeRangeFilter> {
  late int _selectedDays;

  @override
  void initState() {
    super.initState();
    _selectedDays = widget.selectedDays;
  }

  @override
  Widget build(BuildContext context) {
    final filters = [
      {'label': '7 jours', 'value': 7},
      {'label': '30 jours', 'value': 30},
      {'label': '90 jours', 'value': 90},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text(
            'Période:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 12),
          ...filters.map((filter) {
            final value = filter['value'] as int;
            final label = filter['label'] as String;
            final isSelected = _selectedDays == value;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FilterChip(
                label: Text(label),
                selected: isSelected,
                onSelected: (_) {
                  setState(() => _selectedDays = value);
                  widget.onChanged(value);
                },
                backgroundColor: Colors.grey[200],
                selectedColor: Colors.blue.withValues(alpha: 0.7),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 11,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
