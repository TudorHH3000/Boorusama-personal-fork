// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/boorus.dart';
import 'package:boorusama/core/configs.dart';
import 'package:boorusama/core/configs/manage.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/foundation/theme.dart';

final tagsProvider =
    NotifierProvider.family<TagsNotifier, List<TagGroupItem>?, BooruConfigAuth>(
  TagsNotifier.new,
  dependencies: [
    currentBooruConfigProvider,
  ],
);

final emptyTagRepoProvider =
    Provider<TagRepository>((ref) => EmptyTagRepository());

final booruTagTypeStoreProvider = Provider<BooruTagTypeStore>(
  (ref) => BooruTagTypeStore(),
);

final booruTagTypePathProvider = Provider<String?>((ref) {
  return null;
});

final booruTagTypeProvider =
    FutureProvider.autoDispose.family<String?, String>((ref, tag) async {
  final config = ref.watchConfigAuth;
  final store = ref.watch(booruTagTypeStoreProvider);
  final sanitized = tag.toLowerCase().replaceAll(' ', '_');
  final data = await store.get(config.booruType, sanitized);

  return data;
});

final tagColorProvider = Provider.family<Color?, String>(
  (ref, tag) {
    final config = ref.watchConfigAuth;

    final colorBuilder = _getCurrentConfigColorBuilder(
      tag,
      ref.watch(booruBuildersProvider),
      config,
    );

    // In case the color builder is null, which means there is no config selected
    if (colorBuilder == null) return null;

    final colorScheme = ref.watch(colorSchemeProvider);

    final color = colorBuilder(colorScheme.brightness, tag);

    final dynamicColors = ref
        .watch(settingsProvider.select((value) => value.enableDynamicColoring));

    // If dynamic colors are disabled, return the color as is
    if (!dynamicColors) return color;

    return color?.harmonizeWith(colorScheme.primary);
  },
  dependencies: [
    currentBooruConfigProvider,
    settingsProvider,
    colorSchemeProvider,
  ],
);

TagColorBuilder? _getCurrentConfigColorBuilder(
  String tag,
  Map<BooruType, BooruBuilder Function()> builders,
  BooruConfigAuth config,
) {
  final booruBuilderFunc = builders[config.booruType];
  final booruBuilder = booruBuilderFunc != null ? booruBuilderFunc() : null;

  return booruBuilder?.tagColorBuilder;
}
