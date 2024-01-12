// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/feats/downloads/bulk_download_provider.dart';
import 'package:boorusama/core/feats/search/search.dart';
import 'package:boorusama/core/feats/utils.dart';
import 'package:boorusama/core/pages/search/search_history_section.dart';
import 'package:boorusama/core/pages/search/simple_tag_search_view.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/router.dart';

class DownloadEmptyTagView extends ConsumerWidget {
  const DownloadEmptyTagView({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(4),
        child: SimpleTagSearchView(
          backButton: context.canPop()
              ? IconButton(
                  splashRadius: 16,
                  onPressed: context.navigator.pop,
                  icon: const Icon(Symbols.arrow_back),
                )
              : null,
          textColorBuilder: (tag) =>
              generateAutocompleteTagColor(ref, context, tag),
          closeOnSelected: false,
          ensureValidTag: false,
          onSelected: (tag) {
            ref
                .read(bulkDownloadSelectedTagsProvider.notifier)
                .addTag(tag.value);
          },
          emptyBuilder: () => ref.watch(searchHistoryProvider).maybeWhen(
                data: (data) => SearchHistorySection(
                  maxHistory: 20,
                  showTime: true,
                  histories: data.histories,
                  onHistoryTap: (history) {
                    ref
                        .read(bulkDownloadSelectedTagsProvider.notifier)
                        .addTags(history.split(' '));
                  },
                ),
                orElse: () => const SizedBox.shrink(),
              ),
        ),
      ),
    );
  }
}
