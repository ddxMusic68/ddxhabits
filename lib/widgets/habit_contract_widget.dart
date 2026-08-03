import 'package:flutter/material.dart';
import '../models/habit_contract.dart';
import '../utils/constants.dart';

class HabitContractWidget extends StatelessWidget {
  final HabitContract contract;

  const HabitContractWidget({
    super.key,
    required this.contract,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.description, color: AppColors.mintDark, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    contract.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              icon: Icons.schedule,
              label: 'Time',
              value: contract.time,
              onSurface: onSurface,
            ),
            _buildDetailRow(
              icon: Icons.place,
              label: 'Place',
              value: contract.place,
              onSurface: onSurface,
            ),
            _buildDetailRow(
              icon: Icons.warning_amber,
              label: 'Consequence',
              value: contract.consequence,
              onSurface: onSurface,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color onSurface,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.mintDark),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? '—' : value,
                  style: TextStyle(
                    fontSize: 16,
                    color: onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
