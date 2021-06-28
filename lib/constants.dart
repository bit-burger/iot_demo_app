const String defaultUrl = 'http://iot-controller';

const int initialTabIndex = 1;

final RegExp urlRegex =
    RegExp(r"^https?:\/\/((?!(\.\.|--|__|::))[\d\w-:.])*[\d\w]$");
