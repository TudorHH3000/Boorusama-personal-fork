// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/danbooru.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru.dart';
import 'package:boorusama/boorus/gelbooru_v1/create_gelbooru_v1_config_page.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/clients/gelbooru/gelbooru_client.dart';
import 'package:boorusama/clients/gelbooru/gelbooru_v1_client.dart';
import 'package:boorusama/core/autocompletes/autocomplete.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/foundation/html.dart';
import 'package:boorusama/foundation/networking/networking.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/widgets/info_container.dart';

part 'providers.dart';

class GelbooruV1Builder
    with
        FavoriteNotSupportedMixin,
        PostCountNotSupportedMixin,
        ArtistNotSupportedMixin,
        CharacterNotSupportedMixin,
        CommentNotSupportedMixin,
        NoteNotSupportedMixin,
        UnknownMetatagsMixin,
        DefaultMultiSelectionActionsBuilderMixin,
        DefaultDownloadFileUrlExtractorMixin,
        DefaultHomeMixin,
        DefaultThumbnailUrlMixin,
        DefaultTagColorMixin,
        DefaultPostImageDetailsUrlMixin,
        DefaultPostGesturesHandlerMixin,
        DefaultGranularRatingFiltererMixin,
        LegacyGranularRatingOptionsBuilderMixin,
        DefaultPostStatisticsPageBuilderMixin,
        DefaultBooruUIMixin
    implements BooruBuilder {
  GelbooruV1Builder({
    required this.postRepo,
    required this.client,
  });

  final PostRepository postRepo;
  final GelbooruClient client;

  @override
  AutocompleteFetcher get autocompleteFetcher =>
      (tags) => client.autocomplete(term: tags).then((value) => value
          .map((e) => AutocompleteData(
                label: e.label ?? '<Unknown>',
                value: e.value ?? '<Unknown>',
              ))
          .toList());

  @override
  CreateConfigPageBuilder get createConfigPageBuilder => (
        context,
        url,
        booruType, {
        backgroundColor,
      }) =>
          CreateGelbooruV1ConfigPage(
            config: BooruConfig.defaultConfig(
              booruType: booruType,
              url: url,
              customDownloadFileNameFormat:
                  kGelbooruCustomDownloadFileNameFormat,
            ),
            backgroundColor: backgroundColor,
            isNewConfig: true,
          );

  @override
  UpdateConfigPageBuilder get updateConfigPageBuilder => (
        context,
        config, {
        backgroundColor,
        initialTab,
      }) =>
          CreateGelbooruV1ConfigPage(
            config: config,
            backgroundColor: backgroundColor,
            initialTab: initialTab,
          );

  @override
  SearchPageBuilder get searchPageBuilder =>
      (context, initialQuery) => GelbooruV1SearchPage(
            initialQuery: initialQuery,
          );

  @override
  PostFetcher get postFetcher => (page, tags) => TaskEither.Do(($) async {
        final posts = await $(postRepo.getPosts(tags, page));

        return posts;
      });

  @override
  late final DownloadFilenameGenerator downloadFilenameBuilder =
      DownloadFileNameBuilder(
    downloadFileUrlExtractor: downloadFileUrlExtractor,
    defaultFileNameFormat: kGelbooruCustomDownloadFileNameFormat,
    defaultBulkDownloadFileNameFormat: kGelbooruCustomDownloadFileNameFormat,
    sampleData: kDanbooruPostSamples,
    tokenHandlers: {
      'source': (post, config) => config.downloadUrl,
    },
  );
}

class GelbooruV1SearchPage extends ConsumerWidget {
  const GelbooruV1SearchPage({
    super.key,
    required this.initialQuery,
  });

  final String? initialQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruBuilder = ref.watch(booruBuilderProvider);

    return SearchPageScaffold(
      noticeBuilder: (context) => InfoContainer(
        contentBuilder: (context) => const AppHtml(
          data: 'The app will use <b>Gelbooru</b> for tag completion.',
        ),
      ),
      initialQuery: initialQuery,
      fetcher: (page, controller) =>
          booruBuilder?.postFetcher.call(page, controller.rawTagsString) ??
          TaskEither.of(<Post>[].toResult()),
    );
  }
}
