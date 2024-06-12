// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:background_downloader/background_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:readmore/readmore.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/core/pages/settings/settings.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/string.dart';
import 'package:boorusama/widgets/widgets.dart';

final downloadFilterProvider =
    StateProvider.family<DownloadFilter2, String?>((ref, initialFilter) {
  return _convertFilter(initialFilter);
});

DownloadFilter2 _convertFilter(String? filter) => switch (filter) {
      'error' => DownloadFilter2.failed,
      'running' => DownloadFilter2.inProgress,
      'complete' => DownloadFilter2.completed,
      _ => DownloadFilter2.all,
    };

final downloadFilteredProvider =
    Provider.family<List<TaskUpdate>, String?>((ref, initialFilter) {
  final filter = ref.watch(downloadFilterProvider(initialFilter));
  final state = ref.watch(downloadTasksProvider);

  return switch (filter) {
    DownloadFilter2.all => state.toList(),
    DownloadFilter2.pending => state
        .whereType<TaskStatusUpdate>()
        .where((e) => e.status == TaskStatus.enqueued)
        .toList(),
    DownloadFilter2.paused => state
        .whereType<TaskStatusUpdate>()
        .where((e) => e.status == TaskStatus.paused)
        .toList(),
    DownloadFilter2.inProgress =>
      state.whereType<TaskProgressUpdate>().toList(),
    DownloadFilter2.completed => state
        .whereType<TaskStatusUpdate>()
        .where((e) => e.status == TaskStatus.complete)
        .toList(),
    DownloadFilter2.failed => state
        .whereType<TaskStatusUpdate>()
        .where((e) =>
            e.status == TaskStatus.failed || e.status == TaskStatus.notFound)
        .toList(),
    DownloadFilter2.canceled => state
        .whereType<TaskStatusUpdate>()
        .where((e) => e.status == TaskStatus.canceled)
        .toList(),
  };
});

class DownloadManagerGatewayPage extends ConsumerWidget {
  const DownloadManagerGatewayPage({
    super.key,
    this.filter,
  });

  final String? filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useLegacy = ref
        .watch(settingsProvider.select((value) => value.useLegacyDownloader));

    return useLegacy
        ? const DisabledDownloadManagerPage()
        : DownloadManagerPage(filter: filter);
  }
}

class DisabledDownloadManagerPage extends StatelessWidget {
  const DisabledDownloadManagerPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Download manager is disabled',
                style: context.textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'You are using the legacy downloader. Please enable the new downloader in the settings.',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.theme.hintColor,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  openDownloadSettingsPage(context);
                },
                child: const Text('Open settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _filterOptions = [
  DownloadFilter2.all,
  DownloadFilter2.inProgress,
  DownloadFilter2.pending,
  DownloadFilter2.paused,
  DownloadFilter2.failed,
  DownloadFilter2.canceled,
  DownloadFilter2.completed,
];

class DownloadManagerPage extends ConsumerStatefulWidget {
  const DownloadManagerPage({
    super.key,
    this.filter,
  });

  final String? filter;

  @override
  ConsumerState<DownloadManagerPage> createState() =>
      _DownloadManagerPageState();
}

class _DownloadManagerPageState extends ConsumerState<DownloadManagerPage> {
  final scrollController = AutoScrollController();

