// Flutter imports:
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru.dart';
import 'package:boorusama/core/configs/create/create.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/foundation/gestures.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'providers.dart';
import 'widgets.dart';

class CreateDanbooruConfigPage extends StatelessWidget {
  const CreateDanbooruConfigPage({
    super.key,
    this.backgroundColor,
    required this.config,
    this.isNewConfig = false,
  });

  final Color? backgroundColor;
  final BooruConfig config;
  final bool isNewConfig;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        initialBooruConfigProvider.overrideWith((ref) => config),
      ],
      child: CreateBooruConfigScaffold(
        isNewConfig: isNewConfig,
        backgroundColor: backgroundColor,
        authTab: DefaultBooruAuthConfigView(
          showInstructionWhen: !config.hasStrictSFW,
          customInstruction: RichText(
            text: TextSpan(
              style: context.textTheme.titleSmall?.copyWith(
                color: context.theme.hintColor,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              children: [
                const TextSpan(
                  text: '*Log in to your account on the browser, visit ',
                ),
                TextSpan(
                  text: 'My Account > API Key',
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launchExternalUrlString(
                          getDanbooruProfileUrl(config.url));
                    },
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.primary,
                  ),
                ),
                const TextSpan(
                  text:
                      '. Copy your key or create a new one if needed, ensuring all permissions are enabled for proper app functionality.',
                ),
              ],
            ),
          ),
        ),
        hasRatingFilter: true,
        postDetailsGestureActions: const {
          ...kDefaultGestureActions,
          kToggleFavoriteAction,
          kUpvoteAction,
          kDownvoteAction,
          kEditAction,
        },
        describePostDetailsAction: (action) => switch (action) {
          kToggleFavoriteAction => 'Toggle favorite',
          kUpvoteAction => 'Upvote',
          kDownvoteAction => 'Downvote',
          kEditAction => 'Edit',
          _ => describeDefaultGestureAction(action),
        },
        postDetailsResolution: const DanbooruImageDetailsQualityProvider(),
        miscOptions: const [
          DanbooruHideDeletedSwitch(),
        ],
        submitButtonBuilder: (data) => DanbooruBooruConfigSubmitButton(
          data: data,
        ),
      ),
    );
  }
}

class DanbooruBooruConfigSubmitButton extends ConsumerWidget {
  const DanbooruBooruConfigSubmitButton({
    super.key,
    required this.data,
  });

  final BooruConfigData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(initialBooruConfigProvider);
    final auth = ref.watch(authConfigDataProvider);
    final hideDeleted = ref.watch(hideDeletedProvider(config));
    final imageDetailsQuality = ref.watch(imageDetailsQualityProvider(config));

    return RawBooruConfigSubmitButton(
      config: config,
      data: data.copyWith(
        login: auth.login,
        apiKey: auth.apiKey,
        deletedItemBehavior: hideDeleted
            ? BooruConfigDeletedItemBehavior.hide
            : BooruConfigDeletedItemBehavior.show,
        imageDetaisQuality: () => imageDetailsQuality,
      ),
      enable: auth.isValid,
    );
  }
}
