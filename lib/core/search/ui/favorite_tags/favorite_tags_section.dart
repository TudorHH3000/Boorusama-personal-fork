// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/favorited_tags/favorited_tags.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/router.dart';
import 'import_tag_button.dart';

const kSearchSelectedFavoriteTagLabelKey = 'search_selected_favorite_tag';

class FavoriteTagsSection extends ConsumerWidget {
  const FavoriteTagsSection({
    super.key,
    required this.selectedLabel,
    required this.onTagTap,
  });

  final String selectedLabel;
  final ValueChanged<String>? onTagTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref
        .watch(miscDataProvider(kSearchSelectedFavoriteTagLabelKey).notifier);

    return FavoriteTagsFilterScope(
      initialValue: selectedLabel,
      sortType: FavoriteTagsSortType.nameAZ,
      builder: (_, tags, labels, selected) => OptionTagsArenaNoEdit(
        title: 'favorite_tags.favorites'.tr(),
        titleTrailing: FavoriteTagLabelSelectorField(
          selected: selected,
          labels: labels,
          onSelect: (value) => notifier.put(value),
        ),
        children: _buildFavoriteTags(ref, tags),
      ),
    );
  }

  List<Widget> _buildFavoriteTags(
    WidgetRef ref,
    List<FavoriteTag> tags,
  ) {
    return [
      ...tags.mapIndexed((index, tag) {
        final colors = ref.context.generateChipColors(
          ref.context.colorScheme.onSurface,
          ref.watch(settingsProvider),
        );

        return RawChip(
          visualDensity: VisualDensity.compact,
          onPressed: () => onTagTap?.call(tag.name),
          label: Text(
            tag.name.replaceAll('_', ' '),
            style: TextStyle(
              color: colors?.foregroundColor,
            ),
          ),
          backgroundColor: colors?.backgroundColor,
          side: colors != null
              ? BorderSide(
                  color: colors.borderColor,
                )
              : null,
          deleteIcon: Icon(
            Symbols.close,
            size: 18,
            color: colors?.foregroundColor,
          ),
        );
      }),
      if (tags.isEmpty) ...[
        const ImportTagButton(),
      ],
    ];
  }
}

class OptionTagsArenaNoEdit extends StatelessWidget {
  const OptionTagsArenaNoEdit({
    super.key,
    required this.title,
    this.titleTrailing,
    required this.children,
  });

  final String title;
  final Widget? titleTrailing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  title.toUpperCase(),
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: const Size(32, 32),
                    shape: const CircleBorder(),
                    backgroundColor:
                        context.colorScheme.surfaceContainerHighest,
                  ),
                  onPressed: () => context.push('/favorite_tags'),
                  child: Icon(
                    Symbols.settings,
                    size: 16,
                    color: context.colorScheme.onSurfaceVariant,
                    fill: 1,
                  ),
                ),
              ],
            ),
            titleTrailing ?? const SizedBox.shrink(),
          ],
        ),
        const SizedBox(height: 2),
        Wrap(
          spacing: 4,
          runSpacing: isDesktopPlatform() ? 4 : 0,
          children: children,
        ),
      ],
    );
  }
}
