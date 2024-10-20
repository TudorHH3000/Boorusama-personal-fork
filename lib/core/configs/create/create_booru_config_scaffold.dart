// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/create/create.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/gestures.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme.dart';

const kDefaultPreviewImageButtonAction = {
  '',
  null,
  kToggleBookmarkAction,
  kDownloadAction,
  kViewArtistAction,
};

class CreateBooruConfigScaffold extends ConsumerWidget {
  const CreateBooruConfigScaffold({
    super.key,
    this.backgroundColor,
    this.tabsBuilder,
    required this.isNewConfig,
    this.authTab,
    this.searchTab,
    this.postDetailsResolution,
    this.hasDownloadTab = true,
    this.hasRatingFilter = false,
    this.miscOptions,
    this.postDetailsGestureActions = kDefaultGestureActions,
    this.postPreviewQuickActionButtonActions = kDefaultPreviewImageButtonAction,
    this.describePostDetailsAction,
    this.describePostPreviewQuickAction,
    this.submitButtonBuilder,
    required this.initialTab,
    this.footer,
  });

  final Color? backgroundColor;
  final Map<String, Widget> Function(BuildContext context)? tabsBuilder;

  final Widget? authTab;
  final Widget? searchTab;

  final Widget? postDetailsResolution;

  final bool hasDownloadTab;
  final bool hasRatingFilter;

  final List<Widget>? miscOptions;

  final Set<String?> postDetailsGestureActions;
  final String Function(String? action)? describePostDetailsAction;

  final Set<String?> postPreviewQuickActionButtonActions;
  final String Function(String? action)? describePostPreviewQuickAction;
  final bool isNewConfig;

  final Widget Function(BooruConfigData data)? submitButtonBuilder;

  final String? initialTab;

  final Widget? footer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(initialBooruConfigProvider);

    final tabMap = {
      if (authTab != null) 'booru.authentication': authTab!,
      'Listing': BooruConfigListingView(
        config: config,
      ),
      if (hasDownloadTab)
        'booru.download': BooruConfigDownloadView(config: config),
      'Search': searchTab ??
          BooruConfigSearchView(
            hasRatingFilter: hasRatingFilter,
            config: config,
          ),
      if (tabsBuilder != null) ...tabsBuilder!(context),
      'booru.gestures': BooruConfigGesturesView(
        postDetailsGestureActions: postDetailsGestureActions,
        describePostDetailsAction: describePostDetailsAction,
      ),
      'booru.misc': BooruConfigMiscView(
        postDetailsGestureActions: postDetailsGestureActions,
        postPreviewQuickActionButtonActions:
            postPreviewQuickActionButtonActions,
        describePostPreviewQuickAction: describePostPreviewQuickAction,
        describePostDetailsAction: describePostDetailsAction,
        config: config,
        postDetailsResolution: postDetailsResolution,
        miscOptions: miscOptions,
      ),
    };

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        titleSpacing: 0,
        title: SelectedBooruChip(
          config: config,
        ),
        actions: [
          BooruConfigDataProvider(
            builder: submitButtonBuilder != null
                ? submitButtonBuilder!
                : (data) => DefaultBooruSubmitButton(
                      data: data,
                    ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            const BooruConfigNameField(),
            Expanded(
              child: _TabControllerProvider(
                initialIndex: _findInitialIndexFromQuery(
                  initialTab,
                  tabMap,
                ),
                tabMap: tabMap,
                length: tabMap.length,
                animationDuration:
                    Screen.of(context).size.isLarge ? Duration.zero : null,
                builder: (controller) => Column(
                  children: [
                    const SizedBox(height: 4),
                    TabBar(
                      controller: controller,
                      labelPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      isScrollable: true,
                      tabs: [
                        for (final tab in tabMap.keys) Tab(text: tab.tr()),
                      ],
                    ),
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(
                          maxWidth: 700,
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: TabBarView(
                          controller: controller,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            for (final tab in tabMap.values)
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical:
                                      Screen.of(context).size.isLarge ? 16 : 8,
                                ),
                                child: tab,
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (isNewConfig)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Not sure? Leave it as it is, you can change it later.',
                              style: context.textTheme.titleSmall?.copyWith(
                                color: context.theme.hintColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (footer != null) footer!,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

int _findInitialIndexFromQuery(
  String? query,
  Map<String, Widget> tabMap,
) {
  final q = query?.toLowerCase();

  if (q == null) {
    return 0;
  }

  final tabNames = tabMap.keys.toList();

  for (var i = 0; i < tabNames.length; i++) {
    final tabName = tabNames[i].toLowerCase();

    if (tabName.contains(q)) {
      return i;
    }
  }

  return 0;
}

class _TabControllerProvider extends StatefulWidget {
  const _TabControllerProvider({
    required this.tabMap,
    required this.animationDuration,
    required this.length,
    this.initialIndex,
    required this.builder,
  });

  final Map<String, Widget> tabMap;
  final Duration? animationDuration;
  final int length;
  final int? initialIndex;
  final Widget Function(TabController controller) builder;

  @override
  State<_TabControllerProvider> createState() => _TabControllerProviderState();
}

class _TabControllerProviderState extends State<_TabControllerProvider>
    with SingleTickerProviderStateMixin {
  late final _controller = TabController(
    length: widget.length,
    vsync: this,
    animationDuration: widget.animationDuration,
    initialIndex: widget.initialIndex ?? 0,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(_controller);
  }
}

class BooruConfigSettingsHeader extends StatelessWidget {
  const BooruConfigSettingsHeader({
    super.key,
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        label,
        style: TextStyle(
          color: context.colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
