// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tags_x/flutter_tags_x.dart' hide TagsState;

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/e621/feats/posts/posts.dart';
import 'package:boorusama/boorus/e621/feats/tags/e621_tag_category.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/string.dart';
import 'package:boorusama/utils/color_utils.dart';
import 'package:boorusama/widgets/widgets.dart';

typedef E621TagGroup = ({
  String groupName,
  E621TagCategory category,
  List<String> tags,
});

class E621PostTagList extends ConsumerWidget {
  const E621PostTagList({
    super.key,
    this.maxTagWidth,
    required this.post,
  });

  final double? maxTagWidth;
  final E621Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booru = ref.watchConfig;
    final tags = <E621TagGroup>[
      if (post.artistTags.isNotEmpty)
        (
          groupName: 'Artist',
          category: E621TagCategory.artist,
          tags: post.artistTags.toList(),
        ),
      if (post.characterTags.isNotEmpty)
        (
          groupName: 'Character',
          category: E621TagCategory.character,
          tags: post.characterTags.toList(),
        ),
      if (post.copyrightTags.isNotEmpty)
        (
          groupName: 'Copyright',
          category: E621TagCategory.copyright,
          tags: post.copyrightTags.toList(),
        ),
      if (post.speciesTags.isNotEmpty)
        (
          groupName: 'Species',
          category: E621TagCategory.species,
          tags: post.speciesTags.toList(),
        ),
      if (post.generalTags.isNotEmpty)
        (
          groupName: 'General',
          category: E621TagCategory.general,
          tags: post.generalTags.toList(),
        ),
      if (post.metaTags.isNotEmpty)
        (
          groupName: 'Meta',
          category: E621TagCategory.meta,
          tags: post.metaTags.toList(),
        ),
    ];

    final widgets = <Widget>[];
    for (final g in tags) {
      widgets
        ..add(_TagBlockTitle(
          title: g.groupName,
          isFirstBlock: g.groupName == tags.first.groupName,
        ))
        ..add(_buildTags(
          context,
          ref,
          booru,
          g,
        ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...widgets,
      ],
    );
  }

  Widget _buildTags(
    BuildContext context,
    WidgetRef ref,
    BooruConfig config,
    E621TagGroup group,
  ) {
    return Tags(
      alignment: WrapAlignment.start,
      spacing: 4,
      runSpacing: 6,
      itemCount: group.tags.length,
      itemBuilder: (index) {
        final tag = group.tags[index];

        return ContextMenu<String>(
          items: [
            PopupMenuItem(
              value: 'wiki',
              child: const Text('post.detail.open_wiki').tr(),
            ),
            PopupMenuItem(
              value: 'add_to_favorites',
              child: const Text('post.detail.add_to_favorites').tr(),
            ),
          ],
          onSelected: (value) {
            if (value == 'wiki') {
              launchWikiPage(config.url, tag);
            } else if (value == 'add_to_favorites') {
              ref.read(favoriteTagsProvider.notifier).add(tag);
            }
          },
          child: _Chip(
            tag: tag,
            onTap: () => goToSearchPage(context, tag: tag),
            tagColor: ref.getTagColor(context, group.category.name),
            maxTagWidth: maxTagWidth,
          ),
        );
      },
    );
  }
}

class _Chip extends ConsumerWidget {
  const _Chip({
    required this.tag,
    required this.maxTagWidth,
    this.tagColor,
    this.onTap,
  });

  final String tag;
  final Color? tagColor;
  final double? maxTagWidth;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.generateChipColors(
      tagColor,
      ref.watch(settingsProvider),
    );

    return RawCompactChip(
      onTap: onTap,
      foregroundColor: colors?.foregroundColor,
      backgroundColor: colors?.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: colors != null
            ? BorderSide(
                color: colors.borderColor,
                width: 1,
              )
            : BorderSide.none,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      label: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxTagWidth ?? context.screenWidth * 0.7,
        ),
        child: Text(
          _getTagStringDisplayName(tag.replaceUnderscoreWithSpace()),
          overflow: TextOverflow.fade,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colors?.backgroundColor.isWhite == true
                ? Colors.black
                : colors?.foregroundColor,
          ),
        ),
      ),
    );
  }
}

String _getTagStringDisplayName(String tag) =>
    tag.length > 30 ? '${tag.substring(0, 30)}...' : tag;

class _TagBlockTitle extends StatelessWidget {
  const _TagBlockTitle({
    required this.title,
    this.isFirstBlock = false,
  });

  final bool isFirstBlock;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 8,
        ),
        _TagHeader(
          title: title,
        ),
        const SizedBox(
          height: 4,
        ),
      ],
    );
  }
}

class _TagHeader extends StatelessWidget {
  const _TagHeader({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Text(
        title,
        style:
            context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w900),
      ),
    );
  }
}
