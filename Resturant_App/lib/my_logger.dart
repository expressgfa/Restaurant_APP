import 'package:logger/logger.dart';

var logger = Logger();


verboseLog(String message) {
  logger.v(message);
}

debugLog(String message) {
  logger.d(message);
}

infoLog(String message) {
  logger.i(message);
}

warningLog(String message) {
  logger.w(message);
}

errorLog(String message) {
  logger.e(message);
}

wtfLog(String message) {
  logger.wtf(message);
}
