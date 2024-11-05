// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/danbooru.dart';
import 'package:boorusama/boorus/gelbooru_v2/artists/artists.dart';
import 'package:boorusama/boorus/gelbooru_v2/comments/comments.dart';
import 'package:boorusama/boorus/gelbooru_v2/posts/posts_v2.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/clients/gelbooru/gelbooru_v2_client.dart';
import 'package:boorusama/clients/gelbooru/types/note_dto.dart';
import 'package:boorusama/core/autocompletes/autocompletes.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/create/create.dart';
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/core/notes/notes.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/foundation/networking/networking.dart';
import 'create_gelbooru_v2_config_page.dart';
import 'home/gelbooru_v2_home_page.dart';
import 'posts/gelbooru_v2_post_details_desktop_page.dart';
import 'posts/gelbooru_v2_post_details_page.dart';

const kGelbooruV2CustomDownloadFileNameFormat =
    '{id}_{md5:maxlength=8}.{extension}';

final gelbooruV2ClientProvider =
    Provider.family<GelbooruV2Client, BooruConfig>((ref, booruConfig) {
  final dio = newDio(ref.watch(dioArgsProvider(booruConfig)));

  return GelbooruV2Client.custom(
    baseUrl: booruConfig.url,
    login: booruConfig.login,
    apiKey: booruConfig.apiKey,
    dio: dio,
  );
});

final gelbooruV2AutocompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfig>((ref, config) {
  final client = ref.watch(gelbooruV2ClientProvider(config));

  return AutocompleteRepositoryBuilder(
    autocomplete: (query) async {
      final dtos = await client.autocomplete(term: query, limit: 20);

      return dtos
          .map((e) {
            try {
              return AutocompleteData(
                type: e.type,
                label: e.label?.replaceAll('_', ' ') ?? '<empty>',
                value: e.value!,
                category: e.category?.toString(),
                postCount: e.postCount,
              );
            } catch (err) {
              return AutocompleteData.empty;
            }
          })
          .where((e) => e != AutocompleteData.empty)
          .toList();
    },
    persistentStorageKey:
        '${Uri.encodeComponent(config.url)}_autocomplete_cache_v1',
  );
});

final gelbooruV2TagsFromIdProvider =
    FutureProvider.autoDispose.family<List<Tag>, int>(
  (ref, id) async {
    final config = ref.watchConfig;
    final client = ref.watch(gelbooruV2ClientProvider(config));

    final data = await client.getTagsFromPostId(postId: id);

    return data
        .map((e) => Tag(
              name: e.name ?? '',
              category: TagCategory.fromLegacyId(e.type),
              postCount: e.count ?? 0,
            ))
        .toList();
  },
);

final gelbooruV2NoteRepoProvider =
    Provider.family<NoteRepository, BooruConfig>((ref, config) {
  final client = ref.watch(gelbooruV2ClientProvider(config));

  return NoteRepositoryBuilder(
    fetch: (postId) => client
        .getNotesFromPostId(
          postId: postId,
        )
        .then((value) => value.map(gelbooruV2NoteToNote).toList()),
  );
});

Note gelbooruV2NoteToNote(NoteDto note) {
  return Note(
    coordinate: NoteCoordinate(
      x: note.x?.toDouble() ?? 0,
      y: note.y?.toDouble() ?? 0,
      height: note.height?.toDouble() ?? 0,
      width: note.width?.toDouble() ?? 0,
    ),
    content: note.body ?? '',
  );
}

