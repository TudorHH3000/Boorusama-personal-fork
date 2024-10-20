// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/clients/zerochan/types/types.dart';
import 'package:boorusama/clients/zerochan/zerochan_client.dart';
import 'package:boorusama/core/autocompletes/autocompletes.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/foundation/networking/networking.dart';
import 'package:boorusama/foundation/path.dart' as path;
import 'zerochan_post.dart';

final zerochanClientProvider =
    Provider.family<ZerochanClient, BooruConfig>((ref, config) {
  final dio = newDio(ref.watch(dioArgsProvider(config)));
  final logger = ref.watch(loggerProvider);

  return ZerochanClient(
    dio: dio,
    logger: (message) => logger.logE('ZerochanClient', message),
  );
});

final zerochanPostRepoProvider = Provider.family<PostRepository, BooruConfig>(
  (ref, config) {
    final client = ref.watch(zerochanClientProvider(config));

    return PostRepositoryBuilder(
      tagComposer: ref.watch(tagQueryComposerProvider(config)),
      getSettings: () async => ref.read(imageListingSettingsProvider),
      fetch: (tags, page, {limit}) async {
        final posts = await client.getPosts(
          tags: tags,
          page: page,
          sort: ZerochanSortOrder.recency,
          limit: limit,
        );

        return posts
            .map((e) => ZerochanPost(
                  id: e.id ?? 0,
                  thumbnailImageUrl: e.thumbnail ?? '',
                  sampleImageUrl: e.sampleUrl() ?? '',
                  originalImageUrl: e.fileUrl() ?? '',
                  tags: e.tags?.map((e) => e.toLowerCase()).toSet() ?? {},
                  rating: Rating.general,
                  hasComment: false,
                  isTranslated: false,
                  hasParentOrChildren: false,
                  source: PostSource.from(e.source),
                  score: 0,
                  duration: 0,
                  fileSize: 0,
                  format: path.extension(e.thumbnail ?? ''),
                  hasSound: null,
                  height: e.height?.toDouble() ?? 0,
                  md5: '',
                  videoThumbnailUrl: '',
                  videoUrl: '',
                  width: e.width?.toDouble() ?? 0,
                  uploaderId: null,
                  uploaderName: null,
                  createdAt: null,
                  metadata: PostMetadata(
                    page: page,
                    search: tags.join(' '),
                  ),
                ))
            .toList()
            .toResult();
      },
    );
  },
);

final zerochanAutoCompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfig>((ref, config) {
  final client = ref.watch(zerochanClientProvider(config));

  return AutocompleteRepositoryBuilder(
    persistentStorageKey:
        '${Uri.encodeComponent(config.url)}_autocomplete_cache_v3',
    persistentStaleDuration: const Duration(days: 1),
    autocomplete: (query) async {
      final tags = await client.getAutocomplete(query: query.toLowerCase());

      return tags
          .where((e) =>
              e.type !=
              'Meta') // Can't search posts by meta tags for some reason
          .map((e) => AutocompleteData(
                label: e.value?.toLowerCase() ?? '',
                value: e.value?.toLowerCase() ?? '',
                postCount: e.total,
                antecedent: e.alias?.toLowerCase().replaceAll(' ', '_'),
                category: e.type?.toLowerCase().replaceAll(' ', '_') ?? '',
              ))
          .toList();
    },
  );
});

final zerochanTagsFromIdProvider =
    FutureProvider.autoDispose.family<List<Tag>, int>(
  (ref, id) async {
    final config = ref.watchConfig;
    final client = ref.watch(zerochanClientProvider(config));

    final data = await client.getTagsFromPostId(postId: id);

    return data
        .where((e) => e.value != null)
        .map((e) => Tag.noCount(
              name: e.value!.toLowerCase().replaceAll(' ', '_'),
              category: zerochanStringToTagCategory(e.type),
            ))
        .toList();
  },
);

TagCategory zerochanStringToTagCategory(String? value) {
  // remove ' fav' and ' primary' from the end of the string
  final type = value?.toLowerCase().replaceAll(RegExp(r' fav$| primary$'), '');

  return switch (type) {
    'mangaka' || 'artist' || 'studio' => TagCategory.artist(),
    'series' ||
    'copyright' ||
    'game' ||
    'visual novel' =>
      TagCategory.copyright(),
    'character' => TagCategory.character(),
    'meta' || 'source' => TagCategory.meta(),
    _ => TagCategory.general(),
  };
}
