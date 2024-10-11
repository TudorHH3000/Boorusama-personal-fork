// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/images/images.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/foundation/gestures.dart';
import 'package:boorusama/foundation/image.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/widgets/widgets.dart';

class InfinitePostListScaffold<T extends Post> extends ConsumerStatefulWidget {
  const InfinitePostListScaffold({
    super.key,
    this.onLoadMore,
    this.onRefresh,
    this.sliverHeaders,
    this.scrollController,
    this.contextMenuBuilder,
    this.multiSelectActions,
    this.extendBody = false,
    this.extendBodyHeight,
    required this.controller,
    this.refreshAtStart = true,
    this.errors,
    this.safeArea = true,
    this.multiSelectController,
  });

  final VoidCallback? onLoadMore;
  final void Function()? onRefresh;
  final List<Widget>? sliverHeaders;
  final AutoScrollController? scrollController;
  final Widget Function(T post, void Function() next)? contextMenuBuilder;

  final bool extendBody;
  final double? extendBodyHeight;
  final bool safeArea;

  final PostGridController<T> controller;
  final bool refreshAtStart;

  final BooruError? errors;

  final Widget? multiSelectActions;

  final MultiSelectController<T>? multiSelectController;

  @override
  ConsumerState<InfinitePostListScaffold<T>> createState() =>
      _InfinitePostListScaffoldState<T>();
}

