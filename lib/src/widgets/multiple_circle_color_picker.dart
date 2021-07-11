import 'package:flutter/material.dart';
import 'circle_color_picker.dart';

import 'dart:math' as math;

class MultipleCircleColorPicker extends StatelessWidget {
  final List<Color> selectedColors;
  final void Function(int index, Color newColor) onColorChanged;
  final void Function(Color newColor) onAllColorsChanged;

  MultipleCircleColorPicker({
    required this.selectedColors,
    required this.onColorChanged,
    required this.onAllColorsChanged,
  });

  bool _areAllColorsTheSame(List<Color> colors) {
    if (colors.length == 0) return true;
    Color lastColor = colors[0];
    for (var i = 1; i < colors.length; i++) {
      if (lastColor.value != colors[i].value) return false;
    }
    return true;
  }

  Widget _getColorPicker(int index) {
    return CircleColorPicker(
      selectedColor: selectedColors[index],
      onColorChange: (Color newColor) => onColorChanged(index, newColor),
    );
  }

  Widget _buildCenterColorPicker() => Center(
        child: CircleColorPicker(
          selectedColor: _areAllColorsTheSame(selectedColors)
              ? selectedColors.first
              : null,
          onColorChange: onAllColorsChanged,
        ),
      );

  Widget _getCircleElement(int number) {
    assert(number >= 0 && number <= 5);
    return Transform.rotate(
      angle: math.pi / 6 * (number),
      child: SizedBox.expand(
        child: Column(
          children: [
            _getColorPicker(number),
            Spacer(),
            _getColorPicker(6 + number),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: [
          _buildCenterColorPicker(),
          ...List.generate(6, (index) => _getCircleElement(index)),
        ],
      ),
    );
  }
}
