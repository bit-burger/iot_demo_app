import 'package:flutter/material.dart';
import 'package:iot_app/src/providers/led_ring.dart';
import 'package:provider/provider.dart';
import 'package:iot_app/src/models/led_state.dart';

class LedControlPage extends StatefulWidget {
  @override
  _LedControlPageState createState() => _LedControlPageState();
}

class _LedControlPageState extends State<LedControlPage> {
  Widget _buildLowerWidget(BuildContext context, LedRing ledRing) {
    if (!ledRing.isActive) return CircularProgressIndicator();
    return Switch.adaptive(
      value: ledRing.state == LedState.on,
      onChanged: (v) {
        final ledsModel = Provider.of<LedRing>(context, listen: false);
        if (v) {
          return ledsModel.turnOn();
        }
        ledsModel.turnOff();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(60),
          child: Consumer<LedRing>(
            builder: (context, ledRing, _) {
              final state = ledRing.state;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(state.description()),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: _buildLowerWidget(context, ledRing),
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