class _InfinitePostListScaffoldState<T extends Post>
    extends ConsumerState<InfinitePostListScaffold<T>> {
  late final AutoScrollController _autoScrollController;
  late final _multiSelectController =
      widget.multiSelectController ?? MultiSelectController<T>();

  @override
  void initState() {
    super.initState();
    _autoScrollController = widget.scrollController ?? AutoScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.multiSelectController == null) {
      _multiSelectController.dispose();
    }

    if (widget.scrollController == null) {
      _autoScrollController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(imageListingSettingsProvider);
    final config = ref.watchConfig;
    final booruBuilder = ref.watchBooruBuilder(config);
    final postGesturesHandler = booruBuilder?.postGestureHandlerBuilder;
    final hasCustomLongPress = booruBuilder?.canHandlePostGesture(
          GestureType.longPress,
          config.postGestures?.preview,
        ) ??
        false;

    final gridThumbnailUrlBuilder = booruBuilder?.gridThumbnailUrlBuilder;
    final multiSelectActions = booruBuilder?.multiSelectionActionsBuilder?.call(
      context,
      _multiSelectController,
    );

    return LayoutBuilder(
      builder: (context, constraints) => PostGrid(
        controller: widget.controller,
        refreshAtStart: widget.refreshAtStart,
        scrollController: _autoScrollController,
        safeArea: widget.safeArea,
        sliverHeaders: [
          ...widget.sliverHeaders ?? [],
          const SliverMasonryGridWarning(),
        ],
        footer: widget.multiSelectActions ??
            multiSelectActions ??
            DefaultMultiSelectionActions(
              controller: _multiSelectController,
            ),
        multiSelectController: _multiSelectController,
        onLoadMore: widget.onLoadMore,
        onRefresh: widget.onRefresh,
        body: SliverPostGrid(
          postController: widget.controller,
          multiSelectController: _multiSelectController,
          constraints: constraints,
          itemBuilder: (context, index, post) {
            final (width, height, cacheWidth, cacheHeight) =
                context.sizeFromConstraints(
              constraints,
              post.aspectRatio,
            );

            return ValueListenableBuilder(
              valueListenable: _multiSelectController.multiSelectNotifier,
              builder: (_, multiSelect, __) => DefaultPostListContextMenuRegion(
                isEnabled: !multiSelect,
                contextMenu: widget.contextMenuBuilder != null
                    ? widget.contextMenuBuilder!.call(
                        post,
                        () {
                          _multiSelectController.enableMultiSelect();
                        },
                      )
                    : GeneralPostContextMenu(
                        hasAccount: false,
                        onMultiSelect: () {
                          _multiSelectController.enableMultiSelect();
                        },
                        post: post,
                      ),
                child: GestureDetector(
                  onLongPress: hasCustomLongPress && postGesturesHandler != null
                      ? () => postGesturesHandler(
                            ref,
                            ref.watchConfig.postGestures?.preview?.longPress,
                            post,
                          )
                      : null,
                  child: ExplicitContentBlockOverlay(
                    width: width ?? 100,
                    height: height ?? 100,
                    block: settings.blurExplicitMedia && post.isExplicit,
                    childBuilder: (block) => ImageGridItem(
                      isGif: post.isGif,
                      isAI: post.isAI,
                      hideOverlay: multiSelect,
                      onTap: !multiSelect
                          ? () {
                              if (booruBuilder?.canHandlePostGesture(
                                          GestureType.tap,
                                          config.postGestures?.preview) ==
                                      true &&
                                  postGesturesHandler != null) {
                                postGesturesHandler(
                                  ref,
                                  ref.watchConfig.postGestures?.preview?.tap,
                                  post,
                                );
                              } else {
                                goToPostDetailsPage(
                                  context: context,
                                  posts: widget.controller.items,
                                  initialIndex: index,
                                  scrollController: _autoScrollController,
                                );
                              }
                            }
                          : null,
                      quickActionButton: !multiSelect && !block
                          ? DefaultImagePreviewQuickActionButton(post: post)
                          : null,
                      autoScrollOptions: AutoScrollOptions(
                        controller: _autoScrollController,
                        index: index,
                      ),
                      isAnimated: post.isAnimated,
                      isTranslated: post.isTranslated,
                      hasComments: post.hasComment,
                      hasParentOrChildren: post.hasParentOrChildren,
                      score: settings.showScoresInGrid ? post.score : null,
                      borderRadius: BorderRadius.circular(
                        settings.imageBorderRadius,
                      ),
                      image: BooruImage(
                        aspectRatio: post.aspectRatio,
                        imageUrl: block
                            ? ''
                            : gridThumbnailUrlBuilder != null
                                ? gridThumbnailUrlBuilder(
                                    settings.imageQuality,
                                    post,
                                  )
                                : post.thumbnailImageUrl,
                        borderRadius: BorderRadius.circular(
                          settings.imageBorderRadius,
                        ),
                        forceFill:
                            settings.imageListType == ImageListType.standard,
                        placeholderUrl: post.thumbnailImageUrl,
                        width: width,
                        height: height,
                        cacheHeight: cacheHeight,
                        cacheWidth: cacheWidth,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          error: widget.errors,
        ),
      ),
    );
  }
}

class DefaultPostListContextMenuRegion extends ConsumerWidget {
  const DefaultPostListContextMenuRegion({
    super.key,
    this.isEnabled = true,
    required this.contextMenu,
    required this.child,
  });

  final bool isEnabled;
  final Widget contextMenu;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    final booruBuilder = ref.watchBooruBuilder(config);
    final hasCustomLongPress = booruBuilder?.canHandlePostGesture(
          GestureType.longPress,
          config.postGestures?.preview,
        ) ??
        false;

    if (hasCustomLongPress) return child;

    return ContextMenuRegion(
      isEnabled: isEnabled,
      contextMenu: contextMenu,
      child: child,
    );
  }
}

class SliverMasonryGridWarning extends ConsumerWidget {
  const SliverMasonryGridWarning({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = ref.watch(
        imageListingSettingsProvider.select((value) => value.imageListType));
    final booruType = ref.watchConfig.booruType;

    return type == ImageListType.masonry && booruType.masonryLayoutUnsupported
        ? SliverToBoxAdapter(
            child: WarningContainer(
              title: 'Layout',
              contentBuilder: (context) => Text(
                'Consider switching to the "Standard" layout. "Masonry" is very jumpy for this booru.',
                style: TextStyle(
                  color: context.colorScheme.onSurface,
                ),
              ),
            ),
          )
        : const SliverSizedBox.shrink();
  }
}

class SinglePagePostListScaffold<T extends Post>
    extends ConsumerStatefulWidget {
  const SinglePagePostListScaffold({
    super.key,
    required this.posts,
    this.sliverHeaders,
  });

  final List<T> posts;
  final List<Widget>? sliverHeaders;

  @override
  ConsumerState<SinglePagePostListScaffold<T>> createState() =>
      _SinglePagePostListScaffoldState<T>();
}

class _SinglePagePostListScaffoldState<T extends Post>
    extends ConsumerState<SinglePagePostListScaffold<T>> {
  @override
  Widget build(BuildContext context) {
    return CustomContextMenuOverlay(
      child: PostScope(
        fetcher: (page) => TaskEither.Do(
          ($) async => page == 1 ? widget.posts.toResult() : <T>[].toResult(),
        ),
        builder: (context, controller, errors) => InfinitePostListScaffold(
          errors: errors,
          controller: controller,
          sliverHeaders: [
            if (widget.sliverHeaders != null) ...widget.sliverHeaders!,
          ],
        ),
      ),
    );
  }
}
