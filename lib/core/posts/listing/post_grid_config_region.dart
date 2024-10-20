// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/foundation/display.dart';

final postGridSideBarVisibleProvider = StateProvider<bool>((ref) {
  return false;
});

class PostGridConfigRegion extends ConsumerWidget {
  const PostGridConfigRegion({
    super.key,
    required this.blacklistHeader,
    required this.postController,
    required this.child,
  });

  final Widget child;
  final Widget blacklistHeader;
  final PostGridController<Post> postController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OrientationLayoutBuilder(
          portrait: (context) => const SizedBox.shrink(),
          landscape: (context) => ResponsiveLayoutBuilder(
            phone: (context) => const SizedBox.shrink(),
            pc: (context) => DesktopPostConfigSection(
              postController: postController,
              blacklistHeader: blacklistHeader,
            ),
          ),
        ),
        OrientationLayoutBuilder(
          portrait: (context) => const SizedBox.shrink(),
          landscape: (context) => ResponsiveLayoutBuilder(
            phone: (context) => const SizedBox.shrink(),
            pc: (context) => const DesktopPostConfigRevealer(),
          ),
        ),
        Expanded(
          child: child,
        ),
      ],
    );
  }
}

class DesktopPostConfigRevealer extends ConsumerWidget {
  const DesktopPostConfigRevealer({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Material(
          color: Colors.transparent,
          shadowColor: Colors.transparent,
          child: InkWell(
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            onTap: () {
              ref.read(postGridSideBarVisibleProvider.notifier).state =
                  !ref.read(postGridSideBarVisibleProvider.notifier).state;
            },
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 6,
              ),
              width: 3,
              height: 32,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DesktopPostConfigSection extends ConsumerWidget {
  const DesktopPostConfigSection({
    super.key,
    required this.blacklistHeader,
    required this.postController,
  });

  final PostGridController<Post> postController;
  final Widget blacklistHeader;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsNotifier = ref.watch(settingsProvider.notifier);

    final gridSize = ref
        .watch(imageListingSettingsProvider.select((value) => value.gridSize));
    final imageListType = ref.watch(
        imageListingSettingsProvider.select((value) => value.imageListType));
    final pageMode = ref
        .watch(imageListingSettingsProvider.select((value) => value.pageMode));
    final imageQuality = ref.watch(
        imageListingSettingsProvider.select((value) => value.imageQuality));

    final visible = ref.watch(postGridSideBarVisibleProvider);

    if (!visible) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            width: 250,
            child: PostGridActionSheet(
              postController: postController,
              popOnSelect: false,
              gridSize: gridSize,
              pageMode: pageMode,
              imageListType: imageListType,
              imageQuality: imageQuality,
              onModeChanged: (mode) => settingsNotifier.updateWith(
                (s) => s.copyWith(
                  listing: s.listing.copyWith(pageMode: mode),
                ),
              ),
              onGridChanged: (grid) => settingsNotifier.updateWith(
                (s) => s.copyWith(
                  listing: s.listing.copyWith(gridSize: grid),
                ),
              ),
              onImageListChanged: (imageListType) =>
                  settingsNotifier.updateWith(
                (s) => s.copyWith(
                  listing: s.listing.copyWith(
                    imageListType: imageListType,
                  ),
                ),
              ),
              onImageQualityChanged: (imageQuality) =>
                  settingsNotifier.updateWith(
                (s) => s.copyWith(
                  listing: s.listing.copyWith(
                    imageQuality: imageQuality,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 230,
            child: blacklistHeader,
          ),
        ],
      ),
    );
  }
}
