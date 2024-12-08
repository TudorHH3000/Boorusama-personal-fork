// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/foundation/networking.dart';
import 'analytics_network_info.dart';
import 'analytics_providers.dart';

class NetworkListener extends ConsumerWidget {
  const NetworkListener({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(analyticsProvider);

    ref.listen(
      connectivityProvider,
      (previous, next) {
        next.when(
          data: (data) {
            if (data.isEmpty || data.contains(ConnectivityResult.none)) {
              analytics.updateNetworkInfo(
                const AnalyticsNetworkInfo.disconnected(),
              );
            } else {
              analytics.updateNetworkInfo(
                AnalyticsNetworkInfo.connected(data.prettyString),
              );
            }
          },
          error: (error, stackTrace) {
            analytics.updateNetworkInfo(
              AnalyticsNetworkInfo.error(error.toString()),
            );
          },
          loading: () {},
        );
      },
    );

    return child;
  }
}
