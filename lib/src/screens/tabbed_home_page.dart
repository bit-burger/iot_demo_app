import 'package:flutter/cupertino.dart';
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
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:iot_app/constants.dart' as constants show isDesktop;

class TabbedHomePage extends StatefulWidget {
  TabbedHomePage();

  @override
  _TabbedHomePageState createState() => _TabbedHomePageState();
}

class _TabbedHomePageState extends State<TabbedHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<bool> iconShouldBeOverriddenByAnimationStopper = [
    true,
    true,
    true,
    false,
    true,
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
          action,
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
            action: Padding(
              padding: EdgeInsets.only(right: 50),
              child: Wrap(
                spacing: 16,
                children: [
                  _coloredButtonAction(
                    title: 'Stop animation',
                    onPressed: () => context
                        .read<FloatingActionButtonEvents>()
                        .floatingActionButtonPressed(),
                    backgroundColor: Colors.orange,
                  ),
                  _coloredButtonAction(
                    title: 'Retry',
                    onPressed: () => ledRing.refresh(),
                    backgroundColor: Colors.blue,
                  ),
                ],
              ),
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

  // FAB for the normal on/off/loading state (also on sensors)
  Widget _refreshFloatingActionButton(bool isSensor) {
    return GestureDetector(
      onLongPress: () {
        if (!isSensor) context.read<LedRing>().reset();
      },
      child: FloatingActionButton(
        onPressed: () {
          if (isSensor) {
            context
                .read<FloatingActionButtonEvents>()
                .floatingActionButtonPressed();
          } else {
            context.read<LedRing>().refresh();
          }
        },
        child: Icon(Icons.refresh),
      ),
    );
  }

  // FAB for AnimationControl in on/off/loading state
  Widget _startAnimationFloatingActionButton() {
    return FloatingActionButton(
      key: ValueKey('Start animation'),
      backgroundColor: Colors.green,
      onPressed: () {
        context
            .read<FloatingActionButtonEvents>()
            .floatingActionButtonPressed();
      },
      child: Icon(Icons.play_arrow),
    );
  }

  // FAB for error state (global)
  Widget _errorFloatingActionButton() {
    return FloatingActionButton(
      key: ValueKey('Error'),
      backgroundColor: Colors.red,
      onPressed: () {
        context.read<LedRing>().refresh();
      },
      child: Icon(Icons.refresh),
    );
  }

  // FAB for animating state
  Widget _animatingStopFloatingActionButton() {
    return FloatingActionButton(
      key: ValueKey('Stop animation'),
      backgroundColor: Colors.orange,
      onPressed: () {
        context
            .read<FloatingActionButtonEvents>()
            .floatingActionButtonPressed();
      },
      child: Icon(Icons.stop),
    );
  }

  Widget _floatingActionButton(int tabIndex, LedState ledState) {
    if (ledState == LedState.animating &&
        iconShouldBeOverriddenByAnimationStopper[tabIndex]) {
      return _animatingStopFloatingActionButton();
    }

    if (ledState == LedState.connectionError) {
      return _errorFloatingActionButton();
    }

    if (tabIndex == 2) {
      return _startAnimationFloatingActionButton();
    }
    return _refreshFloatingActionButton(tabIndex == 3);
  }

  PreferredSizeWidget _buildAppBar() {
    final appBar = AppBar(
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
    );

    if (constants.isDesktop)
      return PreferredSize(
        preferredSize: appBar.preferredSize,
        child: MoveWindow(
          child: appBar,
        ),
      );
    return appBar;
  }

  @override
  Widget build(BuildContext context) {
    final tabIndex = context.watch<TabViewIndex>().index;
    final ledRing = context.watch<LedRing>();

    return Scaffold(
      appBar: _buildAppBar(),
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
          if (statesList[tabIndex].contains(ledRing.state) &&
              (ledRing.state != LedState.off ||
                  !ledRing.ledConfiguration.isCompletelyOnOrOff))
            ..._modalBarrier(tabIndex, ledRing),
        ],
      ),
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
