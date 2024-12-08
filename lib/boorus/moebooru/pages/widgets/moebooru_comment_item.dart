// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/moebooru/feats/comments/comments.dart';
import 'package:boorusama/core/comments/comment_header.dart';
import 'package:boorusama/core/configs/ref.dart';
import 'package:boorusama/core/dtext/dtext.dart';
import 'package:boorusama/foundation/html.dart';

class MoebooruCommentItem extends ConsumerWidget {
  const MoebooruCommentItem({
    super.key,
    required this.comment,
  });

  final MoebooruComment comment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruConfig = ref.watchConfigAuth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommentHeader(
          authorName: comment.creator,
          authorTitleColor: Theme.of(context).colorScheme.primary,
          createdAt: comment.createdAt,
        ),
        const SizedBox(height: 4),
        AppHtml(
          data: dtext(
            comment.body,
            booruUrl: booruConfig.url,
          ),
        )
      ],
    );
  }
}
