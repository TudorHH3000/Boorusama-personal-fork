// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/saved_searches/saved_searches.dart';
import 'package:boorusama/core/configs/configs.dart';

final danbooruSavedSearchRepoProvider =
    Provider.family<SavedSearchRepository, BooruConfigAuth>((ref, config) {
  return SavedSearchRepositoryApi(
    ref.watch(danbooruClientProvider(config)),
  );
});

final danbooruSavedSearchesProvider = AsyncNotifierProvider.family<
    SavedSearchesNotifier, List<SavedSearch>, BooruConfigAuth>(
  SavedSearchesNotifier.new,
);
