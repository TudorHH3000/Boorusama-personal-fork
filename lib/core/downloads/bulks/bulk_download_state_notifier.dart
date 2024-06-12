// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';

class BulkDownloadStateNotifier
    extends FamilyNotifier<BulkDownloadState, BooruConfig> {
  @override
  BulkDownloadState build(BooruConfig arg) {
    ref.listen(
      bulkDownloadManagerStatusProvider,
      (previous, next) {
        if (next == BulkDownloadManagerStatus.initial) {
          ref.invalidateSelf();
        }
      },
    );

    ref.listen(
      bulkDownloadDataProvider(arg),
      (previous, next) {
        next.whenData((value) {
          updateDownloadStatus(url: value.url, status: value);
        });
      },
    );

    return BulkDownloadState.initial();
  }

  void addDownloadSize(int fileSize) {
    state = state.copyWith(
      estimatedDownloadSize: state.estimatedDownloadSize + fileSize,
    );
  }

  void updateDownloadStatus({
    required String url,
    required DownloadStatus status,
  }) {
    state = state.copyWith(
      downloadStatuses: {
        ...state.downloadStatuses,
        url: status,
      },
    );
  }

  void updateDownloadToInitilizingState(
    String url,
  ) {
    updateDownloadStatus(
      url: url,
      status: DownloadInitializing(
        url,
        state.downloadStatuses[url]!.fileName,
      ),
    );
  }
}
