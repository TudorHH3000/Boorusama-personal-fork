// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/manage.dart';
import 'package:boorusama/core/posts/posts.dart';

final postShareProvider = NotifierProvider.autoDispose
    .family<PostShareNotifier, PostShareState, Post>(
  PostShareNotifier.new,
  dependencies: [
    currentBooruConfigProvider,
    booruFactoryProvider,
  ],
);