  @override
  void initState() {
    super.initState();

    if (widget.filter != null) {
      // scroll to the selected filter
      final filterType = _convertFilter(widget.filter);
      final index = _filterOptions.indexOf(filterType);

      if (index != -1) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          scrollController.scrollToIndex(
            index,
            preferPosition: AutoScrollPosition.end,
            duration: const Duration(milliseconds: 100),
          );
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(downloadFilteredProvider(widget.filter));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              openDownloadSettingsPage(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              ref.read(downloadTasksProvider.notifier).state = [];
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Builder(
              builder: (context) {
                final selectedFilter =
                    ref.watch(downloadFilterProvider(widget.filter));

                return ChoiceOptionSelectorList(
                  scrollController: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  searchable: false,
                  options: _filterOptions,
                  hasNullOption: false,
                  optionLabelBuilder: (value) =>
                      value?.name.sentenceCase ?? 'Unknown',
                  onSelected: (value) {
                    if (value == null) return;

                    ref
                        .read(downloadFilterProvider(widget.filter).notifier)
                        .state = value;
                  },
                  selectedOption: selectedFilter,
                );
              },
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: tasks.isNotEmpty
                    ? ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return SimpleDownloadTile(
                            task: task,
                            onResume: () {
                              final dt = castOrNull<DownloadTask>(task.task);

                              if (dt == null) return;

                              FileDownloader().resume(dt);
                            },
                            onPause: () {
                              final dt = castOrNull<DownloadTask>(task.task);

                              if (dt == null) return;

                              FileDownloader().pause(dt);
                            },
                            onResumeFailed: () {
                              final dt = castOrNull<DownloadTask>(task.task);

                              if (dt == null) return;

                              FileDownloader().resume(dt);
                            },
                            onRestart: () {
                              FileDownloader().enqueue(task.task);
                            },
                            onCancel: () {
                              FileDownloader()
                                  .cancelTaskWithId(task.task.taskId);
                            },
                          );
                        },
                      )
                    : Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: switch (ref
                                .watch(downloadFilterProvider(widget.filter))) {
                              DownloadFilter2.failed =>
                                const Text('No failed downloads'),
                              DownloadFilter2.inProgress =>
                                const Text('No downloads in progress'),
                              DownloadFilter2.pending =>
                                const Text('No pending downloads'),
                              DownloadFilter2.paused =>
                                const Text('No paused downloads'),
                              DownloadFilter2.completed =>
                                const Text('No completed downloads'),
                              DownloadFilter2.canceled =>
                                const Text('No canceled downloads'),
                              _ => const Text('No downloads'),
                            },
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 24,
                              horizontal: 8,
                            ),
                            child: Text(
                              'This feature is still in experimental phase, please report any issues to the developer. You can also switch back to the legacy downloader in the settings.',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.theme.hintColor,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            RetryAllFailedButton(filter: widget.filter),
          ],
        ),
      ),
    );
  }
}

class RetryAllFailedButton extends ConsumerWidget {
  const RetryAllFailedButton({
    super.key,
    this.filter,
  });

  final String? filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final failed = ref
        .watch(downloadFilteredProvider(filter))
        .whereType<TaskStatusUpdate>()
        .where((e) => e.status == TaskStatus.failed)
        .toList();

    return ref.watch(downloadFilterProvider(filter)) ==
                DownloadFilter2.failed &&
            failed.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.all(12),
            child: FilledButton(
              onPressed: () {
                for (final task in failed) {
                  final dt = castOrNull<DownloadTask>(task.task);

                  if (dt == null) continue;

                  FileDownloader().enqueue(dt);
                }
              },
              child: const Text('Retry all'),
            ),
          )
        : const SizedBox.shrink();
  }
}

final _checkResumableProvider =
    FutureProvider.autoDispose.family<bool, Task>((ref, task) async {
  return FileDownloader().taskCanResume(task);
});

extension TaskCancelX on TaskUpdate {
  bool get isCanceled => switch (this) {
        TaskStatusUpdate u => u.status == TaskStatus.canceled,
        TaskProgressUpdate _ => false,
      };

  bool get canCancel => switch (this) {
        TaskStatusUpdate u => switch (u.status) {
            TaskStatus.failed => false,
            TaskStatus.paused => false,
            TaskStatus.running => true,
            TaskStatus.enqueued => true,
            TaskStatus.complete => false,
            TaskStatus.notFound => false,
            TaskStatus.canceled => false,
            TaskStatus.waitingToRetry => true,
          },
        TaskProgressUpdate _ => true,
      };
}

final _filePathProvider = FutureProvider.autoDispose
    .family<String, Task>((ref, task) => task.filePath());

class SimpleDownloadTile extends ConsumerWidget {
  const SimpleDownloadTile({
    super.key,
    required this.task,
    required this.onResume,
    required this.onPause,
    required this.onResumeFailed,
    required this.onRestart,
    required this.onCancel,
  });

  final TaskUpdate task;
  final void Function() onResume;
  final void Function() onPause;
  final void Function() onResumeFailed;
  final void Function() onRestart;
  final void Function() onCancel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metadata = DownloaderMetadata.fromJsonString(task.task.metaData);

