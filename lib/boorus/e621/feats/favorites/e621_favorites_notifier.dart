// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/e621/feats/posts/posts.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/functional.dart';
import 'e621_favorites_provider.dart';

class E621FavoritesNotifier
    extends FamilyNotifier<IMap<int, bool>, BooruConfig> {
  @override
  IMap<int, bool> build(BooruConfig arg) {
    ref.watchConfig;

    return <int, bool>{}.lock;
  }

  void preload(List<E621Post> posts) => _preload({
        for (final post in posts) post.id: post.isFavorited,
      });

  void _preload(Map<int, bool> data) {
    state = state.addAll(data.lock);
  }

  Future<void> add(int postId) async {
    if (state[postId] == true) return;

    final success =
        await ref.read(e621FavoritesRepoProvider(arg)).addToFavorites(postId);
    if (success) {
      state = state.add(postId, true);
    }
  }

  Future<void> remove(int postId) async {
    if (state[postId] == false) return;

    final success = await ref
        .read(e621FavoritesRepoProvider(arg))
        .removeFromFavorites(postId);
    if (success) {
      state = state.add(postId, false);
    }
  }
}
