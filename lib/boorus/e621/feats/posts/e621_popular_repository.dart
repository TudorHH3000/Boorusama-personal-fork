// Project imports:
import 'package:boorusama/boorus/e621/feats/posts/posts.dart';
import 'package:boorusama/clients/e621/e621_client.dart';
import 'package:boorusama/clients/e621/types/types.dart' as e;
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/core/feats/types.dart';
import 'package:boorusama/foundation/caching/caching.dart';
import 'package:boorusama/foundation/http/http.dart';
import 'package:boorusama/functional.dart';

abstract interface class E621PopularRepository {
  PostsOrError<E621Post> getPopularPosts(DateTime date, TimeScale timeScale);
}

class E621PopularRepositoryApi
    with SettingsRepositoryMixin
    implements E621PopularRepository {
  E621PopularRepositoryApi(
    this.client,
    this.booruConfig,
    this.settingsRepository,
  );

  final E621Client client;
  final BooruConfig booruConfig;

  @override
  final SettingsRepository settingsRepository;
  final Cache<List<E621Post>> _cache = Cache(
    maxCapacity: 5,
    staleDuration: const Duration(seconds: 10),
  );

  String _buildKey(String date, String scale) => '$date-$scale';

  @override
  PostsOrError<E621Post> getPopularPosts(DateTime date, TimeScale timeScale) =>
      TaskEither.Do(($) async {
        final dateString = dateToE621Date(date);
        final timeScaleString = timeScaleToE621TimeScale(timeScale);
        final key = _buildKey(dateString, timeScaleString);
        final cached = _cache.get(key);

        if (cached != null && cached.isNotEmpty) return cached;

        final response = await $(tryFetchRemoteData(
          fetcher: () => client.getPopularPosts(
            date: date,
            scale: switch (timeScale) {
              TimeScale.day => e.TimeScale.day,
              TimeScale.week => e.TimeScale.week,
              TimeScale.month => e.TimeScale.month,
            },
          ),
        ));

        final data = response.map(postDtoToPostNoMetadata).toList();

        final filteredNoImage = filterPostWithNoImage(data);

        _cache.set(key, filteredNoImage);

        return filteredNoImage;
      });
}

String dateToE621Date(DateTime date) =>
    '${date.year}-${date.month}-${date.day}';

String timeScaleToE621TimeScale(TimeScale timeScale) => timeScale.name;

List<E621Post> filterPostWithNoImage(List<E621Post> posts) =>
    posts.where((post) => !post.hasNoImage).toList();
