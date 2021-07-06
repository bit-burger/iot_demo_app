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
    return Consumer<LedRing>(
      builder: (context, ledsModel, _) {
        return Stack(
          children: [
            SafeArea(
              child: Center(
                child: MultipleCircleColorPicker(
                  selectedColors: ledsModel.ledConfiguration.ledValues
                      .map((e) => e.toColor())
                      .toList(growable: false),
                  onColorChanged: (int index, Color newColor) {
                    ledsModel.updateLed(index, Led.fromColor(newColor));
                    Navigator.of(context).pop();
                  },
                  onAllColorsChanged: (Color newColor) {
                    ledsModel.updateLeds(Leds.all(Led.fromColor(newColor)));
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
