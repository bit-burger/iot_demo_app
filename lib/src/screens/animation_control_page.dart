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
import 'package:iot_app/src/models/leds.dart';
import 'package:iot_app/src/providers/floating_action_button_events.dart';
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
// TODO: make sure errors and animation is handled accordingly:
//       - if any command on normal is done (like turning off and on),
//       - an error should be returned by the api and be showed
//       - that is why also the error message must be recorded and displayed
//       - if animation is already running and new one is put on top it should be overridden
//       - animation stop button must exist (maybe long press on FAB)
//       - if any other error happens on animation, it should be displayed with a snack bar

class _AnimationControlPageState extends State<AnimationControlPage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late final List<LedFrame> _animationFrames;

  // TODO: have these two values also saved in Preferences
  late double _standardTime;
  late int _repeat;

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
          i ?? lastFrameIndex + 1, LedFrame(Leds.off(), _standardTime));
    }
    saveChanges();
  }

  void _removeFrame([int? i]) {
    _animationFrames.removeAt(i ?? lastFrameIndex);
    saveChanges();
  }

  void _resetFrameColors([int? i]) {
    _animationFrames[i ?? lastFrameIndex].frame.allOff();
    saveChanges();
  }

  void _resetFrameTime([int? i]) {
    _animationFrames[i ?? lastFrameIndex].time = _standardTime;
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
                onPressed: noFrames ? null : () => setState(_removeFrame),
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
                final timeAsString = _standardTime.toString();
                return 'Frame time for new frames: ' +
                    timeAsString +
                    (_standardTime.toString().length == 3 ? '0' : '') +
                    ' seconds';
              }()),
            ),
          ),
          Slider.adaptive(
            min: 0,
            max: 10,
            divisions: 40,
            value: _standardTime,
            label: _standardTime.toString(),
            onChanged: (v) {
              if (v == 0) return;
              HapticFeedback.selectionClick();
              setState(() {
                _standardTime = v;
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
          value: (i) => setState(() => _removeFrame(i)),
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
                setState(() => _removeFrame(index));
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
    _animationFrames = context.read<Preferences>().ledAnimationFrames;
    _standardTime = 0.5;
    _repeat = 100;

    context
        .read<FloatingActionButtonEvents>()
        .addListener(_floatingActionButtonTapped);

    _headerAnimationController = AnimationController(
      value: _animationFrames.isEmpty ? 1 : 0,
      vsync: this,
      duration: Duration(seconds: 1),
    );

    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  void _floatingActionButtonTapped() {
    final tabIndex = context.read<TabViewIndex>();
    if (tabIndex.index != 2) return;
    final microController = context.read<MicroController>();
    microController.makeRequest('/animation', Method.PUT, {
      'repeat': _repeat,
      'frames': _animationFrames
          .map((frame) => frame.toJson())
          .toList(growable: false),
    });
  }
}
