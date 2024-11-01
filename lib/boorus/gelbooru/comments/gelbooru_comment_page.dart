// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'comments.dart';

class GelbooruCommentPage extends ConsumerWidget {
  const GelbooruCommentPage({
    super.key,
    required this.postId,
    required this.useAppBar,
  });

  final int postId;
  final bool useAppBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    return CommentPageScaffold(
      postId: postId,
      useAppBar: useAppBar,
      fetcher: (postId) =>
          ref.watch(gelbooruCommentRepoProvider(config)).getComments(postId),
    );
  }
}
