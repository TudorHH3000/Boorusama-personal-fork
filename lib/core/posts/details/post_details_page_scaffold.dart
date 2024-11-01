// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:exprollable_page_view/exprollable_page_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/images/images.dart';
import 'package:boorusama/core/notes/notes.dart';
import 'package:boorusama/core/posts/details/common.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/core/videos/videos.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/gestures.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/widgets/widgets.dart';

enum PostDetailsPart {
  pool,
  info,
  toolbar,
  artistInfo,
  source,
  tags,
  stats,
  fileDetails,
  comments,
  artistPosts,
  relatedPosts,
  characterList,
}

const kDefaultPostDetailsParts = {
  PostDetailsPart.pool,
  PostDetailsPart.info,
  PostDetailsPart.toolbar,
  PostDetailsPart.artistInfo,
  PostDetailsPart.stats,
  PostDetailsPart.source,
  PostDetailsPart.tags,
  PostDetailsPart.fileDetails,
  PostDetailsPart.comments,
  PostDetailsPart.artistPosts,
  PostDetailsPart.relatedPosts,
  PostDetailsPart.characterList,
};

const kDefaultPostDetailsNoSourceParts = {
  PostDetailsPart.pool,
  PostDetailsPart.info,
  PostDetailsPart.toolbar,
  PostDetailsPart.artistInfo,
  PostDetailsPart.stats,
  PostDetailsPart.tags,
  PostDetailsPart.fileDetails,
  PostDetailsPart.comments,
  PostDetailsPart.artistPosts,
  PostDetailsPart.relatedPosts,
  PostDetailsPart.characterList,
};

class PostDetailsPageScaffold<T extends Post> extends ConsumerStatefulWidget {
  const PostDetailsPageScaffold({
    super.key,
    required this.posts,
    required this.initialIndex,
    required this.onExit,
    this.toolbar,
    this.sliverArtistPostsBuilder,
    this.sliverCharacterPostsBuilder,
    this.onExpanded,
    this.tagListBuilder,
    this.infoBuilder,
    required this.swipeImageUrlBuilder,
    this.topRightButtonsBuilder,
    this.placeholderImageUrlBuilder,
    this.artistInfoBuilder,
    this.onPageChanged,
    this.onPageChangeIndexed,
    this.sliverRelatedPostsBuilder,
    this.commentsBuilder,
    this.poolTileBuilder,
    this.statsTileBuilder,
    this.fileDetailsBuilder,
    this.sourceSectionBuilder,
    this.parts = kDefaultPostDetailsParts,
    this.postDetailsController,
  });

  final int initialIndex;
  final List<T> posts;
  final void Function(int page) onExit;
  final void Function(T post)? onExpanded;
  final void Function(T post)? onPageChanged;
  final void Function(int index)? onPageChangeIndexed;
  final String Function(T post) swipeImageUrlBuilder;
  final String? Function(T post, int currentPage)? placeholderImageUrlBuilder;
  final Widget? toolbar;
  final List<Widget> Function(BuildContext context, T post)?
      sliverArtistPostsBuilder;
  final Widget Function(BuildContext context, T post)?
      sliverCharacterPostsBuilder;
  final Widget Function(BuildContext context, T post)? tagListBuilder;
  final Widget Function(BuildContext context, T post)? infoBuilder;
  final Widget Function(BuildContext context, T post)? artistInfoBuilder;
  final Widget Function(BuildContext context, T post)? commentsBuilder;
  final Widget Function(BuildContext context, T post)? poolTileBuilder;
  final Widget Function(BuildContext context, T post)? statsTileBuilder;
  final Widget Function(BuildContext context, T post)? fileDetailsBuilder;
  final Widget Function(BuildContext context, T post)? sourceSectionBuilder;

  final Set<PostDetailsPart> parts;

  final Widget Function(BuildContext context, T post)?
      sliverRelatedPostsBuilder;
  final List<Widget> Function(int currentPage, bool expanded, T post,
      DetailsPageController controller)? topRightButtonsBuilder;

  final PostDetailsController<T>? postDetailsController;

  @override
  ConsumerState<PostDetailsPageScaffold<T>> createState() =>
      _PostDetailPageScaffoldState<T>();
}

