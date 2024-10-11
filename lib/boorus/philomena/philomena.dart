// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/danbooru.dart';
import 'package:boorusama/boorus/gelbooru_v2/gelbooru_v2.dart';
import 'package:boorusama/boorus/philomena/create_philomena_config_page.dart';
import 'package:boorusama/core/artists/artists.dart';
import 'package:boorusama/core/autocompletes/autocompletes.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/router.dart';
import 'philomena_post.dart';

class PhilomenaBuilder
    with
        FavoriteNotSupportedMixin,
        PostCountNotSupportedMixin,
        NoteNotSupportedMixin,
        DefaultThumbnailUrlMixin,
        CommentNotSupportedMixin,
        ArtistNotSupportedMixin,
        CharacterNotSupportedMixin,
        LegacyGranularRatingOptionsBuilderMixin,
        UnknownMetatagsMixin,
        DefaultMultiSelectionActionsBuilderMixin,
        DefaultDownloadFileUrlExtractorMixin,
        DefaultHomeMixin,
        DefaultGranularRatingFiltererMixin,
        DefaultPostGesturesHandlerMixin,
        DefaultPostStatisticsPageBuilderMixin,
        DefaultBooruUIMixin
    implements BooruBuilder {
  PhilomenaBuilder({
    required this.postRepo,
    required this.autocompleteRepo,
  });

  final PostRepository postRepo;
  final AutocompleteRepository autocompleteRepo;

  @override
  AutocompleteFetcher get autocompleteFetcher =>
      (query) => autocompleteRepo.getAutocomplete(query);

  @override
  CreateConfigPageBuilder get createConfigPageBuilder => (
        context,
        url,
        booruType, {
        backgroundColor,
      }) =>
          CreatePhilomenaConfigPage(
            config: BooruConfig.defaultConfig(
              booruType: booruType,
              url: url,
              customDownloadFileNameFormat: null,
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
          CreatePhilomenaConfigPage(
            config: config,
            backgroundColor: backgroundColor,
            initialTab: initialTab,
          );

  @override
  PostFetcher get postFetcher => (page, tags) => postRepo.getPosts(tags, page);

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder =>
      (context, config, payload) => PhilomenaPostDetailsPage(payload: payload);

  @override
  TagColorBuilder get tagColorBuilder =>
      (brightness, tagType) => switch (tagType) {
            'error' => brightness.isDark
                ? const Color.fromARGB(255, 212, 84, 96)
                : const Color.fromARGB(255, 173, 38, 63),
            'rating' => brightness.isDark
                ? const Color.fromARGB(255, 64, 140, 217)
                : const Color.fromARGB(255, 65, 124, 169),
            'origin' => brightness.isDark
                ? const Color.fromARGB(255, 111, 100, 224)
                : const Color.fromARGB(255, 56, 62, 133),
            'oc' => brightness.isDark
                ? const Color.fromARGB(255, 176, 86, 182)
                : const Color.fromARGB(255, 176, 86, 182),
            'character' => brightness.isDark
                ? const Color.fromARGB(255, 73, 170, 190)
                : const Color.fromARGB(255, 46, 135, 119),
            'species' => brightness.isDark
                ? const Color.fromARGB(255, 176, 106, 80)
                : const Color.fromARGB(255, 131, 87, 54),
            'content-official' => brightness.isDark
                ? const Color.fromARGB(255, 185, 180, 65)
                : const Color.fromARGB(255, 151, 142, 27),
            'content-fanmade' => brightness.isDark
                ? const Color.fromARGB(255, 204, 143, 180)
                : const Color.fromARGB(255, 174, 90, 147),
            _ => brightness.isDark
                ? Colors.green
                : const Color.fromARGB(255, 111, 143, 13),
          };

  @override
  late final DownloadFilenameGenerator<Post> downloadFilenameBuilder =
      DownloadFileNameBuilder<Post>(
    downloadFileUrlExtractor: downloadFileUrlExtractor,
    defaultFileNameFormat: kGelbooruV2CustomDownloadFileNameFormat,
    defaultBulkDownloadFileNameFormat: kGelbooruV2CustomDownloadFileNameFormat,
    sampleData: kDanbooruPostSamples,
    hasRating: false,
    tokenHandlers: {
      'width': (post, config) => post.width.toString(),
      'height': (post, config) => post.height.toString(),
      'source': (post, config) => post.source.url,
    },
  );

  @override
  PostImageDetailsUrlBuilder get postImageDetailsUrlBuilder => (imageQuality,
          rawPost, config) =>
      castOrNull<PhilomenaPost>(rawPost).toOption().fold(
            () => rawPost.sampleImageUrl,
            (post) => config.imageDetaisQuality.toOption().fold(
                () => post.sampleImageUrl,
                (quality) =>
                    switch (stringToPhilomenaPostQualityType(quality)) {
                      PhilomenaPostQualityType.full => post.representation.full,
                      PhilomenaPostQualityType.large =>
                        post.representation.large,
                      PhilomenaPostQualityType.medium =>
                        post.representation.medium,
                      PhilomenaPostQualityType.tall => post.representation.tall,
                      PhilomenaPostQualityType.small =>
                        post.representation.small,
                      PhilomenaPostQualityType.thumb =>
                        post.representation.thumb,
                      PhilomenaPostQualityType.thumbSmall =>
                        post.representation.thumbSmall,
                      PhilomenaPostQualityType.thumbTiny =>
                        post.representation.thumbTiny,
                      null => post.representation.small,
                    }),
          );
}

class PhilomenaPostDetailsPage extends ConsumerWidget {
  const PhilomenaPostDetailsPage({
    super.key,
    required this.payload,
  });

  final DetailsPayload payload;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PostDetailsPageScaffold(
      posts: payload.posts,
      initialIndex: payload.initialIndex,
      artistInfoBuilder: (context, post) => ArtistSection(
        commentary: post is PhilomenaPost
            ? ArtistCommentary.description(post.description)
            : const ArtistCommentary.empty(),
        artistTags: post.artistTags ?? {},
        source: post.source,
      ),
      swipeImageUrlBuilder: defaultPostImageUrlBuilder(ref),
      infoBuilder: (context, post) => SimpleInformationSection(post: post),
      statsTileBuilder: (context, rawPost) =>
          castOrNull<PhilomenaPost>(rawPost).toOption().fold(
                () => const SizedBox(),
                (post) => SimplePostStatsTile(
                  totalComments: post.commentCount,
                  favCount: post.favCount,
                  score: post.score,
                  votePercentText: _generatePercentText(post),
                ),
              ),
      onExit: (page) => payload.scrollController?.scrollToIndex(page),
    );
  }
}

String _generatePercentText(PhilomenaPost? post) {
  if (post == null) return '';
  final percent = post.score > 0 ? (post.upvotes / post.score) : 0;
  return post.score > 0 ? '(${(percent * 100).toInt()}% upvoted)' : '';
}
