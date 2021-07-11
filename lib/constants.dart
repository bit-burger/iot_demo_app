import 'dart:io';

import 'package:flutter/rendering.dart';

const String defaultUrl = 'http://iot-controller';

const int defaultTabIndex = 1;

const double defaultNewFrameTime = 0.5;

const int defaultFrameRepeat = 10;

const double animationFrameBufferTime = 0.0060;

final RegExp urlRegex =
    RegExp(r"^https?:\/\/((?!(\.\.|--|__|::))[\d\w-:.])*[\d\w]$");

final bool isDesktop =
    Platform.isMacOS || Platform.isWindows || Platform.isLinux;

const Size minDesktopWindowSize = const Size(763, 569);
