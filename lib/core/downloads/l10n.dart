// Project imports:
import 'downloads.dart';
import 'types.dart';

export 'package:boorusama/foundation/i18n.dart';

extension DownloadFilterLocalize on DownloadFilter? {
  String localize() => switch (this) {
        DownloadFilter.all => 'All',
        DownloadFilter.pending => 'Pending',
        DownloadFilter.paused => 'Paused',
        DownloadFilter.inProgress => 'In Progress',
        DownloadFilter.completed => 'Completed',
        DownloadFilter.canceled => 'Canceled',
        DownloadFilter.failed => 'Failed',
        null => 'Unknown',
      };

  String emptyLocalize() => switch (this) {
        DownloadFilter.all => 'No downloads',
        DownloadFilter.pending => 'No pending downloads',
        DownloadFilter.paused => 'No paused downloads',
        DownloadFilter.inProgress => 'No downloads in progress',
        DownloadFilter.completed => 'No completed downloads',
        DownloadFilter.canceled => 'No canceled downloads',
        DownloadFilter.failed => 'No failed downloads',
        null => 'No downloads',
      };
}

class DownloadTranslations {
  const DownloadTranslations._();

  static const String downloadManagerTitle = 'Downloads';

  static const String retryAllFailed = 'Retry all';
  static const String cancel = 'Cancel';

  static const String downloadFailedNotification = 'failed';
  static const String downloadCompletedNotification = 'completed';
  static const String downloadStartedNotification = 'Download started';
  static const String downloadNothingToClear = 'Nothing to clear';

  static const String downloadPath = 'settings.download.path';
  static const String downloadSelectFolder =
      'settings.download.select_a_folder';
  static const String downloadSelectFolderWarning =
      "The app can only download files inside public directories <b>({0})</b> for Android 11+. <br><br> Valid location examples:<br><b>[Internal]</b> /storage/emulated/0/Download <br><b>[SD card]</b> /storage/A1B2-C3D4/Download<br><br>Please choose another directory or create a new one if it doesn't exist. <br>This device's version is <b>{1}</b>.";

  static const String skipDownloadIfExists =
      'Ignore files that already downloaded';
  static const String skipDownloadIfExistsExplanation =
      "This will prevent downloading files that already exist in the folder. This is useful when you don't want to download the same file multiple times.";

  // Bulk download
  static const String bulkDownloadTitle = 'Bulk Download';
  static const String bulkDownloadNewDownloadTitle = 'New download';
  static const String bulkDownloadCreate = 'New download';
  static const String bulkDownloadEmpty = 'No downloads';
  static const String bulkDownloadDelete = 'Delete';
  static const String bulkDownloadCopyPath = 'Copy path';
  static const String bulkDownloadStart = 'Start';
  static const String bulkDownloadCancel = 'Cancel';
  static const String bulkDownloadStop = 'Stop';
  static const String bulkDownloadCreatedStatus = 'Created';
  static const String bulkDownloadDownload = 'Download';
  static const String bulkDownloadAddToQueue = 'Add to queue';
  static String bulkDownloadInProgressStatus(int? completed) =>
      'Fetching${completed != null ? ' page ${completed + 1}' : ''}...';
  static String bulkDownloadTitleInfoCounter(bool plural, bool isMixed) =>
      isMixed
          ? plural
              ? '{} files'
              : '{} file'
          : plural
              ? '{} images'
              : '{} image';
  static const String bulkDownloadSaveToFolder =
      'download.bulk_download_save_to_folder';
  static const String bulkdDownloadShowAdvancedOptions =
      'Show advanced options';
  static const String bulkDownloadEnableNotifications = 'Enable notifications';
  static const String bulkDownloadSelectFolder =
      'download.bulk_download_select_a_folder';
}
