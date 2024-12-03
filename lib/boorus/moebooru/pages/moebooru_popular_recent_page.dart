// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/functional.dart';
import '../feats/posts/posts.dart';
import 'widgets/period_toggle_switch.dart';

class MoebooruPopularRecentPage extends ConsumerStatefulWidget {
  const MoebooruPopularRecentPage({
    super.key,
  });

  @override
  ConsumerState<MoebooruPopularRecentPage> createState() =>
      _MoebooruPopularPageState();
}

class _MoebooruPopularPageState
    extends ConsumerState<MoebooruPopularRecentPage> {
  final selectedPeriod = ValueNotifier(MoebooruTimePeriod.day);

  MoebooruPopularRepository get repo =>
      ref.read(moebooruPopularRepoProvider(ref.readConfigAuth));

  @override
  Widget build(BuildContext context) {
    return PostScope(
      fetcher: (page) => page > 1
          ? TaskEither.of(<Post>[].toResult())
          : repo.getPopularPostsRecent(selectedPeriod.value),
      builder: (context, controller) => Column(
        children: [
          PeriodToggleSwitch(
            onToggle: (period) {
              selectedPeriod.value = period;
              controller.refresh();
            },
          ),
          const SizedBox(height: 12),
          Expanded(
            child: PostGrid(
              controller: controller,
            ),
          ),
        ],
      ),
    );
  }
}
