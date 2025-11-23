import 'package:flutter/material.dart';

class DashboardFilterButton extends StatelessWidget {
  final String label;
  final String selectedLabel;
  final VoidCallback onTap;
  final Color activeColor;

  const DashboardFilterButton({
    super.key,
    required this.label,
    required this.selectedLabel,
    required this.onTap,
    this.activeColor =Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = selectedLabel == label;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