    return DownloadTileBuilder(
      url: task.task.url,
      thumbnailUrl: metadata.thumbnailUrl,
      siteUrl: metadata.siteUrl,
      fileSize: switch (task) {
        TaskStatusUpdate _ => metadata.fileSize,
        TaskProgressUpdate p =>
          p.hasExpectedFileSize ? p.expectedFileSize : metadata.fileSize,
      },
      networkSpeed: switch (task) {
        TaskStatusUpdate _ => null,
        TaskProgressUpdate p => p.hasNetworkSpeed ? p.networkSpeed : null,
      },
      timeRemaining: switch (task) {
        TaskStatusUpdate _ => null,
        TaskProgressUpdate p => p.hasTimeRemaining ? p.timeRemaining : null,
      },
      onCancel: task.canCancel ? onCancel : null,
      builder: (_) => RawDownloadTile(
        fileName: task.task.filename,
        strikeThrough: task.isCanceled,
        color: task.isCanceled ? context.theme.hintColor : null,
        trailing: switch (task) {
          TaskStatusUpdate s => switch (s.status) {
              TaskStatus.failed =>
                ref.watch(_checkResumableProvider(task.task)).when(
                      data: (value) => value
                          ? IconButton(
                              onPressed: () => onResumeFailed.call(),
                              icon: const Icon(
                                Symbols.refresh,
                                fill: 1,
                              ),
                            )
                          : IconButton(
                              onPressed: () => onRestart.call(),
                              icon: const Icon(
                                Symbols.refresh,
                                fill: 1,
                              ),
                            ),
                      loading: () => const Center(
                        child: SizedBox(
                          height: 12,
                          width: 12,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (e, _) => const SizedBox.shrink(),
                    ),
              TaskStatus.paused => IconButton(
                  onPressed: () => onResume.call(),
                  icon: const Icon(
                    Symbols.play_arrow,
                    fill: 1,
                  ),
                ),
              TaskStatus.running => IconButton(
                  onPressed: () => onPause(),
                  icon: const Icon(
                    Symbols.pause,
                    fill: 1,
                  ),
                ),
              TaskStatus.complete => const Icon(
                  Symbols.download_done,
                  color: Colors.green,
                ),
              TaskStatus.enqueued => const SizedBox.shrink(),
              TaskStatus.notFound => const SizedBox.shrink(),
              TaskStatus.canceled => const SizedBox.shrink(),
              TaskStatus.waitingToRetry =>
                const Center(child: CircularProgressIndicator()),
            },
          TaskProgressUpdate _ => IconButton(
              onPressed: () => onPause(),
              icon: const Icon(
                Symbols.pause,
                fill: 1,
              ),
            ),
        },
        subtitle: switch (task) {
          TaskStatusUpdate s => _TaskSubtitle(task: s),
          TaskProgressUpdate p => p.progress >= 0
              ? LinearPercentIndicator(
                  lineHeight: 2,
                  percent: p.progress,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  animation: true,
                  animateFromLastPercent: true,
                  trailing: Text(
                    '${(p.progress * 100).floor()}%',
                  ),
                )
              : const SizedBox.shrink(),
        },
        url: task.task.url,
      ),
    );
  }
}

class _TaskSubtitle extends ConsumerWidget {
  const _TaskSubtitle({
    required this.task,
  });

  final TaskStatusUpdate task;

  String _prettifyFilePathIfNeeded(String path) {
    if (isAndroid()) {
      if (path.startsWith('/storage/emulated/0/')) {
        return path.replaceAll('/storage/emulated/0/', '/');
      }
    }

    return path;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = task;
    return ReadMoreText(
      s.exception?.description == null
          ? switch (s.status) {
              TaskStatus.complete =>
                ref.watch(_filePathProvider(task.task)).maybeWhen(
                      data: (data) => _prettifyFilePathIfNeeded(data),
                      orElse: () => '...',
                    ),
              _ => s.status.name.sentenceCase,
            }
          : 'Failed: ${s.exception!.description} ',
      trimLines: 1,
      trimMode: TrimMode.Line,
      trimCollapsedText: ' more',
      trimExpandedText: ' less',
      lessStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: context.colorScheme.primary,
      ),
      moreStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: context.colorScheme.primary,
      ),
      style: TextStyle(
        color: Theme.of(context).hintColor,
        fontSize: 12,
      ),
    );
  }
}
