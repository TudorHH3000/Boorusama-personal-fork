// Package imports:

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/danbooru.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/explores/explores.dart';
import 'package:boorusama/boorus/danbooru/posts/posts.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/blacklists/blacklists.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/manage/manage.dart';
import 'package:boorusama/core/datetimes/datetimes.dart';
import 'package:boorusama/core/posts/posts.dart';

typedef ScaleAndTime = ({
  TimeScale scale,
  DateTime date,
});

final timeScaleProvider = StateProvider<TimeScale>((ref) => TimeScale.day);
final dateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final timeAndDateProvider = Provider<ScaleAndTime>((ref) {
  final timeScale = ref.watch(timeScaleProvider);
  final date = ref.watch(dateProvider);

  return (scale: timeScale, date: date);
}, dependencies: [
  timeScaleProvider,
  dateProvider,
]);

final danbooruExploreRepoProvider =
    Provider.family<ExploreRepository, BooruConfigSearch>(
  (ref, config) {
    return ExploreRepositoryCacher(
      repository: ExploreRepositoryApi(
        transformer: (posts) => transformPosts(ref, posts, config),
        client: ref.watch(danbooruClientProvider(config.auth)),
        postRepository: ref.watch(danbooruPostRepoProvider(config)),
        settings: () => ref.read(imageListingSettingsProvider),
        shouldFilter: (post) {
          // A special rule for safebooru to make sure inappropriate posts are not shown
          if (config.auth.url == kDanbooruSafeUrl) {
            return post.rating != Rating.general;
          }

          final filterer =
              ref.read(currentBooruBuilderProvider)?.granularRatingFilterer;

          if (filterer == null) return false;

          return filterer(post, config);
        },
      ),
      popularStaleDuration: const Duration(seconds: 10),
      mostViewedStaleDuration: const Duration(seconds: 30),
      hotStaleDuration: const Duration(seconds: 5),
    );
  },
  dependencies: [
    danbooruClientProvider,
    danbooruPostRepoProvider,
    settingsRepoProvider,
    globalBlacklistedTagRepoProvider,
    currentBooruConfigProvider,
  ],
);

final danbooruMostViewedTodayProvider =
    FutureProvider<PostResult<DanbooruPost>>((ref) async {
  final repo = ref
      .watch(danbooruExploreRepoProvider(ref.watchConfigSearch))
      .getMostViewedPosts(DateTime.now());

  return repo.run().then((value) => value.fold(
        (l) => <DanbooruPost>[].toResult(),
        (r) => r,
      ));
});

final danbooruPopularTodayProvider =
    FutureProvider<PostResult<DanbooruPost>>((ref) async {
  final repo = ref
      .watch(danbooruExploreRepoProvider(ref.watchConfigSearch))
      .getPopularPosts(DateTime.now(), 1, TimeScale.day);

  return repo.run().then((value) => value.fold(
        (l) => <DanbooruPost>[].toResult(),
        (r) => r,
      ));
});

final danbooruHotTodayProvider =
    FutureProvider<PostResult<DanbooruPost>>((ref) async {
  final repo = ref
      .watch(danbooruExploreRepoProvider(ref.watchConfigSearch))
      .getHotPosts(1);

  return repo.run().then((value) => value.fold(
        (l) => <DanbooruPost>[].toResult(),
        (r) => r,
      ));
});
