// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_portal/flutter_portal.dart';
import 'package:oktoast/oktoast.dart';

// Project imports:
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/foundation/analytics.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'widgets/platforms/platforms.dart';

final navigatorKey = GlobalKey<NavigatorState>();
const kMinSideBarWidth = 62.0;

class App extends StatelessWidget {
  const App({
    super.key,
    required this.appName,
    required this.initialSettings,
  });

  final String appName;
  final Settings initialSettings;

  @override
  Widget build(BuildContext context) {
    return Portal(
      child: OKToast(
        child: AnalyticsScope(
          settings: initialSettings,
          builder: (analyticsEnabled) => RouterBuilder(
            analyticsEnabled: analyticsEnabled,
            builder: (context, router) => ThemeBuilder(
              builder: (theme, themeMode) => MaterialApp.router(
                builder: (context, child) => ConditionalParentWidget(
                  condition: isDesktopPlatform(),
                  conditionalBuilder: (child) => WindowTitleBar(
                    appName: appName,
                    child: child,
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      iconTheme: Theme.of(context).iconTheme.copyWith(
                            weight: isWindows() ? 200 : 400,
                          ),
                    ),
                    child: ScrollConfiguration(
                      behavior: const MaterialScrollBehavior()
                          .copyWith(overscroll: false),
                      child: child!,
                    ),
                  ),
                ),
                theme: theme,
                themeMode: themeMode,
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
                debugShowCheckedModeBanner: false,
                title: appName,
                routerConfig: router,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
