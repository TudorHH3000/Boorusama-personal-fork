// Flutter imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/ref.dart';
import 'package:boorusama/core/favorites/quick_favorite_button.dart';
import '../posts/post/danbooru_post.dart';
import 'favorites_notifier.dart';

class DanbooruQuickFavoriteButton extends ConsumerWidget {
  const DanbooruQuickFavoriteButton({
    super.key,
    required this.post,
  });

  final DanbooruPost post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier =
        ref.watch(danbooruFavoritesProvider(ref.watchConfigAuth).notifier);
    final isFaved =
        post.isBanned ? false : ref.watch(danbooruFavoriteProvider(post.id));

    return QuickFavoriteButton(
      isFaved: isFaved,
      onFavToggle: (isFaved) async {
        if (!isFaved) {
          notifier.remove(post.id);
        } else {
          notifier.add(post.id);
        }
      },
    );
  }
}
