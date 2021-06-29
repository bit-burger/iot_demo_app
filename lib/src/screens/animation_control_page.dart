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
import 'package:iot_app/src/models/tab_view_floating_action_button_event_provider.dart';
import 'package:iot_app/src/widgets/circle_color_picker_modal_sheet.dart';
import 'package:iot_app/src/widgets/color_list_tile.dart';
import 'package:provider/provider.dart';

class AnimationControlPage extends StatefulWidget {
  @override
  _AnimationControlPageState createState() => _AnimationControlPageState();
}

class _AnimationControlPageState extends State<AnimationControlPage>
    with AutomaticKeepAliveClientMixin {
  late final List<LedFrame> _animationFrames;
  late double _standardTime;

  bool get noFrames => _animationFrames.length == 0;

  int get lastFrameIndex => _animationFrames.length - 1;

  void _duplicateFrameToLeft([int? i]) {
    setState(() {
      _animationFrames.insert((i ?? lastFrameIndex) + 1,
          _animationFrames[i ?? lastFrameIndex].copy()..rotateToLeft());
    });
  }

  void _duplicateFrameToRight([int? i]) {
    setState(() {
      _animationFrames.insert((i ?? lastFrameIndex) + 1,
          _animationFrames[i ?? lastFrameIndex].copy()..rotateToRight());
    });
  }

  void _duplicateFrame([int? i]) {
    setState(() {
      _animationFrames.insert((i ?? lastFrameIndex) + 1,
          _animationFrames[i ?? lastFrameIndex].copy());
    });
  }

  void _addNewFrame([int? i]) {
    setState(() {
      _animationFrames.insert(
          i ?? lastFrameIndex + 1, LedFrame(Leds.off(), _standardTime));
    });
  }

  void _removeFrame([int? i]) {
    setState(() {
      _animationFrames.removeAt(i ?? lastFrameIndex);
    });
  }

  void _resetFrameColors([int? i]) {
    setState(() {
      _animationFrames[i ?? lastFrameIndex].frame.allOff();
    });
  }

  void _resetFrameTime([int? i]) {
    setState(() {
      _animationFrames[i ?? lastFrameIndex].time = _standardTime;
    });
  }

  void _changeColor(int i, int? ledIndex, Color newColor) {
    setState(() {
      final frame = _animationFrames[i];
      final led = Led.fromColor(newColor);
      if (ledIndex != null) {
        frame.frame.ledValues[ledIndex] = led;
      } else {
        frame.frame = Leds.all(led);
      }
    });
  }

  Widget _buildHeader() {
    return Column(
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
                      setState(() {
                        _animationFrames
                            .add(LedFrame(Leds.off(), _standardTime));
                      });
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
                onPressed: _addNewFrame,
              ),
              TextButton(
                child: Text('Delete last'),
                onPressed: noFrames ? null : _removeFrame,
              ),
              TextButton(
                child: Text('Duplicate last'),
                onPressed: noFrames ? null : _duplicateFrame,
              ),
              TextButton(
                child: Text('Duplicate last left'),
                onPressed: noFrames ? null : _duplicateFrameToLeft,
              ),
              TextButton(
                child: Text('Duplicate last right'),
                onPressed: noFrames ? null : _duplicateFrameToRight,
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
          value: _duplicateFrame,
          child: Text('Duplicate'),
        ),
        PopupMenuItem(
          value: _duplicateFrameToLeft,
          child: Text('Duplicate to left'),
        ),
        PopupMenuItem(
          value: _duplicateFrameToRight,
          child: Text('Duplicate to right'),
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: _resetFrameColors,
          child: Text('Reset colors'),
        ),
        PopupMenuItem(
          value: _resetFrameTime,
          child: Text('Reset frame time'),
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: _removeFrame,
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
                      _changeColor(index, ledIndex, newColor),
                ),
                backgroundColor: Colors.transparent,
              );
            },
            selectedColors: ledFrame.toColorList(),
            onChangedColors: (int? ledIndex, Color newColor) =>
                _changeColor(index, ledIndex, newColor),
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
                setState(() {
                  _duplicateFrame(index);
                });
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
                setState(() {
                  _removeFrame(index);
                });
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
        header: noFrames ? _buildHeader() : null,
        footer: _buildFooter(),
      ),
    );
  }

  @override
  void initState() {
    _animationFrames = <LedFrame>[];
    _standardTime = 0.5;
    Provider.of<TabViewFloatingActionButtonEventProvider>(context,
            listen: false)
        .addListener(_floatingActionButtonTapped);
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  void _floatingActionButtonTapped() {
    final provider = Provider.of<TabViewFloatingActionButtonEventProvider>(
        context,
        listen: false);
    if (provider.tabIndex != 2) return;
    print('FloatingActionButton tappped (in AnimationControlPage)');
  }
}
