import 'package:flutter/material.dart';
import 'package:iot_app/src/models/led_state.dart';
import 'package:iot_app/src/providers/floating_action_button_events.dart';
import 'package:iot_app/src/providers/tab_view_index.dart';
import 'package:iot_app/src/providers/led_ring.dart';
import 'package:iot_app/src/screens/animation_control_page.dart';
import 'package:provider/provider.dart';
import 'color_control_page.dart';
import 'sensors_page.dart';
import 'settings_page.dart';
import 'led_control_page.dart';

class TabbedHomePage extends StatefulWidget {
  TabbedHomePage();

  @override
  _TabbedHomePageState createState() => _TabbedHomePageState();
}

class _TabbedHomePageState extends State<TabbedHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<IconData?> tabIconList = [
    null,
    null,
    Icons.play_arrow,
    Icons.refresh,
    null,
  ];

  List<bool> iconShouldBeOverriddenByAnimationStopper = [
    true,
    true,
    true,
    false,
    false,
  ];

  List<Set<LedState>> statesList = [
    {LedState.connectionError, LedState.animating},
    {
      LedState.loading,
      LedState.connectionError,
      LedState.animating,
      LedState.off
    },
    {LedState.animating, LedState.connectionError, LedState.loading},
    {LedState.loading, LedState.connectionError},
    {},
  ];

  Widget _titledAction({
    required String title,
    required Widget action,
  }) =>
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(30),
            child: Text(
              title,
              style: Theme.of(context).primaryTextTheme.button,
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 50),
            child: action,
          ),
        ],
      );

  Widget _coloredButtonAction({
    required String title,
    Color backgroundColor = Colors.blue,
    required void onPressed(),
  }) {
    return OutlinedButton(
      child: Text(
        title,
        style: Theme.of(context).primaryTextTheme.button,
      ),
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(backgroundColor),
      ),
    );
  }

  Widget _modalBarrierContent(LedRing ledRing) {
    switch (ledRing.state) {
      case LedState.off:
        return _titledAction(
          title:
              'The leds are off, press the button below to turn them on again',
          action: _coloredButtonAction(
            title: 'Turn on',
            onPressed: () => ledRing.turnOn(),
          ),
        );
      case LedState.loading:
        return CircularProgressIndicator();
      case LedState.animating:
        return _titledAction(
            title:
                'The leds are animating, press the button below to stop animating',
            action: Wrap(
              spacing: 16,
              children: [
                _coloredButtonAction(
                  title: 'Stop animation',
                  onPressed: () => context
                      .read<FloatingActionButtonEvents>()
                      .floatingActionButtonPressed(),
                  backgroundColor: Colors.blue,
                ),
                _coloredButtonAction(
                  title: 'Retry',
                  onPressed: () => ledRing.refresh(),
                  backgroundColor: Colors.red,
                ),
              ],
            ));
      case LedState.connectionError:
        return _titledAction(
          title: 'There was an error connecting with the leds, '
              'press the button below to try again',
          action: _coloredButtonAction(
            title: 'Retry',
            onPressed: () => ledRing.refresh(),
            backgroundColor: Colors.red,
          ),
        );
      default:
        throw Error();
    }
  }

  Iterable<Widget> _modalBarrier(int tabIndex, LedRing ledRing) sync* {
    yield ModalBarrier(
      color: Colors.black.withAlpha(200),
    );
    yield Padding(
      padding: MediaQuery.of(context).padding.add(EdgeInsets.only(bottom: 16)),
      child: Align(
        alignment: ledRing.state != LedState.loading
            ? Alignment.bottomCenter
            : Alignment.center,
        child: _modalBarrierContent(ledRing),
      ),
    );
  }

  Widget _customTabFloatingActionButton(IconData customIcon) {
    return FloatingActionButton(
      onPressed: () => context
          .read<FloatingActionButtonEvents>()
          .floatingActionButtonPressed(),
      backgroundColor: customIcon == Icons.play_arrow ? Colors.green : null,
      child: Icon(
        customIcon,
      ),
    );
  }

  Widget _normalFloatingActionButton(bool isError) {
    return GestureDetector(
      onLongPress: isError ? null : () => context.read<LedRing>().reset(),
      child: FloatingActionButton(
        onPressed: () => context.read<LedRing>().refresh(),
        child: Icon(
          Icons.refresh,
        ),
      ),
    );
  }

  Widget _animationStopFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => context
          .read<FloatingActionButtonEvents>()
          .floatingActionButtonPressed(),
      child: Icon(
        Icons.stop,
      ),
    );
  }

  Widget _floatingActionButton(int tabIndex, LedState ledState) {
    if (ledState == LedState.animating &&
        iconShouldBeOverriddenByAnimationStopper[tabIndex]) {
      return _animationStopFloatingActionButton();
    }

    final customIcon = tabIconList[tabIndex];
    if (customIcon != null) return _customTabFloatingActionButton(customIcon);

    return _normalFloatingActionButton(ledState == LedState.connectionError);
  }

  @override
  Widget build(BuildContext context) {
    final tabIndex = context.watch<TabViewIndex>().index;
    final ledRing = context.watch<LedRing>();

    return Scaffold(
      appBar: AppBar(
        leading: SizedBox(),
        title: const Text('IOT-Control-App'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: 'LEDControl'),
            Tab(text: 'ColorControl'),
            Tab(text: 'AnimationControl'),
            Tab(text: 'Sensors'),
            Tab(text: 'Settings'),
          ],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            physics: NeverScrollableScrollPhysics(),
            children: [
              LedControlPage(),
              ColorControlPage(),
              AnimationControlPage(),
              SensorsPage(),
              SettingsPage(),
            ],
          ),
          if (statesList[tabIndex].contains(ledRing.state))
            ..._modalBarrier(tabIndex, ledRing),
        ],
      ),
      // TODO: Only turn, when really switches (from green to blue, new icon)
      floatingActionButton: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        transitionBuilder: (child, animation) => RotationTransition(
          child: child,
          turns: animation,
        ),
        child: _floatingActionButton(tabIndex, ledRing.state),
      ),
    );
  }

  @override
  void initState() {
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: context.read<TabViewIndex>().index,
    );
    _tabController.addListener(() {
      context.read<TabViewIndex>().index = _tabController.index;
    });
    super.initState();
  }
}
