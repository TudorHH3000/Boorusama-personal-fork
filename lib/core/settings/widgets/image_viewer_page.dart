// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/core/settings/widgets/widgets/settings_header.dart';
import 'package:boorusama/core/settings/widgets/widgets/settings_tile.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/router.dart';
import 'widgets/settings_page_scaffold.dart';

class ImageViewerPage extends ConsumerStatefulWidget {
  const ImageViewerPage({
    super.key,
  });

  @override
  ConsumerState<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends ConsumerState<ImageViewerPage> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return SettingsPageScaffold(
      title: const Text('settings.image_viewer.image_viewer').tr(),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsHeader(label: 'settings.general'.tr()),
            SettingsTile(
              title: const Text('settings.image_details.ui_overlay.ui_overlay')
                  .tr(),
              selectedOption: settings.postDetailsOverlayInitialState,
              items: PostDetailsOverlayInitialState.values,
              onChanged: (value) => ref.updateSettings(
                  settings.copyWith(postDetailsOverlayInitialState: value)),
              optionBuilder: (value) => Text(value.localize().tr()),
            ),
            const Divider(thickness: 1),
            const SettingsHeader(label: 'Slideshow'),
            SettingsTile(
              title: const Text('Slideshow mode'),
              selectedOption: settings.slideshowDirection,
              items: SlideshowDirection.values,
              onChanged: (value) => ref
                  .updateSettings(settings.copyWith(slideshowDirection: value)),
              optionBuilder: (value) => Text(value.localize().tr()),
            ),
            SettingsTile(
              title: const Text('Slideshow interval'),
              subtitle: const Text(
                  'Value less than 1 second will automatically skip transition'),
              selectedOption: settings.slideshowInterval,
              items: getSlideShowIntervalPossibleValue(),
              onChanged: (newValue) {
                ref.updateSettings(
                    settings.copyWith(slideshowInterval: newValue));
              },
              optionBuilder: (value) => Text(
                '${value.toStringAsFixed(value < 1 ? 2 : 0)} sec',
              ),
            ),
            SwitchListTile(
              title: const Text('Skip slideshow transition'),
              value: settings.skipSlideshowTransition,
              onChanged: (value) => ref.updateSettings(
                settings.copyWith(
                  slideshowTransitionType: value
                      ? SlideshowTransitionType.none
                      : SlideshowTransitionType.natural,
                ),
              ),
            ),
            const Divider(thickness: 1),
            const SettingsHeader(label: 'Video'),
            SwitchListTile(
              title: const Text('Mute video by default'),
              value: settings.muteAudioByDefault,
              onChanged: (value) => ref.updateSettings(
                settings.copyWith(
                  videoAudioDefaultState: value
                      ? VideoAudioDefaultState.mute
                      : VideoAudioDefaultState.unmute,
                ),
              ),
            ),
          ],
        ),
        const BooruConfigMoreSettingsRedirectCard.imageViewer(),
      ],
    );
  }
}

Future<void> openImageViewerSettingsPage(BuildContext context) {
  return context.push(
    Uri(
      path: '/settings',
      queryParameters: {
        'initial': 'viewer',
      },
    ).toString(),
  );
}
