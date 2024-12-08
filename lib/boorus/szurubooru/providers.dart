// Package imports:
import 'package:booru_clients/szurubooru.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/szurubooru/favorites/favorites.dart';
import 'package:boorusama/core/autocompletes/autocompletes.dart';
import 'package:boorusama/core/configs/config.dart';
import 'package:boorusama/core/http/providers.dart';
import 'package:boorusama/core/posts.dart';
import 'package:boorusama/core/posts/sources.dart';
import 'package:boorusama/core/search/query_composer_providers.dart';
import 'package:boorusama/core/settings/data/listing_provider.dart';
import 'package:boorusama/core/tags/categories/tag_category.dart';
import 'package:boorusama/core/tags/tag/tag.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/path.dart';
import 'post_votes/post_votes.dart';
import 'szurubooru_post.dart';

final szurubooruClientProvider =
    Provider.family<SzurubooruClient, BooruConfigAuth>(
  (ref, config) {
    final dio = ref.watch(dioProvider(config));

    return SzurubooruClient(
      dio: dio,
      baseUrl: config.url,
      username: config.login,
      token: config.apiKey,
    );
  },
);

final szurubooruPostRepoProvider =
    Provider.family<PostRepository, BooruConfigSearch>(
  (ref, config) {
    final client = ref.watch(szurubooruClientProvider(config.auth));

    return PostRepositoryBuilder(
      getComposer: () => ref.read(currentTagQueryComposerProvider),
      fetch: (tags, page, {limit}) async {
        final posts = await client.getPosts(
          tags: tags,
          page: page,
          limit: limit,
        );

        final categories =
            await ref.read(szurubooruTagCategoriesProvider(config.auth).future);

        final data = posts.posts
            .map((e) => SzurubooruPost(
                  id: e.id ?? 0,
                  thumbnailImageUrl: e.thumbnailUrl ?? '',
                  sampleImageUrl: e.contentUrl ?? '',
                  originalImageUrl: e.contentUrl ?? '',
                  tags: e.tags
                          ?.map((e) => e.names?.firstOrNull)
                          .nonNulls
                          .toSet() ??
                      {},
                  tagDetails: e.tags
                          ?.map((e) => Tag(
                                name: e.names?.firstOrNull ?? '???',
                                category: categories.firstWhereOrNull(
                                        (element) =>
                                            element.name == e.category) ??
                                    TagCategory.general(),
                                postCount: e.usages ?? 0,
                              ))
                          .toList() ??
                      [],
                  rating: switch (e.safety?.toLowerCase()) {
                    'safe' => Rating.general,
                    'questionable' => Rating.questionable,
                    'sketchy' => Rating.questionable,
                    'unsafe' => Rating.explicit,
                    _ => Rating.general,
                  },
                  hasComment: (e.commentCount ?? 0) > 0,
                  isTranslated: (e.noteCount ?? 0) > 0,
                  hasParentOrChildren: (e.relationCount ?? 0) > 0,
                  source: PostSource.from(e.source),
                  score: e.score ?? 0,
                  duration: 0,
                  fileSize: e.fileSize ?? 0,
                  format: extension(e.contentUrl ?? ''),
                  hasSound: e.flags?.contains('sound'),
                  height: e.canvasHeight?.toDouble() ?? 0,
                  md5: e.checksumMD5 ?? '',
                  videoThumbnailUrl: e.thumbnailUrl ?? '',
                  videoUrl: e.contentUrl ?? '',
                  width: e.canvasWidth?.toDouble() ?? 0,
                  createdAt: e.creationTime != null
                      ? DateTime.tryParse(e.creationTime!)
                      : null,
                  uploaderName: e.user?.name,
                  ownFavorite: e.ownFavorite ?? false,
                  favoriteCount: e.favoriteCount ?? 0,
                  commentCount: e.commentCount ?? 0,
                  metadata: PostMetadata(
                    page: page,
                    search: tags.join(' '),
                  ),
                ))
            .toList();

        ref
            .read(szurubooruFavoritesProvider(config.auth).notifier)
            .preload(data);
        ref
            .read(szurubooruPostVotesProvider(config.auth).notifier)
            .getVotes(data);

        return data.toResult(
          total: posts.total,
        );
      },
      getSettings: () async => ref.read(imageListingSettingsProvider),
    );
  },
);

final szurubooruAutocompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfigAuth>(
  (ref, config) {
    final client = ref.watch(szurubooruClientProvider(config));

    return AutocompleteRepositoryBuilder(
      persistentStorageKey:
          '${Uri.encodeComponent(config.url)}_autocomplete_cache_v1',
      autocomplete: (query) async {
        // if not logged in, don't autocomplete
        if (!config.hasLoginDetails()) return [];

        final tags = await client.autocomplete(query: query);

        final categories =
            await ref.read(szurubooruTagCategoriesProvider(config).future);

        return tags
            .map((e) => AutocompleteData(
                  label: e.names?.firstOrNull
                          ?.toLowerCase()
                          .replaceAll('_', ' ') ??
                      '???',
                  value: e.names?.firstOrNull?.toLowerCase() ?? '???',
                  category: categories
                      .firstWhereOrNull((element) => element.name == e.category)
                      ?.name,
                  postCount: e.usages,
                ))
            .toList();
      },
    );
  },
);

final szurubooruTagCategoriesProvider =
    FutureProvider.family<List<TagCategory>, BooruConfigAuth>(
  (ref, config) async {
    final client = ref.read(szurubooruClientProvider(config));

    final categories = await client.getTagCategories();

    return categories
        .mapIndexed((index, e) => TagCategory(
              id: index,
              name: e.name ?? '???',
              order: e.order,
              darkColor: ColorUtils.hexToColor(e.color),
              lightColor: ColorUtils.hexToColor(e.color),
            ))
        .toList();
  },
);
