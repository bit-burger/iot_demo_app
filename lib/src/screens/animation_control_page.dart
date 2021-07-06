import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';
import 'package:iot_app/src/models/led.dart';
import 'package:iot_app/src/models/led_frame.dart';
import 'package:iot_app/src/models/led_state.dart';
import 'package:iot_app/src/models/leds.dart';
import 'package:iot_app/src/providers/floating_action_button_events.dart';
import 'package:iot_app/src/providers/led_ring.dart';
import 'package:iot_app/src/providers/micro_controller.dart';
import 'package:iot_app/src/providers/preferences.dart';
import 'package:iot_app/src/providers/tab_view_index.dart';
import 'package:iot_app/src/widgets/circle_color_picker_modal_sheet.dart';
import 'package:iot_app/src/widgets/color_list_tile.dart';
import 'package:provider/provider.dart';

class AnimationControlPage extends StatefulWidget {
  @override
  _AnimationControlPageState createState() => _AnimationControlPageState();
}
// TODO: On the modal barrier, put an animating led ring

class _AnimationControlPageState extends State<AnimationControlPage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late final List<LedFrame> _animationFrames;

  late double _newFrameTime;
  late int _repeat;
  Timer? _animationTimer;

  bool get noFrames => _animationFrames.length == 0;

  int get lastFrameIndex => _animationFrames.length - 1;

  void saveChanges() {
    context.read<Preferences>().ledAnimationFrames = _animationFrames;
    if (_animationFrames.isEmpty) {
      _headerAnimationController.animateTo(1,
          duration: Duration(milliseconds: 500));
    } else {
      _headerAnimationController.animateTo(0,
          duration: Duration(milliseconds: 500));
    }
  }

  void _duplicateFrameToLeft([int? i, int howOften = 1]) {
    for (var j = 0; j < howOften; j++) {
      _animationFrames.insert((i ?? lastFrameIndex) + 1,
          _animationFrames[i ?? lastFrameIndex].copy()..rotateToLeft());
    }
    saveChanges();
  }

  void _duplicateFrameToRight([int? i, int howOften = 1]) {
    for (var j = 0; j < howOften; j++) {
      _animationFrames.insert((i ?? lastFrameIndex) + 1,
          _animationFrames[i ?? lastFrameIndex].copy()..rotateToRight());
    }
    saveChanges();
  }

  void _duplicateFrame([int? i, int howOften = 1]) {
    for (var j = 0; j < howOften; j++) {
      _animationFrames.insert((i ?? lastFrameIndex) + 1,
          _animationFrames[i ?? lastFrameIndex].copy());
    }
    saveChanges();
  }

  void _addNewFrame([int? i, int howOften = 1]) {
    for (var j = 0; j < howOften; j++) {
      _animationFrames.insert(
          i ?? lastFrameIndex + 1, LedFrame(Leds.off(), _newFrameTime));
    }
    saveChanges();
  }

  void _deleteFrame([int? i, int howOften = 1]) {
    for (var j = 0; j < howOften; j++) {
      _animationFrames.removeAt(i ?? lastFrameIndex);
    }
    saveChanges();
  }

  void _resetFrameColors([int? i]) {
    _animationFrames[i ?? lastFrameIndex].frame.allOff();
    saveChanges();
  }

  void _resetFrameTime([int? i]) {
    _animationFrames[i ?? lastFrameIndex].time = _newFrameTime;
    saveChanges();
  }

  void _resetAllFrameTimes() {
    for (var i = 0; i < _animationFrames.length; i++) {
      _animationFrames[i].time = _newFrameTime;
    }
    saveChanges();
  }

  void _changeColor(int i, int? ledIndex, Color newColor) {
    final frame = _animationFrames[i];
    final led = Led.fromColor(newColor);
    if (ledIndex != null) {
      frame.frame.ledValues[ledIndex] = led;
    } else {
      frame.frame = Leds.all(led);
    }
    saveChanges();
  }

  late final AnimationController _headerAnimationController;

  Widget _buildHeader() {
    return SizeFadeTransition(
      curve: Curves.easeInCubic,
      animation: _headerAnimationController,
      child: Column(
        children: [
          ListTile(
            title: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Column(
                  children: [
                    SizedBox(
                      height: 16,
                    ),
                    TextButton(
                      child: Icon(
                        Icons.add,
                        color: Theme.of(context).disabledColor,
                        size: 40,
                      ),
                      onPressed: () {
                        setState(_addNewFrame);
                      },
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    Text(
                      'No animation frames',
                      style: Theme.of(context).textTheme.caption,
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Text(
                      "Press 'Add new' or the + icon to add one",
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Divider(),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          if (!noFrames)
            Divider(
              indent: 0,
              endIndent: 0,
              height: 1 / 4,
              thickness: 1 / 4,
            ),
          SizedBox(
            height: 7.75,
          ),
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              TextButton(
                child: Text('Add new'),
                onPressed: () => setState(_addNewFrame),
                onLongPress: () => setState(() => _addNewFrame(null, 11)),
              ),
              TextButton(
                child: Text('Delete last'),
                onPressed: noFrames ? null : () => setState(_deleteFrame),
                onLongPress: noFrames
                    ? null
                    : () => setState(
                        () => _deleteFrame(0, _animationFrames.length)),
              ),
              TextButton(
                child: Text('Duplicate last'),
                onPressed: noFrames ? null : () => setState(_duplicateFrame),
                onLongPress: noFrames
                    ? null
                    : () => setState(() => _duplicateFrame(null, 11)),
              ),
              TextButton(
                child: Text('Duplicate last left'),
                onPressed:
                    noFrames ? null : () => setState(_duplicateFrameToLeft),
                onLongPress: noFrames
                    ? null
                    : () => setState(() => _duplicateFrameToLeft(null, 11)),
              ),
              TextButton(
                child: Text('Duplicate last right'),
                onPressed:
                    noFrames ? null : () => setState(_duplicateFrameToRight),
                onLongPress: noFrames
                    ? null
                    : () => setState(() => _duplicateFrameToRight(null, 11)),
              ),
              TextButton(
                child: Text('All adapt global frame time'),
                onPressed:
                    noFrames ? null : () => setState(_resetAllFrameTimes),
              ),
            ],
          ),
          Divider(),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: EdgeInsets.only(left: 5),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(() {
                final timeAsString = _newFrameTime.toString();
                return 'Frame time for new frames: ' +
                    timeAsString +
                    (_newFrameTime.toString().length == 3 ? '0' : '') +
                    ' seconds';
              }()),
            ),
          ),
          Slider.adaptive(
            min: 0,
            max: 10,
            divisions: 40,
            value: _newFrameTime,
            label: _newFrameTime.toString(),
            onChanged: (v) {
              if (v == 0) return;
              HapticFeedback.selectionClick();
              setState(() {
                _newFrameTime = v;
                context.read<Preferences>().newFrameTime = _newFrameTime;
              });
            },
          ),
          Divider(),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: EdgeInsets.only(left: 5),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(() {
                var timeAsString = _repeat.toString();
                if (_repeat < 10) timeAsString = ' ' + timeAsString;
                if (_repeat < 100) timeAsString = timeAsString + '';
                return 'How often to repeat the sequence: ' +
                    timeAsString +
                    ' time' +
                    (_repeat == 1 ? '' : 's');
              }()),
            ),
          ),
          Slider.adaptive(
            min: 1,
            max: 100,
            value: _repeat.toDouble(),
            label: _repeat.toString(),
            onChanged: (v) {
              HapticFeedback.selectionClick();
              setState(() {
                _repeat = v.toInt();
                context.read<Preferences>().frameRepeat = _repeat;
              });
            },
          ),
          SizedBox(
            height: MediaQuery.of(context).padding.bottom + 200,
          ),
        ],
      ),
    );
  }

  Widget _buildPopUpButton({required int index}) {
    return PopupMenuButton<void Function(int)>(
      padding: EdgeInsets.zero,
      tooltip: 'Show actions',
      onSelected: (void Function(int) f) {
        f(index);
      },
      itemBuilder: (_) => <PopupMenuEntry<void Function(int)>>[
        PopupMenuItem(
          value: (i) => setState(() => _duplicateFrame(i)),
          child: Text('Duplicate'),
        ),
        PopupMenuItem(
          value: (i) => setState(() => _duplicateFrameToLeft(i)),
          child: Text('Duplicate to left'),
        ),
        PopupMenuItem(
          value: (i) => setState(() => _duplicateFrameToRight(i)),
          child: Text('Duplicate to right'),
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: (i) => setState(() => _resetFrameColors(i)),
          child: Text('Reset colors'),
        ),
        PopupMenuItem(
          value: (i) => setState(() => _resetFrameTime(i)),
          child: Text('Reset frame time'),
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: (i) => setState(() => _deleteFrame(i)),
          child: Text('Delete'),
        ),
      ],
    );
  }

  Reorderable _buildItem(
    BuildContext context,
    Animation<double> itemAnimation,
    LedFrame ledFrame,
    int index,
  ) {
    return Reorderable(
      key: ValueKey(ledFrame),
      builder: (context, dragAnimation, inDrag) {
        final animatedBuilder = AnimatedBuilder(
          animation: dragAnimation,
          child: ColorListTile(
            onPressed: () {
              Scaffold.of(context).showBodyScrim(true, 0.2);
              Scaffold.of(context).showBottomSheet(
                (context) => CircleColorPickerModalSheet(
                  initialColorValues: ledFrame.toColorList(),
                  dismiss: () {
                    Navigator.of(context).pop();
                    Scaffold.of(context).showBodyScrim(false, 0);
                  },
                  onChangedColors: (int? ledIndex, Color newColor) =>
                      setState(() => _changeColor(index, ledIndex, newColor)),
                ),
                backgroundColor: Colors.transparent,
              );
            },
            selectedColors: ledFrame.toColorList(),
            onChangedColors: (int? ledIndex, Color newColor) =>
                setState(() => _changeColor(index, ledIndex, newColor)),
            firstTrailing: Handle(
              child: Icon(Icons.drag_handle),
            ),
            secondTrailing: _buildPopUpButton(index: index),
          ),
          builder: (context, child) {
            final backgroundColor = Color.lerp(
                Colors.white, Colors.grey.shade100, dragAnimation.value);
            return SizeFadeTransition(
              animation: itemAnimation,
              curve: Curves.decelerate,
              child: Column(
                children: [
                  if (!inDrag)
                    Divider(
                      indent: 0,
                      endIndent: 0,
                      height: 1 / 4,
                      thickness: 1 / 4,
                    ),
                  Material(
                    child: child!,
                    color: backgroundColor,
                  ),
                  if (!inDrag)
                    Divider(
                      indent: 0,
                      endIndent: 0,
                      height: 1 / 4,
                      thickness: 1 / 4,
                    ),
                ],
              ),
            );
          },
        );
        if (inDrag) return animatedBuilder;
        return Slidable(
          key: UniqueKey(),
          actions: [
            SlideAction(
              onTap: () {
                setState(() => _duplicateFrame(index));
              },
              color: Colors.blueAccent,
              child: Center(
                child: Text(
                  'Duplicate',
                  style: Theme.of(context).primaryTextTheme.bodyText1,
                ),
              ),
            ),
          ],
          secondaryActions: [
            SlideAction(
              onTap: () {
                setState(() => _deleteFrame(index));
              },
              color: Colors.redAccent,
              child: Center(
                child: Text(
                  'Delete',
                  style: Theme.of(context).primaryTextTheme.bodyText1,
                ),
              ),
            ),
          ],
          actionPane: SlidableScrollActionPane(),
          child: animatedBuilder,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: ImplicitlyAnimatedReorderableList<LedFrame>(
        // key: globalKey,
        items: _animationFrames,
        areItemsTheSame: (oldItem, newItem) => identical(oldItem, newItem),
        onReorderFinished: (_, __, ___, newItems) {
          setState(() {
            _animationFrames
              ..clear()
              ..addAll(newItems);
          });
        },
        itemBuilder: _buildItem,
        header: _buildHeader(),
        footer: _buildFooter(),
      ),
    );
  }

  @override
  void initState() {
    final preferences = context.read<Preferences>();

    _animationFrames = preferences.ledAnimationFrames;
    _newFrameTime = preferences.newFrameTime;
    _repeat = preferences.frameRepeat;

    context
        .read<FloatingActionButtonEvents>()
        .addListener(_floatingActionButtonTapped);

    _headerAnimationController = AnimationController(
      value: _animationFrames.isEmpty ? 1 : 0,
      vsync: this,
      duration: Duration(seconds: 1),
    );

    final ledRing = context.read<LedRing>();

    ledRing.addListener(() {
      if (ledRing.isActive) {
        _animationTimer?.cancel();
        _animationTimer = null;
      }
    });

    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  void displayErrorMessage(String errorMessage) {
    final snackBar = SnackBar(
      content: Text(
        errorMessage,
        textAlign: TextAlign.center,
        // style: Theme.of(context).snackBarTheme.contentTextStyle,
      ),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void stopAnimating(LedRing ledRing, MicroController microController) async {
    if (ledRing.state == LedState.loading) {
      return displayErrorMessage(
        'A request to micro controller is still loading,'
        ' please wait for it to complete',
      );
    }
    ledRing.startedLoading();
    _animationTimer?.cancel();
    _animationTimer = null;
    final result =
        await microController.makeRequest('/cancel-animation', Method.DELETE);
    if (result.isValue) {
      ledRing.stoppedAnimating();
    } else if (result.asError!.error == MicroControllerErrors.AnimationError) {
      displayErrorMessage('Animation was already stopped');
      ledRing.stoppedAnimating();
    } else {
      ledRing.connectionError();
    }
  }

  void startAnimating(LedRing ledRing, MicroController microController) async {
    _animationTimer?.cancel();
    _animationTimer = null;
    if (ledRing.state == LedState.loading) {
      return displayErrorMessage(
        'A request to micro controller is still loading,'
        ' please wait for it to complete',
      );
    }
    ledRing.startedLoading();
    final result =
        await microController.makeRequest('/animation', Method.POST, {
      'repeat': _repeat,
      'frames': _animationFrames
          .map((frame) => frame.toJson())
          .toList(growable: false),
    });
    if (result.isValue) {
      ledRing.startedAnimating();
      final secondsTillAnimationStop = _animationFrames.fold<double>(
              0, (previousValue, frame) => previousValue += frame.time) *
          _repeat.toDouble();
      _animationTimer = Timer(
        Duration(milliseconds: (secondsTillAnimationStop * 1000).toInt()),
        () {
          ledRing.stoppedAnimating();
        },
      );
    } else if (result.asError!.error == MicroControllerErrors.AnimationError) {
      ledRing.startedAnimating();
      displayErrorMessage('Already animating');
    } else {
      ledRing.connectionError();
    }
  }

  void _floatingActionButtonTapped() async {
    final tabIndex = context.read<TabViewIndex>();
    final ledRing = context.read<LedRing>();
    final microController = context.read<MicroController>();

    if (ledRing.state == LedState.animating) {
      stopAnimating(ledRing, microController);
    } else if (tabIndex.index == 2) {
      startAnimating(ledRing, microController);
    }
  }
}
