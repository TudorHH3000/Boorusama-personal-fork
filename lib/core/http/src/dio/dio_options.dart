// Dart imports:
import 'dart:io';

// Project imports:
import '../../../boorus/booru/booru.dart';
import '../../../configs/config.dart';
import '../../../foundation/loggers.dart';

class DioOptions {
  DioOptions({
    required this.cacheDir,
    required this.baseUrl,
    required this.userAgent,
    required this.authConfig,
    required this.loggerService,
    required this.booruFactory,
  });
  final Directory cacheDir;
  final String baseUrl;
  final String userAgent;
  final BooruConfigAuth authConfig;
  final Logger loggerService;
  final BooruFactory booruFactory;
}
