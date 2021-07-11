import 'package:flutter/material.dart';

import 'multiple_circle_color_picker.dart';

// TODO: Buttons to do extra things, like turn one to left
class CircleColorPickerModalSheet extends StatefulWidget {
  CircleColorPickerModalSheet({
    required this.initialColorValues,
    required this.initialTime,
    required this.onChangedColors,
    required this.bottomPadding,
  });

  final List<Color> initialColorValues;
  final double initialTime;
  final void Function(int?, Color) onChangedColors;
  final double bottomPadding;

  @override
  _CircleColorPickerModalSheetState createState() =>
      _CircleColorPickerModalSheetState();
}

class _CircleColorPickerModalSheetState
    extends State<CircleColorPickerModalSheet>
    with SingleTickerProviderStateMixin {
  late List<Color> _colorValues;
  late double _time;

  @override
  void initState() {
    _colorValues =
        widget.initialColorValues.map((color) => Color(color.value)).toList();
    _time = widget.initialTime;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ),
        Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 5, top: 24),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(() {
                          final timeAsString = _time.toString();
                          return 'Frame time for new frames: ' +
                              timeAsString +
                              (_time.toString().length == 3 ? '0' : '') +
                              ' seconds';
                        }()),
                      ),
                    ),
                    Slider.adaptive(
                      min: 0.01,
                      max: 10,
                      value: _time,
                      onChanged: (v) {
                        setState(() {
                          _time = ((v * 100).toInt() / 100).toDouble();
                        });
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(32)
                    .copyWith(top: 16)
                    .add(EdgeInsets.only(bottom: widget.bottomPadding)),
                child: MultipleCircleColorPicker(
                  selectedColors: _colorValues,
                  onAllColorsChanged: (newColor) {
                    setState(() {
                      _colorValues =
                          List<Color>.generate(12, (index) => newColor);
                      widget.onChangedColors(null, newColor);
                      Navigator.of(context).pop();
                    });
                  },
                  onColorChanged: (int index, Color newColor) {
                    setState(() {
                      _colorValues[index] = newColor;
                      widget.onChangedColors(index, newColor);
                      Navigator.of(context).pop();
                    });
                  },
                ),
              ),
            ],
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 8.0,
              ),
            ],
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
