// @dart=2.8
import 'package:flutter/material.dart';
import 'package:iot_app/src/models/led.dart';
import 'package:iot_app/src/models/leds.dart';
import 'package:iot_app/src/models/leds_model.dart';
import 'package:iot_app/src/widgets/circle_widget.dart';
import 'package:iot_app/src/widgets/circle_widget_layout.dart';
import 'package:provider/provider.dart';
import 'package:iot_app/src/models/led_state.dart';

class SingleColorControlPage extends StatefulWidget {
  @override
  _SingleColorControlPageState createState() => _SingleColorControlPageState();
}

class _SingleColorControlPageState extends State<SingleColorControlPage> {
  Widget _buildFrontWidget(BuildContext context, LedState ledState) {
    switch (ledState) {
      case LedState.off:
        return Align(
          alignment: Alignment.bottomCenter,
          child: TextButton(
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all(Theme.of(context).primaryColor),
            ),
            onPressed: () {
              Provider.of<LedsModel>(context, listen: false).turnOn();
            },
            child: Text(
              'Turn back on',
              style: Theme.of(context).primaryTextTheme.button,
            ),
          ),
        );
      case LedState.loading:
        return CircularProgressIndicator();
      case LedState.error:
        return Align(
          alignment: Alignment.bottomCenter,
          child: TextButton(
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all(Theme.of(context).errorColor),
            ),
            onPressed: () {
              Provider.of<LedsModel>(context, listen: false).refreshData();
            },
            child: Text(
              'Retry',
              style: Theme.of(context).primaryTextTheme.button,
            ),
          ),
        );
      default:
        throw Error();
    }
  }

  Widget _getColorPicker(BuildContext context, int index, LedsModel ledsModel) {
    final led = ledsModel.ledConfiguration.ledValues[index];
    return CircleWidget(
      selectedColor: led.toColor(),
      onColorChange: (color) {
        setState(() {
          ledsModel.updateLed(index, Led.fromColor(color));
        });
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LedsModel>(
      builder: (context, ledsModel, _) {
        final ledState = ledsModel.ledState;
        return Stack(
          children: [
            if (ledsModel.ledConfiguration != null)
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(60),
                  child: Center(
                    child: CircleFloatingButton.completeCircle(
                      radius: 105,
                      child: CircleWidget(
                        selectedColor: ledsModel.ledConfiguration.allSameValue
                            ? ledsModel.ledConfiguration.ledValues.first
                                .toColor()
                            : null,
                        onColorChange: (Color color) {
                          ledsModel.updateLeds(Leds.all(Led.fromColor(color)));
                        },
                      ),
                      items: List.generate(
                          12,
                          (index) =>
                              _getColorPicker(context, index, ledsModel)),
                    ),
                  ),
                ),
              ),
            if (ledState != LedState.on) ...[
              ModalBarrier(
                color: Colors.black54,
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: _buildFrontWidget(context, ledState),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
