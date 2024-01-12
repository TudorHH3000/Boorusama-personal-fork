// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/e621/feats/favorites/favorites.dart';
import 'package:boorusama/boorus/e621/feats/posts/posts.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/widgets/widgets.dart';

class E621PostActionToolbar extends ConsumerWidget {
  const E621PostActionToolbar({
    super.key,
    required this.post,
  });

  final E621Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    final isFaved = ref.watch(e621FavoriteProvider(post.id));

    return SimplePostActionToolbar(
      post: post,
      isFaved: isFaved,
      isAuthorized: config.hasLoginDetails(),
      addFavorite: () =>
          ref.read(e621FavoritesProvider(config).notifier).add(post.id),
      removeFavorite: () =>
          ref.read(e621FavoritesProvider(config).notifier).remove(post.id),
    );
  }
}
