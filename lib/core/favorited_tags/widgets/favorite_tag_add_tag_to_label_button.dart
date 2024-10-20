// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/flutter.dart';
import 'package:boorusama/router.dart';
import '../favorited_tags.dart';

class FavoriteTagAddTagToLabelButton extends ConsumerWidget {
  const FavoriteTagAddTagToLabelButton({
    super.key,
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () {
        goToQuickSearchPage(
          context,
          ref: ref,
          onSubmitted: (context, text, _) {
            context.navigator.pop();
            ref.read(favoriteTagsProvider.notifier).add(
              text,
              labels: [
                label,
              ],
            );
          },
          onSelected: (tag, _) {
            ref.read(favoriteTagsProvider.notifier).add(
              tag,
              labels: [
                label,
              ],
            );
          },
        );
      },
      icon: const Icon(Symbols.add),
    );
  }
}
