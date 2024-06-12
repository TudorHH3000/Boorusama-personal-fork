// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/display.dart';

final postGridSideBarVisibleProvider = StateProvider<bool>((ref) {
  return false;
});

class PostGridConfigRegion extends ConsumerWidget {
  const PostGridConfigRegion({
    super.key,
    required this.blacklistHeader,
    required this.builder,
    required this.postController,
  });

  final Widget Function(
    BuildContext context,
    Widget blacklistHeader,
  ) builder;
  final Widget blacklistHeader;
  final PostGridController<Post> postController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return !kPreferredLayout.isMobile
        ? Builder(
            builder: (context) {
              final gridSize = ref.watch(gridSizeSettingsProvider);
              final imageListType = ref.watch(imageListTypeSettingsProvider);
              final pageMode = ref.watch(pageModeSettingsProvider);
              final imageQuality = ref.watch(imageQualitySettingsProvider);

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (ref.watch(postGridSideBarVisibleProvider))
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                              onModeChanged: (mode) => ref.setPageMode(mode),
                              onGridChanged: (grid) => ref.setGridSize(grid),
                              onImageListChanged: (imageListType) =>
                                  ref.setImageListType(imageListType),
                              onImageQualityChanged: (imageQuality) =>
                                  ref.setImageQuality(imageQuality),
                            ),
                          ),
                          SizedBox(
                            width: 230,
                            child: blacklistHeader,
                          ),
                        ],
                      ),
                    ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Material(
                        color: Colors.transparent,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        child: InkWell(
                          customBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          onTap: () {
                            ref
                                    .read(postGridSideBarVisibleProvider.notifier)
                                    .state =
                                !ref
                                    .read(
                                        postGridSideBarVisibleProvider.notifier)
                                    .state;
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
                  ),
                  Expanded(
                    child: builder(
                      context,
                      blacklistHeader,
                    ),
                  ),
                ],
              );
            },
          )
        : builder(
            context,
            blacklistHeader,
          );
  }
}