class _PostDetailPageScaffoldState<T extends Post>
    extends ConsumerState<PostDetailsPageScaffold<T>>
    with PostDetailsPageMixin<PostDetailsPageScaffold<T>, T> {
  late final _posts = widget.posts;
  late final _controller = DetailsPageController(
    initialPage: widget.initialIndex,
    swipeDownToDismiss: !posts[widget.initialIndex].isVideo,
    hideOverlay: ref.read(settingsProvider).hidePostDetailsOverlay,
  );

  @override
  DetailsPageController get controller => _controller;

  @override
  Function(int page) get onPageChanged => (page) => ref
      .read(postShareProvider(posts[page]).notifier)
      .updateInformation(posts[page]);

  @override
  List<T> get posts => _posts;

  @override
  int get initialPage => widget.initialIndex;

  @override
  void initState() {
    super.initState();
    _controller.currentPage.addListener(_onPageChanged);
  }

  void _onPageChanged() {
    final page = _controller.currentPage.value;

    onSwiped(page);
    widget.onPageChangeIndexed?.call(page);
    widget.onPageChanged?.call(posts[page]);
  }

  @override
  void dispose() {
    _controller.currentPage.removeListener(_onPageChanged);
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      settingsProvider.select((value) => value.hidePostDetailsOverlay),
      (previous, next) {
        if (previous != next && _controller.hideOverlay.value != next) {
          _controller.setHideOverlay(next);
        }
      },
    );

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
            controller.nextPage(),
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
            controller.previousPage(),
        const SingleActivator(LogicalKeyboardKey.keyO): () =>
            controller.toggleOverlay(),
        const SingleActivator(LogicalKeyboardKey.escape): () {
          Navigator.of(context).pop();
          widget.onExit(controller.currentPage.value);
        },
      },
      child: Focus(
        autofocus: true,
        child: CustomContextMenuOverlay(
          backgroundColor: context.colorScheme.secondaryContainer,
          child: ValueListenableBuilder(
            valueListenable: controller.slideshow,
            builder: (context, slideshow, child) => GestureDetector(
              behavior: slideshow ? HitTestBehavior.opaque : null,
              onTap: () => controller.stopSlideshow(),
              child: IgnorePointer(
                ignoring: slideshow,
                child: child,
              ),
            ),
            child: ValueListenableBuilder(
              valueListenable: controller.currentPage,
              builder: (_, page, __) => _build(page),
            ),
          ),
        ),
      ),
    );
  }

  Widget _build(int currentPage) {
    final config = ref.watchConfig;
    final booruBuilder = ref.watchBooruBuilder(config);
    final postGesturesHandler = booruBuilder?.postGestureHandlerBuilder;
    final focusedPost = posts[currentPage];

    Widget buildShareChild() {
      return Column(
        children: [
          if (widget.infoBuilder != null)
            widget.infoBuilder!(context, focusedPost),
          widget.toolbar != null
              ? widget.toolbar!
              : SimplePostActionToolbar(post: focusedPost),
        ],
      );
    }

    Widget buildBottomSheet() {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (focusedPost.isVideo)
            ValueListenableBuilder(
              valueListenable: videoProgress,
              builder: (_, progress, __) => VideoSoundScope(
                builder: (context, soundOn) => BooruVideoProgressBar(
                  soundOn: soundOn,
                  progress: progress,
                  playbackSpeed: ref.watchPlaybackSpeed(focusedPost.videoUrl),
                  onSeek: (position) => onVideoSeekTo(position, currentPage),
                  onSpeedChanged: (speed) =>
                      ref.setPlaybackSpeed(focusedPost.videoUrl, speed),
                  onSoundToggle: (value) => ref.setGlobalVideoSound(value),
                ),
              ),
            ),
          Container(
            color: context.colorScheme.surface,
            padding: EdgeInsets.only(
              bottom: MediaQuery.paddingOf(context).bottom,
            ),
            child: buildShareChild(),
          ),
        ],
      );
    }

    return DetailsPage(
      currentSettings: () => ref.read(settingsProvider),
      controller: controller,
      intitialIndex: widget.initialIndex,
      onExit: widget.onExit,
      onSwipeDownEnd: booruBuilder?.canHandlePostGesture(
                    GestureType.swipeDown,
                    config.postGestures?.fullview,
                  ) ==
                  true &&
              postGesturesHandler != null
          ? (page) => postGesturesHandler(
                ref,
                config.postGestures?.fullview?.swipeDown,
                posts[page],
              )
          : null,
      bottomSheet: widget.infoBuilder != null
          ? DecoratedBox(
              decoration: BoxDecoration(
                color: context.colorScheme.surface.applyOpacity(0.8),
                border: Border(
                  top: BorderSide(
                    color: context.theme.dividerColor,
                    width: 0.2,
                  ),
                ),
              ),
              child: buildBottomSheet(),
            )
          : buildBottomSheet(),
      targetSwipeDown: SwipeTargetImage(
        imageUrl: focusedPost.isVideo
            ? focusedPost.videoThumbnailUrl
            : widget.swipeImageUrlBuilder(focusedPost),
        aspectRatio: focusedPost.aspectRatio,
      ),
      expandedBuilder: (context, page, expanded, enableSwipe) {
        final post = posts[page];
        final (previousPost, nextPost) = posts.getPrevAndNextPosts(page);
        final expandedOnCurrentPage = expanded && page == currentPage;
        final media = PostMedia(
          inFocus: !expanded && page == currentPage,
          post: post,
          imageUrl: widget.swipeImageUrlBuilder(post),
          placeholderImageUrl: widget.placeholderImageUrlBuilder != null
              ? widget.placeholderImageUrlBuilder!(post, currentPage)
              : post.thumbnailImageUrl,
          onImageTap: onImageTap,
          onDoubleTap: booruBuilder?.canHandlePostGesture(
                        GestureType.doubleTap,
                        ref.watchConfig.postGestures?.fullview,
                      ) ==
                      true &&
                  postGesturesHandler != null
              ? () => postGesturesHandler(
                    ref,
                    ref.watchConfig.postGestures?.fullview?.doubleTap,
                    post,
                  )
              : null,
          onLongPress: booruBuilder?.canHandlePostGesture(
                        GestureType.longPress,
                        ref.watchConfig.postGestures?.fullview,
                      ) ==
                      true &&
                  postGesturesHandler != null
              ? () => postGesturesHandler(
                    ref,
                    ref.watchConfig.postGestures?.fullview?.longPress,
                    post,
                  )
              : null,
          onCurrentVideoPositionChanged: onCurrentPositionChanged,
          onVideoVisibilityChanged: onVisibilityChanged,
          imageOverlayBuilder: (constraints) => noteOverlayBuilderDelegate(
            constraints,
            post,
            ref.watch(notesControllerProvider(post)),
          ),
          useHero: page == currentPage,
          onImageZoomUpdated: onZoomUpdated,
          onVideoPlayerCreated: (controller) =>
              onVideoPlayerCreated(controller, page),
          onWebmVideoPlayerCreated: (controller) =>
              onWebmVideoPlayerCreated(controller, page),
          autoPlay: true,
        );

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: CustomScrollView(
            physics: enableSwipe ? null : const NeverScrollableScrollPhysics(),
            controller: PageContentScrollController.of(context),
            slivers: [
              // preload next image only, not the post itself
              if (nextPost != null && !nextPost.isVideo)
                SliverOffstage(
                  sliver: SliverToBoxAdapter(
                    child: PostDetailsPreloadImage(
                      url: widget.swipeImageUrlBuilder(nextPost),
                    ),
                  ),
                ),
              if (previousPost != null && !previousPost.isVideo)
                SliverOffstage(
                  sliver: SliverToBoxAdapter(
                    child: PostDetailsPreloadImage(
                      url: widget.swipeImageUrlBuilder(previousPost),
                    ),
                  ),
                ),
              if (!expandedOnCurrentPage)
                SliverSizedBox(
                  height: context.screenHeight -
                      MediaQuery.viewPaddingOf(context).top,
                  child: media,
                )
              else
                SliverToBoxAdapter(child: media),
              if (!expandedOnCurrentPage)
                SliverSizedBox(height: context.screenHeight),
              if (expandedOnCurrentPage)
                ...widget.parts
                    .map(
                      (p) => switch (p) {
                        PostDetailsPart.pool => widget.poolTileBuilder != null
                            ? SliverToBoxAdapter(
                                child: widget.poolTileBuilder!(context, post),
                              )
                            : null,
                        PostDetailsPart.info => widget.infoBuilder != null
                            ? SliverToBoxAdapter(
                                child: widget.infoBuilder!(context, post),
                              )
                            : null,
                        PostDetailsPart.toolbar => widget.toolbar != null
                            ? SliverToBoxAdapter(
                                child: widget.toolbar,
                              )
                            : null,
                        PostDetailsPart.artistInfo =>
                          widget.artistInfoBuilder != null
                              ? SliverToBoxAdapter(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      const Divider(thickness: 0.5, height: 8),
                                      widget.artistInfoBuilder!(
                                        context,
                                        post,
                                      ),
                                    ],
                                  ),
                                )
                              : null,
                        PostDetailsPart.stats => widget.statsTileBuilder != null
                            ? SliverToBoxAdapter(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const SizedBox(height: 8),
                                    widget.statsTileBuilder!(context, post),
                                    const Divider(thickness: 0.5),
                                  ],
                                ),
                              )
                            : null,
                        PostDetailsPart.tags => widget.tagListBuilder != null
                            ? SliverToBoxAdapter(
                                child: widget.tagListBuilder!(context, post),
                              )
                            : SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: BasicTagList(
                                    tags: post.tags.toList(),
                                    onTap: (tag) =>
                                        goToSearchPage(context, tag: tag),
                                  ),
                                ),
                              ),
                        PostDetailsPart.fileDetails =>
                          widget.fileDetailsBuilder != null
                              ? SliverToBoxAdapter(
                                  child: Column(
                                    children: [
                                      widget.fileDetailsBuilder!(context, post),
                                      const Divider(thickness: 0.5),
                                    ],
                                  ),
                                )
                              : SliverToBoxAdapter(
                                  child: Column(
                                    children: [
                                      FileDetailsSection(
                                        post: post,
                                        rating: post.rating,
                                      ),
                                      const Divider(thickness: 0.5),
                                    ],
                                  ),
                                ),
                        PostDetailsPart.source => widget.sourceSectionBuilder !=
                                null
                            ? SliverToBoxAdapter(
                                child:
                                    widget.sourceSectionBuilder!(context, post),
                              )
                            : post.source.whenWeb(
                                (source) => SliverToBoxAdapter(
                                  child: SourceSection(source: source),
                                ),
                                () => null,
                              ),
                        PostDetailsPart.comments =>
                          widget.commentsBuilder != null
                              ? SliverToBoxAdapter(
                                  child: widget.commentsBuilder!(context, post),
                                )
                              : null,
                        PostDetailsPart.artistPosts =>
                          widget.sliverArtistPostsBuilder != null
                              ? MultiSliver(
                                  children: widget.sliverArtistPostsBuilder!(
                                    context,
                                    post,
                                  ),
                                )
                              : null,
                        PostDetailsPart.relatedPosts =>
                          widget.sliverRelatedPostsBuilder != null
                              ? widget.sliverRelatedPostsBuilder!(context, post)
                              : null,
                        PostDetailsPart.characterList => widget
                                    .sliverCharacterPostsBuilder !=
                                null
                            ? widget.sliverCharacterPostsBuilder!(context, post)
                            : null,
                      },
                    )
                    .nonNulls,
              SliverSizedBox(
                height: MediaQuery.paddingOf(context).bottom + 72,
              ),
            ],
          ),
        );
      },
      pageCount: posts.length,
      topRightButtonsBuilder: (expanded) =>
          widget.topRightButtonsBuilder != null
              ? widget.topRightButtonsBuilder!(
                  currentPage,
                  expanded,
                  focusedPost,
                  controller,
                )
              : [
                  NoteActionButtonWithProvider(
                    post: focusedPost,
                    expanded: expanded,
                    noteState: ref.watch(notesControllerProvider(focusedPost)),
                  ),
                  GeneralMoreActionButton(
                    post: focusedPost,
                    onStartSlideshow: () => controller.startSlideshow(),
                  ),
                ],
      onExpanded: () => widget.onExpanded?.call(focusedPost),
    );
  }
}

class DefaultPostDetailsActionToolbar extends StatelessWidget {
  const DefaultPostDetailsActionToolbar({
    super.key,
    required this.controller,
  });

  final PostDetailsController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller.currentPost,
      builder: (_, post, __) => DefaultPostActionToolbar(post: post),
    );
  }
}
