// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import 'package:boorusama/core/configs/ref.dart';
import 'package:boorusama/core/datetimes/datetime_selector.dart';
import 'package:boorusama/core/datetimes/time_scale_toggle_switch.dart';
import 'package:boorusama/core/datetimes/types.dart';
import 'package:boorusama/core/posts.dart';
import 'package:boorusama/core/posts/listing.dart';
import '../feats/posts/posts.dart';

enum MoebooruPopularType {
  recent,
  day,
  week,
  month,
}

class MoebooruPopularPage extends ConsumerStatefulWidget {
  const MoebooruPopularPage({
    super.key,
  });

  @override
  ConsumerState<MoebooruPopularPage> createState() =>
      _MoebooruPopularPageState();
}

class _MoebooruPopularPageState extends ConsumerState<MoebooruPopularPage> {
  final selectedDateNotifier = ValueNotifier(DateTime.now());
  final selectedPopular = ValueNotifier(MoebooruPopularType.day);

  MoebooruPopularRepository get repo =>
      ref.read(moebooruPopularRepoProvider(ref.readConfigAuth));

  DateTime get selectedDate => selectedDateNotifier.value;

  PostsOrError _typeToData(MoebooruPopularType type, int page) =>
      switch (type) {
        MoebooruPopularType.recent =>
          repo.getPopularPostsRecent(MoebooruTimePeriod.day),
        MoebooruPopularType.day => repo.getPopularPostsByDay(selectedDate),
        MoebooruPopularType.week => repo.getPopularPostsByWeek(selectedDate),
        MoebooruPopularType.month => repo.getPopularPostsByMonth(selectedDate)
      };

  @override
  Widget build(BuildContext context) {
    return PostScope(
      fetcher: (page) => page > 1
          ? TaskEither.of(<Post>[].toResult())
          : _typeToData(selectedPopular.value, page),
      builder: (context, controller) => Column(
        children: [
          Expanded(
            child: PostGrid(
              controller: controller,
              sliverHeaders: [
                SliverToBoxAdapter(
                  child: TimeScaleToggleSwitch(
                    onToggle: (category) {
                      selectedPopular.value =
                          _convertToMoebooruPopularType(category);
                      controller.refresh();
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
            margin: EdgeInsets.only(
              bottom: MediaQuery.viewPaddingOf(context).bottom,
            ),
            child: ValueListenableBuilder<DateTime>(
              valueListenable: selectedDateNotifier,
              builder: (context, d, __) =>
                  ValueListenableBuilder<MoebooruPopularType>(
                valueListenable: selectedPopular,
                builder: (_, type, __) => DateTimeSelector(
                  onDateChanged: (date) {
                    selectedDateNotifier.value = date;
                    controller.refresh();
                  },
                  date: d,
                  scale: _convertToTimeScale(type),
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

TimeScale _convertToTimeScale(MoebooruPopularType popularType) =>
    switch (popularType) {
      MoebooruPopularType.day || MoebooruPopularType.recent => TimeScale.day,
      MoebooruPopularType.week => TimeScale.week,
      MoebooruPopularType.month => TimeScale.month,
    };

MoebooruPopularType _convertToMoebooruPopularType(TimeScale timeScale) =>
    switch (timeScale) {
      TimeScale.day => MoebooruPopularType.day,
      TimeScale.week => MoebooruPopularType.week,
      TimeScale.month => MoebooruPopularType.month
    };
