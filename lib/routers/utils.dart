// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/core/autocompletes/autocompletes.dart';
import 'package:boorusama/core/comments/comments.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/downloads/bulks/create_bulk_download_task_sheet.dart';
import 'package:boorusama/core/favorited_tags/favorited_tags.dart';
import 'package:boorusama/core/images/images.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/search/search.dart';
import 'package:boorusama/core/search/ui/selected_tag_edit_dialog.dart';
import 'package:boorusama/core/search_histories/search_histories.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/animations.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/foundation/toast.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/widgets/widgets.dart';

void goToHomePage(
  BuildContext context, {
  bool replace = false,
}) {
  context.navigator.popUntil((route) => route.isFirst);
}

void goToOriginalImagePage(BuildContext context, Post post) {
  if (post.isMp4) {
    showSimpleSnackBar(
      context: context,
      content: const Text('This is a video post, cannot view original image'),
    );
    return;
  }

  context.push(
    '/original_image_viewer',
    extra: post,
  );
}

void goToSearchPage(
  BuildContext context, {
  String? tag,
}) {
  if (tag == null) {
    context.push('/search');
  } else {
    final encodedTag = Uri.encodeComponent(tag);
    context.push('/search?$kInitialQueryKey=$encodedTag');
  }
}

void goToFavoritesPage(BuildContext context) {
  context.go('/favorites');
}

void goToArtistPage(
  BuildContext context,
  String? artistName,
) {
  if (artistName == null) return;

  final encodedArtistName = Uri.encodeComponent(artistName);
  context.push('/artists?$kArtistNameKey=$encodedArtistName');
}

void goToCharacterPage(BuildContext context, String character) {
  if (character.isEmpty) return;

  final encodedCharacter = Uri.encodeComponent(character);
  context.push('/characters?$kCharacterNameKey=$encodedCharacter');
}

void goToPostDetailsPage<T extends Post>({
  required BuildContext context,
  required Iterable<T> posts,
  required int initialIndex,
  AutoScrollController? scrollController,
}) {
  context.push(
    '/details',
    extra: (
      initialIndex: initialIndex,
      posts: posts,
      scrollController: scrollController,
      isDesktop: kPreferredLayout.isDesktop,
    ),
  );
}

void goToBlacklistedTagsSearchPage(
  BuildContext context, {
  required void Function(List<String> tags, String currentQuery) onSelectDone,
  List<String>? initialTags,
}) {
  showDialog(
    context: context,
    routeSettings: const RouteSettings(
      name: RouterPageConstant.blacklistedSearch,
    ),
    builder: (c) {
      return SelectedTagEditDialog(
        tag: TagSearchItem.raw(tag: initialTags?.join(' ') ?? ''),
        onUpdated: (tag) {
          if (tag.isNotEmpty) {
            onSelectDone([], tag.trim());
          }
        },
      );
    },
  );
}

void goToMetatagsPage(
  BuildContext context, {
  required List<Metatag> metatags,
  required void Function(Metatag tag) onSelected,
}) {
  showAdaptiveBottomSheet(
    context,
    settings: const RouteSettings(
      name: RouterPageConstant.metatags,
    ),
    builder: (context) => MetatagListPage(
      metatags: metatags,
      onSelected: onSelected,
    ),
  );
}

Future<Object?> goToFavoriteTagImportPage(
  BuildContext context,
) {
  return showGeneralDialog(
    context: context,
    routeSettings: const RouteSettings(
      name: RouterPageConstant.favoriteTagsImport,
    ),
    pageBuilder: (context, _, __) => ImportTagsDialog(
      padding: kPreferredLayout.isMobile ? 0 : 8,
      onImport: (tagString, ref) =>
          ref.read(favoriteTagsProvider.notifier).import(tagString),
    ),
  );
}

void goToImagePreviewPage(WidgetRef ref, BuildContext context, Post post) {
  showGeneralDialog(
    context: context,
    routeSettings: const RouteSettings(
      name: RouterPageConstant.postQuickPreview,
    ),
    pageBuilder: (context, animation, secondaryAnimation) => QuickPreviewImage(
      child: BooruImage(
        placeholderUrl: post.thumbnailImageUrl,
        aspectRatio: post.aspectRatio,
        imageUrl: post.sampleImageUrl,
      ),
    ),
  );
}

