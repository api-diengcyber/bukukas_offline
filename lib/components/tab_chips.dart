import 'package:flutter/material.dart';

// ignore: must_be_immutable
class TabChips extends StatefulWidget {
  TabChips({
    super.key,
    this.elevation = 1,
    required this.activeColor,
    required this.activeTextColor,
    this.backgroundColor,
    this.initialIndex,
    this.enabled = true,
    required this.data,
    this.onTap,
  });

  double elevation;
  final Color activeColor;
  final Color activeTextColor;
  Color? backgroundColor;
  bool enabled;
  final List<Map<String, dynamic>> data;
  int? initialIndex;
  Function? onTap;

  @override
  State<StatefulWidget> createState() => _TabChipsState();
}

class _TabChipsState extends State<TabChips> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialIndex != null) {
      setState(() {
        _selectedIndex = widget.initialIndex!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(
        widget.data.length,
        (index) {
          return Container(
            margin: const EdgeInsets.only(right: 3),
            child: ChoiceChip(
              elevation: widget.elevation,
              avatar: widget.data[index]['avatar'],
              selected: _selectedIndex == index,
              label: Text(
                "${widget.data[index]['name']}",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: _selectedIndex == index
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: _selectedIndex == index
                      ? widget.activeTextColor
                      : Colors.black54,
                ),
              ),
              backgroundColor: widget.backgroundColor ?? Colors.grey.shade300,
              selectedColor: widget.activeColor,
              disabledColor: Colors.grey.shade200,
              onSelected: widget.enabled
                  ? (selected) {
                      if (selected) {
                        setState(() {
                          _selectedIndex = index;
                        });
                        widget.onTap!(widget.data[index], index);
                      }
                    }
                  : null,
            ),
          );
        },
      ),
    );
  }
}
