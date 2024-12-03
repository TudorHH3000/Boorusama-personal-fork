// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/tags/tags.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/tags/tags.dart';

class TrendingTagNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<Search>, BooruConfigAuth> {
  @override
  FutureOr<List<Search>> build(BooruConfigAuth arg) {
    return fetch();
  }

  PopularSearchRepository get popularSearchRepository =>
      ref.read(popularSearchProvider(arg));

  Future<List<Search>> fetch() async {
    final bl = await ref.read(blacklistTagsProvider(arg).future);
    final excludedTags = {
      ...ref.read(tagInfoProvider).r18Tags,
      ...bl,
    };

    var searches =
        await popularSearchRepository.getSearchByDate(DateTime.now());
    if (searches.isEmpty) {
      searches = await popularSearchRepository.getSearchByDate(
        DateTime.now().subtract(const Duration(days: 1)),
      );
    }

    final filtered =
        searches.where((s) => !excludedTags.contains(s.keyword)).toList();

    final tags = await ref
        .read(tagRepoProvider(arg))
        .getTagsByName(filtered.map((e) => e.keyword).toSet(), 1);

    await ref
        .read(booruTagTypeStoreProvider)
        .saveTagIfNotExist(arg.booruType, tags);

    return filtered;
  }
}
