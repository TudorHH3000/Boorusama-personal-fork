// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/home/home.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/router.dart';
import 'szurubooru.dart';
import 'szurubooru_pool_page.dart';

class SzurubooruHomePage extends StatelessWidget {
  const SzurubooruHomePage({
    super.key,
    required this.config,
  });

  final BooruConfig config;

  @override
  Widget build(BuildContext context) {
    return HomePageScaffold(
      mobileMenu: [
        if (config.hasLoginDetails()) ...[
          SideMenuTile(
            icon: const Icon(Symbols.favorite),
            title: Text('profile.favorites'.tr()),
            onTap: () => goToFavoritesPage(context),
          ),
          SideMenuTile(
            icon: const Icon(Symbols.photo_album),
            title: const Text('Pools'),
            onTap: () => goToPoolPage(context),
          ),
        ]
      ],
      desktopMenuBuilder: (context, controller, constraints) => [
        if (config.hasLoginDetails()) ...[
          HomeNavigationTile(
            value: 1,
            controller: controller,
            constraints: constraints,
            selectedIcon: Symbols.favorite,
            icon: Symbols.favorite,
            title: 'Favorites',
          ),
          HomeNavigationTile(
            value: 2,
            controller: controller,
            constraints: constraints,
            selectedIcon: Symbols.photo_album,
            icon: Symbols.photo_album,
            title: 'Pools',
          ),
        ],
      ],
      desktopViews: [
        if (config.hasLoginDetails()) ...[
          SzurubooruFavoritesPage(username: config.name),
        ],
        const SzurubooruPoolPage(),
      ],
    );
  }
}
