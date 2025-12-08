import 'package:flutter/material.dart';

class RestaurantStatusFilter extends StatefulWidget {
  final String selectedStatus;
  final Function(String) onStatusChanged;

  const RestaurantStatusFilter({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  @override
  State<RestaurantStatusFilter> createState() => _RestaurantStatusFilterState();
}

class _RestaurantStatusFilterState extends State<RestaurantStatusFilter> {
  final List<String> _statusOptions = ['All', 'Open', 'Closed'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _statusOptions.map((status) {
          final isSelected = widget.selectedStatus == status;
          return GestureDetector(
            onTap: () {
              widget.onStatusChanged(status);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF37B6AF)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}