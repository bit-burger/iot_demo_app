import 'package:flutter/material.dart';

import 'multiple_circle_color_picker.dart';

class CircleColorPickerModalSheet extends StatefulWidget {
  CircleColorPickerModalSheet({
    required this.onChangedColors,
    required this.dismiss,
    required this.initialColorValues,
  });

  final void Function(int?, Color) onChangedColors;
  final void Function() dismiss;
  final List<Color> initialColorValues;

  @override
  _CircleColorPickerModalSheetState createState() =>
      _CircleColorPickerModalSheetState();
}

class _CircleColorPickerModalSheetState
    extends State<CircleColorPickerModalSheet> {
  late List<Color> colorValues;

  @override
  void initState() {
    colorValues =
        widget.initialColorValues.map((color) => Color(color.value)).toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: widget.dismiss,
          ),
        ),
        Container(
          height: 400,
          child: SafeArea(
            top: false,
            child: MultipleCircleColorPicker(
              selectedColors: colorValues,
              onAllColorsChanged: (newColor) {
                setState(() {
                  colorValues = List<Color>.generate(12, (index) => newColor);
                  widget.onChangedColors(null, newColor);
                  Navigator.of(context).pop();
                });
              },
              onColorChanged: (int index, Color newColor) {
                setState(() {
                  colorValues[index] = newColor;
                  widget.onChangedColors(index, newColor);
                  Navigator.of(context).pop();
                });
              },
            ),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
        ),
      ],
    );
  }
}
