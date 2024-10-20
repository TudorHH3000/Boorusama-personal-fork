// Project imports:
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/search/search.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/foundation/caching/caching.dart';
import 'package:boorusama/functional.dart';
import 'danbooru_post.dart';

class DanbooruArtistCharacterPostRepository
    implements PostRepository<DanbooruPost> {
  DanbooruArtistCharacterPostRepository({
    required this.repository,
    required this.cache,
  });

  final PostRepository<DanbooruPost> repository;
  final Cacher<String, List<DanbooruPost>> cache;
  @override
  TagQueryComposer get tagComposer => repository.tagComposer;

  @override
  PostsOrError<DanbooruPost> getPosts(
    String tags,
    int page, {
    int? limit,
  }) {
    final tagString = tags;
    final name = '$tagString-$page-$limit';

    return cache.get(name).toOption().fold(
          () => repository
              .getPosts(
                tags,
                page,
                limit: limit,
              )
              .flatMap((r) => TaskEither(() async {
                    await cache.put(name, r.posts);
                    return Either.of(r);
                  })),
          (data) => TaskEither.right(data.toResult()),
        );
  }

  @override
  PostsOrError<DanbooruPost> getPostsFromController(
          SelectedTagController controller, int page,
          {int? limit}) =>
      repository.getPostsFromController(controller, page, limit: limit);
}
