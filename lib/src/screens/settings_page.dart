import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iot_app/src/models/leds_model.dart';
import 'package:provider/provider.dart';
import 'package:iot_app/constants.dart' show urlRegex;

class SettingsPage extends StatefulWidget {
  SettingsPage();

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage> {
  // of the TextField.
  late final TextEditingController textController;

  @override
  void initState() {
    textController = TextEditingController(
      text: Provider.of<LedsModel>(context, listen: false).url,
    );
    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  saveNewSettings([String? url]) {
    if (url == null) url = textController.text;
    if (url.isEmpty ||
        !urlRegex.hasMatch(url)) {
      setState(() {});
    } else {
      Provider.of<LedsModel>(context, listen: false).changeUrl(url);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            // Retrieve the text the that user has entered by using the
            // TextEditingController.
            title: Text(
              "Saved: " + url!,
              style: Theme.of(context).textTheme.headline6,
            ),
            content: Text(
              "To view the changes, "
              "press on the refresh button",
            ),
          );
        },
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
              textInputAction: TextInputAction.done,
              controller: textController,
              onSubmitted: saveNewSettings,
              decoration: InputDecoration(
                errorText: textController.text.isEmpty
                    ? 'Please enter a url'
                    : !urlRegex.hasMatch(textController.text)
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
              child: Text('Save settings'),
            ),
          ],
        ),
      ),
    );
  }
}
