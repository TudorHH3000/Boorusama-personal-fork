// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/core/bookmarks/bookmarks.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/downloads/download.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/url_launcher.dart';
import 'package:boorusama/router.dart';

class GeneralPostContextMenu extends ConsumerWidget {
  const GeneralPostContextMenu({
    super.key,
    required this.post,
    this.onMultiSelect,
    required this.hasAccount,
  });

  final Post post;
  final void Function()? onMultiSelect;
  final bool hasAccount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruConfig = ref.watchConfigAuth;
    final bookmarkState = ref.watch(bookmarkProvider);
    final isBookmarked =
        bookmarkState.isBookmarked(post, booruConfig.booruType);
    final commentPageBuilder =
        ref.watch(currentBooruBuilderProvider)?.commentPageBuilder;

    return GenericContextMenu(
      buttonConfigs: [
        ContextMenuButtonConfig(
          'post.action.preview'.tr(),
          onPressed: () => goToImagePreviewPage(ref, context, post),
        ),
        if (commentPageBuilder != null && post.hasComment)
          ContextMenuButtonConfig(
            'post.action.view_comments'.tr(),
            onPressed: () => goToCommentPage(context, ref, post.id),
          ),
        ContextMenuButtonConfig(
          'download.download'.tr(),
          onPressed: () {
            ref.download(post);
          },
        ),
        if (!isBookmarked)
          ContextMenuButtonConfig(
            'post.detail.add_to_bookmark'.tr(),
            onPressed: () => ref.bookmarks
              ..addBookmarkWithToast(
                context,
                booruConfig.booruId,
                booruConfig.url,
                post,
              ),
          )
        else
          ContextMenuButtonConfig(
            'post.detail.remove_from_bookmark'.tr(),
            onPressed: () => ref.bookmarks
              ..removeBookmarkWithToast(
                context,
                bookmarkState.getBookmark(post, booruConfig.booruType)!,
              ),
          ),
        if (post.tags.isNotEmpty)
          ContextMenuButtonConfig(
            'View tags',
            onPressed: () {
              goToShowTaglistPage(ref, post.extractTags());
            },
          ),
        if (!booruConfig.hasStrictSFW)
          ContextMenuButtonConfig(
            'post.detail.view_in_browser'.tr(),
            onPressed: () =>
                launchExternalUrlString(post.getLink(booruConfig.url)),
          ),
        if (onMultiSelect != null)
          ContextMenuButtonConfig(
            'post.action.select'.tr(),
            onPressed: () {
              onMultiSelect?.call();
            },
          ),
      ],
    );
  }
}
