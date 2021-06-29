import 'package:flutter/material.dart';
import 'package:iot_app/src/widgets/circle_color_picker.dart';

class ColorListTile extends StatelessWidget {
  static const widthOfCircleToMaxRowWidth = (1 / 11) / (59 / 44);
  static const widthOfSpaceToMaxRowWidth = widthOfCircleToMaxRowWidth / 4;

  ColorListTile({
    required this.onPressed,
    required this.selectedColors,
    required this.onChangedColors,
    required this.firstTrailing,
    required this.secondTrailing,
  });

  final void Function() onPressed;
  final List<Color> selectedColors;
  final void Function(int?, Color) onChangedColors;
  final Widget firstTrailing;
  final Widget secondTrailing;

  List<Widget> _buildColorRow({required double maxWidth}) {
    final widthOfCircle = widthOfCircleToMaxRowWidth * maxWidth;
    final widthOfSpace = widthOfSpaceToMaxRowWidth * maxWidth;
    final widgetList = <Widget>[];
    for (var i = 0; i < 12; i++) {
      widgetList.add(
        CircleColorPicker(
          size: widthOfCircle,
          selectedColor: selectedColors[i],
        ),
      );
      if (i != 11)
        widgetList.add(
          SizedBox(
            width: widthOfSpace,
          ),
        );
    }
    return widgetList;
  }

  @override
  Widget build(BuildContext context) {
    final space = MediaQuery.of(context).size.width - 16 - 16 - 24 - 24;
    final widthOfCells = space / 12;
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.all(Colors.black12),
      ),
      child: SizedBox(
        height: widthOfCells,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (_, constraints) {
                    return Row(
                      children: [
                        SizedBox(width: 16),
                        ..._buildColorRow(maxWidth: constraints.minWidth - 16),
                      ],
                    );
                  },
                ),
              ),
              secondTrailing,
              firstTrailing,
              SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }
}
