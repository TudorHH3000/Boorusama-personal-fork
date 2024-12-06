// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/users/users.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/clients/danbooru/danbooru_client.dart';
import 'package:boorusama/core/configs.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/functional.dart';
import 'user_repository.dart';

final danbooruUserRepoProvider =
    Provider.family<UserRepository, BooruConfigAuth>((ref, config) {
  return UserRepositoryApi(
    ref.watch(danbooruClientProvider(config)),
    ref.watch(tagInfoProvider).defaultBlacklistedTags,
  );
});

const _kCurrentUserIdKey = '_current_uid';

final danbooruCurrentUserProvider =
    FutureProvider.family<UserSelf?, BooruConfigAuth>((ref, config) async {
  if (!config.hasLoginDetails()) return null;

  // First, we try to get the user id from the cache
  final miscData = ref.watch(miscDataBoxProvider);
  final key =
      '${_kCurrentUserIdKey}_${Uri.encodeComponent(config.url)}_${config.login}';
  final cached = miscData.get(key);
  var id = cached != null ? int.tryParse(cached) : null;

  // If the cached id is null, we need to fetch it from the api
  if (id == null) {
    final dio = ref.watch(dioProvider(config));

    final data = await DanbooruClient(
            dio: dio,
            baseUrl: config.url,
            apiKey: config.apiKey,
            login: config.login)
        .getProfile()
        .then((value) => value.data['id']);

    id = switch (data) {
      final int i => i,
      _ => null,
    };

    // If the id is not null, we cache it
    if (id != null) {
      miscData.put(key, id.toString());
    }
  }

  // If the id is still null, we can't do anything else here
  if (id == null) return null;

  return ref.watch(danbooruUserRepoProvider(config)).getUserSelfById(id);
});

final danbooruUserProvider =
    AsyncNotifierProvider.autoDispose.family<UserNotifier, DanbooruUser, int>(
  UserNotifier.new,
);

typedef DanbooruUserUploadParams = ({
  String username,
  int uploadCount,
});

final danbooruUserUploadsProvider =
    FutureProvider.family<List<DanbooruPost>, DanbooruUserUploadParams>(
        (ref, params) async {
  final uploadCount = params.uploadCount;
  final name = params.username;

  if (uploadCount == 0) return [];
  final config = ref.watchConfigSearch;

  final repo = ref.watch(danbooruPostRepoProvider(config));
  final uploads = await repo.getPostsFromTagsOrEmpty(
    'user:$name',
    limit: 50,
  );

  return uploads.posts;
});

final danbooruUserFavoritesProvider = FutureProvider.autoDispose
    .family<List<DanbooruPost>, int>((ref, uid) async {
  final config = ref.watchConfigSearch;
  final user = await ref.watch(danbooruUserProvider(uid).future);
  final repo = ref.watch(danbooruPostRepoProvider(config));
  final favs = await repo.getPostsFromTagsOrEmpty(
    buildFavoriteQuery(user.name),
    limit: 50,
  );

  return favs.posts;
});

final danbooruCreatorHiveBoxProvider = Provider<Box>((ref) {
  throw UnimplementedError();
});

final danbooruCreatorRepoProvider =
    Provider.family<CreatorRepository, BooruConfigAuth>(
  (ref, config) {
    return CreatorRepositoryFromUserRepo(
      ref.watch(danbooruUserRepoProvider(config)),
      ref.watch(danbooruCreatorHiveBoxProvider),
    );
  },
  dependencies: [
    danbooruCreatorHiveBoxProvider,
  ],
);

final danbooruCreatorsProvider = NotifierProvider.family<CreatorsNotifier,
    IMap<int, Creator>, BooruConfigAuth>(CreatorsNotifier.new);

final danbooruCreatorProvider = Provider.family<Creator?, int?>((ref, id) {
  if (id == null) return null;
  final config = ref.watchConfigAuth;
  return ref.watch(danbooruCreatorsProvider(config))[id];
});
