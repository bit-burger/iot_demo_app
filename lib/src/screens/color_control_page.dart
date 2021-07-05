import 'package:flutter/material.dart';
import 'package:iot_app/src/models/led.dart';
import 'package:iot_app/src/models/leds.dart';
import 'package:iot_app/src/providers/led_ring.dart';
import 'package:iot_app/src/widgets/multiple_circle_color_picker.dart';
import 'package:provider/provider.dart';
import 'package:iot_app/src/models/led_state.dart';

class ColorControlPage extends StatefulWidget {
  @override
  _ColorControlPageState createState() => _ColorControlPageState();
}

class _ColorControlPageState extends State<ColorControlPage> {
  Widget _buildFrontWidget(BuildContext context, LedState ledState) {
    switch (ledState) {
      case LedState.off:
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: 15),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Theme.of(context).primaryColor),
                ),
                onPressed: () {
                  Provider.of<LedRing>(context, listen: false).turnOn();
                },
                child: Text(
                  'Turn back on',
                  style: Theme.of(context).primaryTextTheme.button,
                ),
              ),
            ),
          ),
        );
      case LedState.loading:
        return Center(child: CircularProgressIndicator());
      case LedState.error:
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: 15),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Theme.of(context).errorColor),
                ),
                onPressed: () {
                  Provider.of<LedRing>(context, listen: false).refresh();
                },
                child: Text(
                  'Error occurred, press to retry',
                  style: Theme.of(context).primaryTextTheme.button,
                ),
              ),
            ),
          ),
        );
      default:
        throw Error();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LedRing>(
      builder: (context, ledsModel, _) {
        final ledState = ledsModel.ledState;
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
            if (ledState != LedState.on) ...[
              ModalBarrier(
                color: Colors.black54,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: _buildFrontWidget(context, ledState),
              ),
            ],
          ],
        );
      },
    );
  }
}
