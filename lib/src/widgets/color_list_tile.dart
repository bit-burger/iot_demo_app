import 'package:flutter/material.dart';
import 'package:iot_app/src/widgets/circle_color_picker.dart';
import 'circle_color_picker_modal_sheet.dart';

class ColorListTile extends StatefulWidget {
  ColorListTile({
    required this.selectedColors,
    required this.onChangedColors,
    required this.firstTrailing,
    required this.secondTrailing,
  });

  final List<Color> selectedColors;
  final void Function(int?, Color) onChangedColors;
  final Widget firstTrailing;
  final Widget secondTrailing;

  @override
  _ColorListTileState createState() => _ColorListTileState();
}

class _ColorListTileState extends State<ColorListTile> {
  static const widthOfCircleToMaxRowWidth = (1 / 11) / (59 / 44);
  static const widthOfSpaceToMaxRowWidth = widthOfCircleToMaxRowWidth / 4;

  bool selected = false;

  List<Widget> _buildColorRow({required double maxWidth}) {
    final widthOfCircle = widthOfCircleToMaxRowWidth * maxWidth;
    final widthOfSpace = widthOfSpaceToMaxRowWidth * maxWidth;
    final widgetList = <Widget>[];
    for (var i = 0; i < 12; i++) {
      widgetList.add(
        CircleColorPicker(
          size: widthOfCircle,
          selectedColor: widget.selectedColors[i],
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

  _beginTap() {
    print('Begin tap');

    setState(() {
      selected = true;
    });
    Scaffold.of(context).showBodyScrim(true, 0.2);
    Scaffold.of(context).showBottomSheet(
      (context) => CircleColorPickerModalSheet(
        initialColorValues: widget.selectedColors,
        dismiss: _endTap,
        onChangedColors: widget.onChangedColors,
      ),
      backgroundColor: Colors.transparent,
    );
  }

  _endTap() {
    Scaffold.of(context).showBodyScrim(false, 0);
    Navigator.of(context).pop();

    setState(() {
      selected = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final space = MediaQuery.of(context).size.width - 16 - 16 - 24 - 24;
    final widthOfCells = space / 12;
    return SizedBox(
      height: widthOfCells + 24,
      child: Stack(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeOutQuart,
            color: selected ? Colors.black12 : Colors.transparent,
          ),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (_, constraints) {
                      return Row(
                        children: [
                          SizedBox(width: 16),
                          ..._buildColorRow(
                              maxWidth: constraints.minWidth - 16),
                        ],
                      );
                    },
                  ),
                ),
                widget.secondTrailing,
                widget.firstTrailing,
                SizedBox(width: 16),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 16, right: 64),
            child: GestureDetector(
              onTap: _beginTap,
              onTapCancel: _endTap,
            ),
          ),
        ],
      ),
    );
  }
}
