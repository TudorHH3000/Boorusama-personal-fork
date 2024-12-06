// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/hydrus/hydrus.dart';
import 'package:boorusama/clients/hydrus/types/types.dart';
import 'package:boorusama/core/configs.dart';
import 'package:boorusama/functional.dart';
import 'favorites.dart';

final hydrusFavoritesProvider = NotifierProvider.family<HydrusFavoritesNotifier,
    IMap<int, bool>, BooruConfigAuth>(
  HydrusFavoritesNotifier.new,
);

final hydrusFavoriteProvider =
    Provider.autoDispose.family<bool, int>((ref, postId) {
  final config = ref.watchConfigAuth;
  final favorites = ref.watch(hydrusFavoritesProvider(config));
  return favorites[postId] ?? false;
});

final hydrusCanFavoriteProvider =
    FutureProvider.family<bool, BooruConfigAuth>((ref, config) async {
  final client = ref.watch(hydrusClientProvider(config));

  final services = await client.getServicesCached();

  return getLikeDislikeRatingKey(services) != null;
});
