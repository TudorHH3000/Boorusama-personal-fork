// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:share_handler/share_handler.dart';

// Project imports:
import 'package:boorusama/core/boorus.dart';
import 'package:boorusama/core/configs.dart';
import 'package:boorusama/core/home/home.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/foundation/url_launcher.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/utils/flutter_utils.dart';
import '../artists/artists.dart';
import '../blacklist/blacklist.dart';
import '../explores/danbooru_explore_page.dart';
import '../favorite_groups/favorite_groups.dart';
import '../favorites/favorites.dart';
import '../forums/forums.dart';
import '../pools/danbooru_pool_page.dart';
import '../router.dart';
import '../saved_searches/saved_searches.dart';
import '../tags/tags.dart';
import '../users/users.dart';

class DanbooruHomePage extends ConsumerStatefulWidget {
  const DanbooruHomePage({
    super.key,
  });

  @override
  ConsumerState<DanbooruHomePage> createState() => _DanbooruHomePageState();
}

class _DanbooruHomePageState extends ConsumerState<DanbooruHomePage> {
  StreamSubscription? _sharedMediaSubscription;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Only support Android for now
    if (!isAndroid()) return;

    _sharedMediaSubscription =
        ShareHandler.instance.sharedMediaStream.listen(_onSharedTextsReceived);
  }

  void _onSharedTextsReceived(SharedMedia media) {
    final text = media.content;
    final config = ref.readConfigAuth;
    final booruName = config.booruType.stringify();
    final booruUrl = config.url;

    if (config.hasStrictSFW) return;

    final uri = text != null ? Uri.tryParse(text) : null;
    final isHttp = uri?.scheme == 'http' || uri?.scheme == 'https';

    if (uri != null && isHttp) {
      context.navigator.push(CupertinoPageRoute(
        builder: (context) {
          return AlertDialog(
            title: Text('Upload to $booruName'),
            content: Text(
                'Are you sure you want to upload to $booruName?\n\n$text \n\nYou need to be logged in the browser to upload.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);

                  final encodedUri = Uri.encodeFull(uri.toString());
                  final url = '${booruUrl}uploads/new?url=$encodedUri';
                  launchExternalUrlString(url);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      ));
    }
  }

  @override
  void dispose() {
    _sharedMediaSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfigAuth;

    final userId = ref.watch(danbooruCurrentUserProvider(config)).maybeWhen(
          data: (user) => user?.id,
          orElse: () => null,
        );

    ref.listen(
      trendingTagsProvider(config),
      (previous, next) {
        // Only used to prevent the provider from being disposed
      },
    );

    return HomePageScaffold(
      mobileMenu: [
        if (config.hasLoginDetails() && userId != null)
          SideMenuTile(
            icon: const _Icon(
              Symbols.account_box,
            ),
            title: const Text('profile.profile').tr(),
            onTap: () {
              goToProfilePage(context);
            },
          ),
        SideMenuTile(
          icon: const _Icon(
            Symbols.explore,
          ),
          title: const Text('explore.explore').tr(),
          onTap: () => goToExplorePage(context),
        ),
        SideMenuTile(
          icon: const _Icon(
            Symbols.photo_album,
          ),
          title: const Text('Pools'),
          onTap: () {
            goToPoolPage(context, ref);
          },
        ),
        SideMenuTile(
          icon: const _Icon(
            Symbols.forum,
          ),
          title: const Text('forum.forum').tr(),
          onTap: () {
            goToForumPage(context);
          },
        ),
        SideMenuTile(
          icon: const _Icon(
            Symbols.search,
          ),
          title: const Text('Artists'),
          onTap: () {
            goToArtistSearchPage(context);
          },
        ),
        if (config.hasLoginDetails()) ...[
          SideMenuTile(
            icon: const _Icon(
              Symbols.favorite,
            ),
            title: Text('profile.favorites'.tr()),
            onTap: () {
              goToFavoritesPage(context);
            },
          ),
          SideMenuTile(
            icon: const _Icon(
              Symbols.collections,
            ),
            title: const Text('favorite_groups.favorite_groups').tr(),
            onTap: () {
              goToFavoriteGroupPage(context);
            },
          ),
          SideMenuTile(
            icon: const _Icon(
              Symbols.search,
            ),
            title: const Text('saved_search.saved_search').tr(),
            onTap: () {
              goToSavedSearchPage(context);
            },
          ),
          SideMenuTile(
            icon: const _Icon(
              Symbols.tag,
            ),
            title: const Text(
              'blacklisted_tags.blacklisted_tags',
            ).tr(),
            onTap: () {
              goToBlacklistedTagPage(context);
            },
          ),
        ]
      ],
      desktopMenuBuilder: (context, controller, constraints) => [
        HomeNavigationTile(
          value: 1,
          controller: controller,
          constraints: constraints,
          selectedIcon: Symbols.explore,
          icon: Symbols.explore,
          title: 'explore.explore'.tr(),
        ),
        HomeNavigationTile(
          value: 2,
          controller: controller,
          constraints: constraints,
          selectedIcon: Symbols.photo_album,
          icon: Symbols.photo_album,
          title: 'Pools',
        ),
        HomeNavigationTile(
          value: 3,
          controller: controller,
          constraints: constraints,
          selectedIcon: Symbols.forum,
          icon: Symbols.forum,
          title: 'forum.forum'.tr(),
        ),
        HomeNavigationTile(
          value: 4,
          controller: controller,
          constraints: constraints,
          selectedIcon: Symbols.search,
          icon: Symbols.search,
          title: 'Artists',
        ),
        if (config.hasLoginDetails()) ...[
          if (userId != null)
            HomeNavigationTile(
              value: 5,
              controller: controller,
              constraints: constraints,
              selectedIcon: Symbols.account_box,
              icon: Symbols.account_box,
              title: 'profile.profile'.tr(),
            ),
          HomeNavigationTile(
            value: 6,
            controller: controller,
            constraints: constraints,
            selectedIcon: Symbols.favorite,
            icon: Symbols.favorite,
            title: 'Favorites',
          ),
          HomeNavigationTile(
            value: 7,
            controller: controller,
            constraints: constraints,
            selectedIcon: Symbols.collections,
            icon: Symbols.collections,
            title: 'favorite_groups.favorite_groups'.tr(),
          ),
          HomeNavigationTile(
            value: 8,
            controller: controller,
            constraints: constraints,
            selectedIcon: Symbols.saved_search,
            icon: Symbols.saved_search,
            title: 'saved_search.saved_search'.tr(),
          ),
          HomeNavigationTile(
            value: 9,
            controller: controller,
            constraints: constraints,
            selectedIcon: Symbols.tag,
            icon: Symbols.tag,
            title: 'blacklisted_tags.blacklisted_tags'.tr(),
          ),
        ],
      ],
      desktopViews: [
        // 1
        const DanbooruExplorePageDesktop(),
        // 2
        const DanbooruPoolPage(),
        // 3
        const DanbooruForumPage(),
        // 4
        const DanbooruArtistSearchPage(),
        if (config.hasLoginDetails()) ...[
          if (userId != null)
            // 5
            const DanbooruProfilePage(
              hasAppBar: false,
            ),
          // 6
          const DanbooruFavoritesPage(),
          // 7
          const FavoriteGroupsPage(),
          // 8
          const SavedSearchFeedPage(),
          // 9
          const DanbooruBlacklistedTagsPage(),
        ],
      ],
    );
  }
}

class _Icon extends StatelessWidget {
  const _Icon(
    this.icon,
  );

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      fill: context.isLight ? 0 : 1,
    );
  }
}
