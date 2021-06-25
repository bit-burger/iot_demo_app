import 'package:flutter/material.dart';
import 'circle_color_picker.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'circle_widget_layout.dart';

class MultipleCircleColorPicker extends StatelessWidget {
  final List<Color> selectedColors;
  final void Function(int index, Color newColor) onColorChanged;
  final void Function(Color newColor) onAllColorsChanged;
  final int radius;
  final int pickerSize;

  MultipleCircleColorPicker({
    required this.selectedColors,
    required this.onColorChanged,
    required this.onAllColorsChanged,
    this.radius = 105,
    this.pickerSize = 105,
  });

  Widget _getColorPicker(BuildContext context, int index) {
    return CircleColorPicker(
      selectedColor: selectedColors[index],
      onColorChange: (Color newColor) => onColorChanged(index, newColor),

    );
  }

  @override
  Widget build(BuildContext context) {
    return CircleFloatingButton.completeCircle(
      radius: 105,
      child: CircleColorPicker(
        selectedColor: selectedColors.allSame() ? selectedColors.first : null,
        onColorChange: onAllColorsChanged,
      ),
      items: List.generate(12, (index) => _getColorPicker(context, index))
          .reversed
          .toList(),
    );
  }
}

extension on List<Color> {
  bool allSame() {
    if (this.length == 0) return true;
    Color lastColor = this[0];
    for (var i = 1; i < this.length; i++) {
      if (lastColor.value != this[i].value) return false;
    }
    return true;
  }
}
