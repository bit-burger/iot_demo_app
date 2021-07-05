import 'package:flutter/material.dart';
import 'package:iot_app/src/providers/led_ring.dart';
import 'package:provider/provider.dart';
import 'package:iot_app/src/models/led_state.dart';

class LedControlPage extends StatefulWidget {
  @override
  _LedControlPageState createState() => _LedControlPageState();
}

class _LedControlPageState extends State<LedControlPage> {
  _buildLowerWidget(BuildContext context, LedState ledState) {
    switch (ledState) {
      case LedState.on:
      case LedState.off:
        return Switch.adaptive(
          value: ledState == LedState.on,
          onChanged: (v) {
            final ledsModel = Provider.of<LedRing>(context, listen: false);
            if (v) {
              return ledsModel.turnOn();
            }
            ledsModel.turnOff();
          },
        );
      case LedState.loading:
        return CircularProgressIndicator();
      case LedState.error:
        return TextButton(
          style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all(Theme.of(context).errorColor),
          ),
          onPressed: () {
            Provider.of<LedRing>(context, listen: false).refresh();
          },
          child: Text(
            'Retry',
            style: Theme.of(context).primaryTextTheme.button,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(60),
          child: Consumer<LedRing>(
            builder: (context, ledsModel, _) {
              final state = ledsModel.ledState;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(state.toStringLong()),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: _buildLowerWidget(context, ledsModel.ledState),
                    ),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
