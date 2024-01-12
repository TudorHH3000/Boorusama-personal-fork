// Project imports:
import 'package:boorusama/boorus/danbooru/feats/pools/pools.dart';
import 'package:boorusama/foundation/caching/caching.dart';

abstract class PoolRepository {
  Future<List<Pool>> getPools(
    int page, {
    PoolCategory? category,
    PoolOrder? order,
    String? name,
    String? description,
  });
  Future<List<Pool>> getPoolsByPostId(int postId);
}

class PoolRepositoryBuilder
    with SimpleCacheMixin<List<Pool>>
    implements PoolRepository {
  PoolRepositoryBuilder({
    required this.fetchMany,
    required this.fetchByPostId,
    int maxCapacity = 1000,
    Duration staleDuration = const Duration(minutes: 10),
  }) {
    cache = Cache(
      maxCapacity: maxCapacity,
      staleDuration: staleDuration,
    );
  }

  final Future<List<Pool>> Function(
    int page, {
    PoolCategory? category,
    PoolOrder? order,
    String? name,
    String? description,
  }) fetchMany;

  final Future<List<Pool>> Function(int postId) fetchByPostId;

  @override
  Future<List<Pool>> getPools(
    int page, {
    PoolCategory? category,
    PoolOrder? order,
    String? name,
    String? description,
  }) =>
      fetchMany(
        page,
        category: category,
        order: order,
        name: name,
        description: description,
      );

  @override
  Future<List<Pool>> getPoolsByPostId(int postId) => tryGet(
        'pool-by-post-$postId',
        orElse: () => fetchByPostId(postId),
      );

  @override
  late Cache<List<Pool>> cache;
}
