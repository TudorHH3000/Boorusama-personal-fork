// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/core/boorus.dart';
import 'package:boorusama/core/boorus/providers.dart';
import 'package:boorusama/core/configs/ref.dart';
import 'package:boorusama/core/tags/categories/providers.dart';
import 'package:boorusama/core/tags/categories/store.dart';
import 'package:boorusama/core/tags/categories/tag_category.dart';
import 'package:boorusama/core/tags/tag/tag.dart';
import 'ai_tag.dart';

final danbooruAITagsProvider = FutureProvider.family<List<AITag>, int>(
  (ref, postId) async {
    final config = ref.watchConfigAuth;
    final booru =
        ref.watch(booruFactoryProvider).create(type: config.booruType);
    final aiTagSupport = booru?.hasAiTagSupported(config.url);

    if (aiTagSupport == null || !aiTagSupport) return [];

    final client = ref.watch(danbooruClientProvider(config));

    final tags =
        await client.getAITags(query: 'id:$postId').then((value) => value
            .map((e) => AITag(
                  score: e.score ?? 0,
                  tag: Tag(
                    name: e.tag?.name ?? '',
                    category: TagCategory.fromLegacyId(e.tag?.category),
                    postCount: e.tag?.postCount ?? 0,
                  ),
                ))
            .where((e) => e.tag.postCount > 0)
            .where((e) => !e.tag.name.startsWith('rating:'))
            .toList());

    await ref.read(booruTagTypeStoreProvider).saveTagIfNotExist(
          config.booruType,
          tags.map((e) => e.tag).toList(),
        );

    return tags;
  },
);
