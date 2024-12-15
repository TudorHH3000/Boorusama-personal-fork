// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:filename_generator/filename_generator.dart';

// Project imports:
import '../../configs/config.dart';
import '../../posts/post/post.dart';
import '../../settings/settings.dart';
import 'token_options.dart';

abstract class DownloadFilenameGenerator<T extends Post> {
  Set<String> get availableTokens;

  Map<RegExp, TextStyle> get patternMatchMap;

  List<String> getTokenOptions(String token);
  TokenOptionDocs? getDocsForTokenOption(String token, String tokenOption);

  Future<String> generate(
    Settings settings,
    BooruConfig config,
    T post, {
    Map<String, String>? metadata,
    required String downloadUrl,
  });

  Future<String> generateForBulkDownload(
    Settings settings,
    BooruConfig config,
    T post, {
    Map<String, String>? metadata,
    required String downloadUrl,
  });

  String generateSample(String format);

  List<String> generateSamples(String format);

  String get defaultFileNameFormat;
  String get defaultBulkDownloadFileNameFormat;
}

typedef DownloadFilenameTokenHandler<T extends Post> = String? Function(
  T post,
  DownloadFilenameTokenOptions options,
);
