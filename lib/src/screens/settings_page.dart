import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iot_app/src/models/led_state.dart';
import 'package:iot_app/src/providers/led_ring.dart';
import 'package:iot_app/src/providers/preferences.dart';
import 'package:provider/provider.dart';
import 'package:iot_app/constants.dart' show urlRegex;

class SettingsPage extends StatefulWidget {
  SettingsPage();

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage> {
  // of the TextField.
  late final TextEditingController _textController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    _textController = TextEditingController(
      text: context.read<Preferences>().url,
    );
    _focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  saveNewSettings([String? url]) {
    if (url == null) {
      _focusNode.unfocus();
      url = _textController.text;
    }
    if (url.isEmpty || !urlRegex.hasMatch(url)) {
      setState(() {});
    } else {
      setState(() {
        context.read<Preferences>().url = url!;
      });
      context.read<LedRing>().refresh();
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "Saved: " + url!,
              style: Theme.of(context).textTheme.headline6,
            ),
            content: Text(
              "The app will now fetch the new data from the new destination",
            ),
          );
        },
      );
    }
  }

  Widget _buildConnectionStatus(LedState ledState) {
    switch (ledState) {
      case LedState.loading:
        return CircularProgressIndicator();
      default:
        return Text.rich(
          TextSpan(
            text: 'Connection Status: ',
            children: [
              TextSpan(
                text: ledState != LedState.error ? 'Connected' : 'Errored',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          style: TextStyle(
            color: ledState != LedState.error ? Colors.blueAccent : Colors.red,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              focusNode: _focusNode,
              controller: _textController,
              onSubmitted: saveNewSettings,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                errorText: _textController.text.isEmpty
                    ? 'Please enter a url'
                    : !urlRegex.hasMatch(_textController.text)
                        ? 'Not a valid url'
                        : null,
                hintText: 'http://url-for-microcontroller',
              ),
            ),
            SizedBox(height: 20),
            TextButton(
              // When the user presses the button, show an alert dialog containing
              // the text that the user has entered into the text field.
              onPressed: saveNewSettings,
              child: Text(
                'Save settings',
                style: Theme.of(context).primaryTextTheme.button,
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue),
              ),
            ),
            SizedBox(height: 20),
            Consumer<LedRing>(
              builder: (_, ledRing, __) =>
                  _buildConnectionStatus(ledRing.ledState),
            ),
          ],
        ),
      ),
    );
  }
}
