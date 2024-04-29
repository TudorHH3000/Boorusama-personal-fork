// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/clients/danbooru/types/tag_category.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/string.dart';
import 'package:boorusama/time.dart';
import 'package:boorusama/widgets/widgets.dart';

class InformationSection extends ConsumerWidget {
  const InformationSection({
    super.key,
    this.padding,
    this.characterTags = const {},
    this.artistTags = const {},
    this.copyrightTags = const {},
    this.createdAt,
    this.source,
    this.onArtistTagTap,
    this.showSource = false,
  });

  final EdgeInsetsGeometry? padding;
  final bool showSource;
  final Set<String> characterTags;
  final Set<String> artistTags;
  final Set<String> copyrightTags;
  final DateTime? createdAt;
  final PostSource? source;

  final void Function(BuildContext context, String artist)? onArtistTagTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding:
          padding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  characterTags.isEmpty
                      ? 'Original'
                      : generateCharacterOnlyReadableName(characterTags)
                          .replaceUnderscoreWithSpace()
                          .titleCase,
                  overflow: TextOverflow.fade,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  softWrap: false,
                ),
                const SizedBox(height: 5),
                if (copyrightTags.isNotEmpty)
                  Text(
                    generateCopyrightOnlyReadableName(copyrightTags)
                        .replaceUnderscoreWithSpace()
                        .titleCase,
                    overflow: TextOverflow.fade,
                    style: context.textTheme.bodyLarge,
                    maxLines: 1,
                    softWrap: false,
                  ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    if (artistTags.isNotEmpty)
                      ArtistNameInfoChip(
                        artistTags: artistTags,
                        onTap: (artist) =>
                            onArtistTagTap?.call(context, artist),
                      ),
                    if (artistTags.isNotEmpty) const SizedBox(width: 5),
                    if (createdAt != null)
                      Text(
                        createdAt!
                            .fuzzify(locale: Localizations.localeOf(context)),
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context
                              .theme.listTileTheme.subtitleTextStyle?.color,
                        ),
                      ),
                  ],
                )
              ],
            ),
          ),
          if (source != null && showSource)
            source!.whenWeb(
              (source) => GestureDetector(
                onTap: () => launchExternalUrl(source.uri),
                child: WebsiteLogo(
                  url: source.faviconUrl,
                ),
              ),
              () => const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }
}

String chooseArtistTag(Set<String> artistTags) {
  if (artistTags.isEmpty) return 'Unknown artist';

  final excludedTags = {
    'banned_artist',
    'voice_actor',
  };

  // find the first artist name that not contains excludedTags
  final artist = artistTags.firstWhereOrNull(
    (tag) => !excludedTags.any(tag.contains),
  );

  return artist ?? 'Unknown artist';
}

class ArtistNameInfoChip extends ConsumerWidget {
  const ArtistNameInfoChip({
    super.key,
    required this.artistTags,
    this.onTap,
  });

  final Set<String> artistTags;
  final void Function(String artist)? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artist = chooseArtistTag(artistTags);
    final colors = context.generateChipColors(
      ref.getTagColor(
        context,
        tagCategoryToString(TagCategory.artist),
      ),
      ref.watch(settingsProvider),
    );

    return Flexible(
      child: CompactChip(
        textColor: colors?.foregroundColor,
        label: artist.replaceUnderscoreWithSpace(),
        onTap: () => onTap?.call(artist),
        backgroundColor: colors?.backgroundColor,
      ),
    );
  }
}

class SimpleInformationSection extends ConsumerWidget {
  const SimpleInformationSection({
    super.key,
    required this.post,
    this.padding,
    this.showSource = false,
  });

  final EdgeInsetsGeometry? padding;
  final bool showSource;
  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruBuilder = ref.watch(booruBuilderProvider);
    final supportArtist = booruBuilder?.isArtistSupported ?? false;

    return InformationSection(
      characterTags: post.characterTags ?? {},
      artistTags: post.artistTags ?? {},
      copyrightTags: post.copyrightTags ?? {},
      createdAt: post.createdAt,
      source: post.source,
      showSource: showSource,
      onArtistTagTap: supportArtist
          ? (context, artist) => goToArtistPage(context, artist)
          : null,
    );
  }
}
