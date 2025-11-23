import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dashboard_filter_button.dart';
import 'dashboard_stat_tile.dart';

class DashboardHeader extends StatelessWidget {
  final String selectedFilter;
  final DateTimeRange? selectedDateRange;
  final VoidCallback onSelectDateRange;
  final ValueChanged<String> onFilterChange;

  const DashboardHeader({
    super.key,
    required this.selectedFilter,
    required this.selectedDateRange,
    required this.onSelectDateRange,
    required this.onFilterChange,
  });

  static const Color kGreenColor = Color(0xFF22C922);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                DashboardFilterButton(
                  label: "Today",
                  selectedLabel: selectedFilter,
                  onTap: () => onFilterChange("Today"),
                ),
                DashboardFilterButton(
                  label: "Yesterday",
                  selectedLabel: selectedFilter,
                  onTap: () => onFilterChange("Yesterday"),
                ),
                DashboardFilterButton(
                  label: "Last 7 Days",
                  selectedLabel: selectedFilter,
                  onTap: () => onFilterChange("Last 7 Days"),
                ),
                IconButton(
                  onPressed: onSelectDateRange,
                  icon: const Icon(Icons.filter_alt_outlined),
                  tooltip: "Custom Date Range",
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                DashboardStatTile(title: "Sales", value: "Rs. 12450"),
                DashboardStatTile(title: "Orders", value: "7"),
                DashboardStatTile(title: "Products", value: "23"),
              ],
            ),

            if (selectedDateRange != null) ...[
              const SizedBox(height: 10),
              Text(
                "From ${DateFormat('dd/MM/yyyy').format(selectedDateRange!.start)} "
                "to ${DateFormat('dd/MM/yyyy').format(selectedDateRange!.end)}",
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