class GelbooruV2Builder
    with
        FavoriteNotSupportedMixin,
        DefaultThumbnailUrlMixin,
        DefaultThumbnailUrlMixin,
        PostCountNotSupportedMixin,
        UnknownMetatagsMixin,
        DefaultMultiSelectionActionsBuilderMixin,
        DefaultHomeMixin,
        DefaultPostImageDetailsUrlMixin,
        DefaultGranularRatingFiltererMixin,
        DefaultPostGesturesHandlerMixin,
        DefaultPostStatisticsPageBuilderMixin,
        DefaultTagColorMixin
    implements BooruBuilder {
  GelbooruV2Builder({
    required this.client,
  });

  final GelbooruV2Client client;

  @override
  CreateConfigPageBuilder get createConfigPageBuilder => (
        context,
        id, {
        backgroundColor,
      }) =>
          CreateBooruConfigScope(
            id: id,
            config: BooruConfig.defaultConfig(
              booruType: id.booruType,
              url: id.url,
              customDownloadFileNameFormat:
                  kGelbooruV2CustomDownloadFileNameFormat,
            ),
            child: CreateGelbooruV2ConfigPage(
              backgroundColor: backgroundColor,
            ),
          );

  @override
  HomePageBuilder get homePageBuilder =>
      (context, config) => GelbooruV2HomePage(config: config);

  @override
  UpdateConfigPageBuilder get updateConfigPageBuilder => (
        context,
        id, {
        backgroundColor,
        initialTab,
      }) =>
          UpdateBooruConfigScope(
            id: id,
            child: CreateGelbooruV2ConfigPage(
              backgroundColor: backgroundColor,
              initialTab: initialTab,
            ),
          );

  @override
  SearchPageBuilder get searchPageBuilder => (context, initialQuery) =>
      GelbooruV2SearchPage(initialQuery: initialQuery);

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder =>
      (context, config, payload) {
        final posts = payload.posts.map((e) => e as GelbooruV2Post).toList();

        return PostDetailsLayoutSwitcher(
          initialIndex: payload.initialIndex,
          posts: posts,
          scrollController: payload.scrollController,
          desktop: (controller) => GelbooruV2PostDetailsDesktopPage(
            initialIndex: controller.currentPage.value,
            posts: posts,
            onExit: (page) => controller.onExit(page),
            onPageChanged: (page) => controller.setPage(page),
          ),
          mobile: (controller) => GelbooruV2PostDetailsPage(
            initialIndex: controller.currentPage.value,
            controller: controller,
            posts: posts,
            onExit: (page) => controller.onExit(page),
            onPageChanged: (page) => controller.setPage(page),
          ),
        );
      };

  @override
  FavoritesPageBuilder? get favoritesPageBuilder =>
      (context, config) => config.hasLoginDetails()
          ? GelbooruV2FavoritesPage(uid: config.login!)
          : const Scaffold(
              body: Center(
                child: Text(
                    'You need to provide login details to use this feature.'),
              ),
            );

  @override
  ArtistPageBuilder? get artistPageBuilder =>
      (context, artistName) => GelbooruV2ArtistPage(
            artistName: artistName,
          );

  @override
  CharacterPageBuilder? get characterPageBuilder =>
      (context, characterName) => GelbooruV2ArtistPage(
            artistName: characterName,
          );

  @override
  CommentPageBuilder? get commentPageBuilder =>
      (context, useAppBar, postId) => GelbooruV2CommentPage(
            postId: postId,
            useAppBar: useAppBar,
          );

  @override
  GranularRatingOptionsBuilder? get granularRatingOptionsBuilder => () => {
        Rating.explicit,
        Rating.questionable,
        Rating.sensitive,
      };

  @override
  final DownloadFilenameGenerator downloadFilenameBuilder =
      DownloadFileNameBuilder(
    defaultFileNameFormat: kGelbooruV2CustomDownloadFileNameFormat,
    defaultBulkDownloadFileNameFormat: kGelbooruV2CustomDownloadFileNameFormat,
    sampleData: kDanbooruPostSamples,
    tokenHandlers: {
      'width': (post, config) => post.width.toString(),
      'height': (post, config) => post.height.toString(),
      'mpixels': (post, config) => post.mpixels.toString(),
      'aspect_ratio': (post, config) => post.aspectRatio.toString(),
      'source': (post, config) => config.downloadUrl,
    },
  );
}

class GelbooruV2SearchPage extends ConsumerWidget {
  const GelbooruV2SearchPage({
    super.key,
    this.initialQuery,
  });

  final String? initialQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    return SearchPageScaffold(
      initialQuery: initialQuery,
      fetcher: (page, controller) => ref
          .watch(gelbooruV2PostRepoProvider(config))
          .getPosts(controller.rawTagsString, page),
    );
  }
}

class GelbooruV2FavoritesPage extends ConsumerWidget {
  const GelbooruV2FavoritesPage({
    super.key,
    required this.uid,
  });

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    final query = 'fav:$uid';

    return FavoritesPageScaffold(
      favQueryBuilder: () => query,
      fetcher: (page) =>
          ref.read(gelbooruV2PostRepoProvider(config)).getPosts(query, page),
    );
  }
}
