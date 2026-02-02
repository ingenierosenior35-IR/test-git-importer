import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class ScrollPicker extends StatefulWidget {
  final List<int> items;
  final int initialItem;
  final ValueChanged<int> onSelectedItemChanged;
  final double itemHeight;
  final double visibleItemCount;
  final String suffix;

  const ScrollPicker({
    Key? key,
    required this.items,
    required this.initialItem,
    required this.onSelectedItemChanged,
    this.itemHeight = 40.0,
    this.visibleItemCount = 5,
    this.suffix = '',
  }) : super(key: key);

  @override
  State<ScrollPicker> createState() => _ScrollPickerState();
}

class _ScrollPickerState extends State<ScrollPicker> {
  late FixedExtentScrollController _scrollController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.items.indexOf(widget.initialItem);
    if (_currentIndex == -1) _currentIndex = 0;
    _scrollController = FixedExtentScrollController(initialItem: _currentIndex);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.itemHeight * widget.visibleItemCount,
      child: Stack(
        children: [
          // Center highlight
          Center(
            child: Container(
              height: widget.itemHeight,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
          ),
          // List wheel
          ListWheelScrollView.useDelegate(
            controller: _scrollController,
            itemExtent: widget.itemHeight,
            physics: const FixedExtentScrollPhysics(),
            diameterRatio: 1.5,
            perspective: 0.003,
            onSelectedItemChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              widget.onSelectedItemChanged(widget.items[index]);
            },
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: widget.items.length,
              builder: (context, index) {
                final isSelected = index == _currentIndex;
                return Center(
                  child: Text(
                    '${widget.items[index]}${widget.suffix}',
                    style: TextStyle(
                      fontSize: isSelected ? 28 : 18,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected 
                          ? AppColors.primary 
                          : Colors.white.withOpacity(0.5),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