void goToSearchHistoryPage(
  BuildContext context, {
  required Function() onClear,
  required Function(SearchHistory history) onRemove,
  required Function(SearchHistory history) onTap,
}) {
  showMaterialModalBottomSheet(
    context: context,
    settings: const RouteSettings(
      name: RouterPageConstant.searchHistories,
    ),
    duration: AppDurations.bottomSheet,
    builder: (context) => FullHistoryPage(
      onClear: onClear,
      onRemove: onRemove,
      onTap: onTap,
      scrollController: ModalScrollController.of(context),
    ),
  );
}

Future<bool?> goToShowTaglistPage(
  WidgetRef ref,
  List<Tag> tags,
) {
  return showAdaptiveSheet(
    navigatorKey.currentContext ?? ref.context,
    expand: true,
    builder: (context) => DefaultShowTagListPage(
      tags: tags,
    ),
  );
}

void goToUpdateBooruConfigPage(
  BuildContext context, {
  required BooruConfig config,
  String? initialTab,
}) {
  context.push(
    Uri(
      path: '/boorus/${config.id}/update',
      queryParameters: {
        if (initialTab != null) 'q': initialTab,
      },
    ).toString(),
  );
}

void goToCommentPage(BuildContext context, WidgetRef ref, int postId) {
  final builder = ref.readBooruBuilder(ref.readConfig)?.commentPageBuilder;

  if (builder == null) return;

  showCommentPage(
    context,
    postId: postId,
    settings: const RouteSettings(
      name: RouterPageConstant.comment,
    ),
    builder: (_, useAppBar) => builder(context, useAppBar, postId),
  );
}

void goToQuickSearchPage(
  BuildContext context, {
  bool ensureValidTag = false,
  BooruConfig? initialConfig,
  required WidgetRef ref,
  Widget Function(String text)? floatingActionButton,
  required void Function(String tag, bool isMultiple) onSelected,
  void Function(BuildContext context, String text, bool isMultiple)?
      onSubmitted,
  Widget Function(TextEditingController controller)? emptyBuilder,
}) {
  showSimpleTagSearchView(
    context,
    settings: const RouteSettings(
      name: RouterPageConstant.quickSearch,
    ),
    ensureValidTag: ensureValidTag,
    floatingActionButton: floatingActionButton,
    builder: (_, isMobile) => isMobile
        ? SimpleTagSearchView(
            initialConfig: initialConfig,
            onSubmitted: onSubmitted,
            ensureValidTag: ensureValidTag,
            floatingActionButton: floatingActionButton != null
                ? (text) => floatingActionButton.call(text)
                : null,
            onSelected: onSelected,
            textColorBuilder: (tag) =>
                generateAutocompleteTagColor(ref, context, tag),
            emptyBuilder: emptyBuilder,
          )
        : SimpleTagSearchView(
            initialConfig: initialConfig,
            onSubmitted: onSubmitted,
            backButton: IconButton(
              splashRadius: 16,
              onPressed: () => context.navigator.pop(),
              icon: const Icon(Symbols.arrow_back),
            ),
            ensureValidTag: ensureValidTag,
            onSelected: onSelected,
            textColorBuilder: (tag) =>
                generateAutocompleteTagColor(ref, context, tag),
            emptyBuilder: emptyBuilder,
          ),
  );
}

Future<T?> showDesktopDialogWindow<T>(
  BuildContext context, {
  required Widget Function(BuildContext context) builder,
  double? width,
  double? height,
  Color? backgroundColor,
  EdgeInsets? margin,
  RouteSettings? settings,
}) =>
    showGeneralDialog(
      context: context,
      routeSettings: settings,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black87,
      pageBuilder: (context, _, __) {
        return Dialog(
          backgroundColor:
              backgroundColor ?? context.colorScheme.surfaceContainerHighest,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: Container(
            width: width ?? context.screenWidth * 0.8,
            height: height ?? context.screenHeight * 0.8,
            margin: margin ??
                const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
            child: builder(context),
          ),
        );
      },
    );

Future<void> goToBulkDownloadPage(
  BuildContext context,
  List<String>? tags, {
  required WidgetRef ref,
}) async {
  if (tags != null) {
    goToNewBulkDownloadTaskPage(
      ref,
      context,
      initialValue: tags,
    );
  } else {
    context.pushNamed(kBulkdownload);
  }
}

Future<T?> showDesktopFullScreenWindow<T>(
  BuildContext context, {
  required Widget Function(BuildContext context) builder,
}) =>
    showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) {
        return builder(context);
      },
    );

Future<T?> showDesktopWindow<T>(
  BuildContext context, {
  required Widget Function(BuildContext context) builder,
  double? width,
}) =>
    showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) => Dialog(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        child: BooruDialog(
          width: width ?? context.screenWidth * 0.75,
          child: builder(context),
        ),
      ),
    );
