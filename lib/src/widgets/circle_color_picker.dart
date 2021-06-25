import 'package:flutter/material.dart';
import 'package:o_color_picker/o_color_picker.dart';
import 'package:o_popup/o_popup.dart';
import 'dart:math' as math;

class CircleColorPicker extends StatelessWidget {
  final double size;
  final Color? selectedColor;
  final void Function(Color) onColorChange;

  CircleColorPicker({
    this.size = 22,
    this.selectedColor,
    required this.onColorChange,
  });

  _rotatedRedLine() => Transform.rotate(
        angle: -math.pi / 4,
        child: Transform.scale(
          scale: 3,
          child: Divider(
            color: Colors.red,
            thickness: 1 / 3,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: OPopupTrigger(
        barrierAnimationDuration: Duration(milliseconds: 400),
        triggerWidget: Container(
          padding: EdgeInsets.all(10.0),
          child: SizedBox(
            height: size,
            width: size,
            child: selectedColor == null ? _rotatedRedLine() : null,
          ),
          decoration: BoxDecoration(
            color: selectedColor,
            border: selectedColor == null ||
                    selectedColor!.computeLuminance() > 0.95
                ? Border.all(color: Color(0xff969696), width: 1)
                : null,
            borderRadius: BorderRadius.all(Radius.circular(22)),
          ),
        ),
        popupContent: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            OColorPicker(
              selectedColor: selectedColor,
              colors: primaryColorsPalette,
              onColorChange: onColorChange,
            ),
          ],
        ),
      ),
    );
  }
}
