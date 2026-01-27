import 'package:flutter/material.dart';

class SportChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const SportChip({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFFCDFF4D) // Yellow/Lime when selected
              : const Color(0xFF2C2C2C), // Dark gray when not selected
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFFCDFF4D) 
                : const Color(0xFF3C3C3C),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.black : Colors.white,
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.black : Colors.white,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
