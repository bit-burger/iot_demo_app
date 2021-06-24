const String defaultUrl = 'http://iot-controller';

final RegExp urlRegex =
    RegExp(r"^https?:\/\/((?!(\.\.|--|__|::))[\d\w-:.])*[\d\w]$");
