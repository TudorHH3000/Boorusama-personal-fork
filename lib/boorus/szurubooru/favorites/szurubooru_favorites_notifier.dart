// Package imports:
import 'package:booru_clients/szurubooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import 'package:boorusama/boorus/szurubooru/providers.dart';
import 'package:boorusama/boorus/szurubooru/szurubooru_post.dart';
import 'package:boorusama/core/configs/config.dart';
import 'package:boorusama/core/configs/ref.dart';
import 'package:boorusama/core/favorites/favorite.dart';
import '../post_votes/post_votes.dart';

class SzurubooruFavoritesNotifier
    extends FamilyNotifier<IMap<int, bool>, BooruConfigAuth>
    with FavoritesNotifierMixin {
  @override
  IMap<int, bool> build(BooruConfigAuth arg) {
    ref.watchConfig;

    return <int, bool>{}.lock;
  }

  void preload(List<SzurubooruPost> posts) => preloadInternal(
        posts,
        selfFavorited: (post) => post.ownFavorite,
      );

  SzurubooruClient get client => ref.read(szurubooruClientProvider(arg));

  @override
  Future<AddFavoriteStatus> Function(int postId) get favoriteAdder =>
      (postId) async {
        try {
          await client.addToFavorites(postId: postId);

          await ref
              .read(szurubooruPostVotesProvider(arg).notifier)
              .upvote(postId, localOnly: true);

          return AddFavoriteStatus.success;
        } catch (e) {
          return AddFavoriteStatus.failure;
        }
      };

  @override
  Future<bool> Function(int postId) get favoriteRemover => (postId) async {
        try {
          await client.removeFromFavorites(postId: postId);

          return true;
        } catch (e) {
          return false;
        }
      };

  @override
  IMap<int, bool> get favorites => state;

  @override
  void Function(IMap<int, bool> data) get updateFavorites =>
      (data) => state = data;
}
