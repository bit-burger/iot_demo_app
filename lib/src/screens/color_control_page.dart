import 'package:flutter/material.dart';
import 'package:iot_app/src/models/led.dart';
import 'package:iot_app/src/models/leds.dart';
import 'package:iot_app/src/providers/led_ring.dart';
import 'package:iot_app/src/widgets/multiple_circle_color_picker.dart';
import 'package:provider/provider.dart';

class ColorControlPage extends StatefulWidget {
  @override
  _ColorControlPageState createState() => _ColorControlPageState();
}

class _ColorControlPageState extends State<ColorControlPage> {
  @override
  Widget build(BuildContext context) {
    final ledRing = context.watch<LedRing>();
    return Stack(
      children: [
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 500),
                child: MultipleCircleColorPicker(
                  selectedColors: ledRing.ledConfiguration.ledValues
                      .map((e) => e.toColor())
                      .toList(growable: false),
                  onColorChanged: (int index, Color newColor) {
                    ledRing.updateLed(index, Led.fromColor(newColor));
                    Navigator.of(context).pop();
                  },
                  onAllColorsChanged: (Color newColor) {
                    ledRing.updateLeds(Leds.all(Led.fromColor(newColor)));
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
