// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/core/images/images.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/widgets/image_grid_item.dart';

class PreviewPostGrid<T extends Post> extends StatelessWidget {
  const PreviewPostGrid({
    super.key,
    required this.posts,
    required this.onTap,
    this.physics,
    required this.imageUrl,
  });

  final List<T> posts;
  final ScrollPhysics? physics;
  final void Function(int index) onTap;
  final String Function(T item) imageUrl;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      removeBottom: true,
      child: LayoutBuilder(
        builder: (context, constraints) => GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: switch (
                screenWidthToDisplaySize(constraints.maxWidth)) {
              ScreenSize.small => 3,
              ScreenSize.medium => 4,
              ScreenSize.large => 6,
              ScreenSize.veryLarge => 7,
            },
            crossAxisSpacing: 3,
            mainAxisSpacing: 3,
          ),
          shrinkWrap: true,
          physics: physics ?? const NeverScrollableScrollPhysics(),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];

            return ImageGridItem(
              isGif: post.isGif,
              isAI: post.isAI,
              onTap: () => onTap(index),
              isAnimated: post.isAnimated,
              isTranslated: post.isTranslated,
              image: BooruImage(
                forceFill: true,
                imageUrl: imageUrl(post),
                placeholderUrl: post.thumbnailImageUrl,
                fit: BoxFit.cover,
              ),
            );
          },
        ),
      ),
    );
  }
}

class PreviewPostList<T extends Post> extends StatelessWidget {
  const PreviewPostList({
    super.key,
    required this.posts,
    required this.onTap,
    this.physics,
    this.imageBuilder,
    required this.imageUrl,
    this.width,
    this.height,
  });

  final List<T> posts;
  final ScrollPhysics? physics;
  final void Function(int index) onTap;
  final Widget Function(T item)? imageBuilder;
  final String Function(T item) imageUrl;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SizedBox(
        height: height ?? 200,
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            scrollDirection: Axis.horizontal,
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: ImageGridItem(
                    isGif: post.isGif,
                    isAI: post.isAI,
                    isAnimated: post.isAnimated,
                    isTranslated: post.isTranslated,
                    onTap: () => onTap(index),
                    image: imageBuilder != null
                        ? imageBuilder!(post)
                        : BooruImage(
                            width: width ?? max(constraints.maxWidth / 6, 120),
                            forceFill: true,
                            aspectRatio: 0.6,
                            imageUrl: imageUrl(post),
                            placeholderUrl: post.thumbnailImageUrl,
                            fit: BoxFit.cover,
                          )),
              );
            },
          ),
        ),
      ),
    );
  }
}
