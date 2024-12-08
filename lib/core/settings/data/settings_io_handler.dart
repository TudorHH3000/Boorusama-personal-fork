// Package imports:
import 'package:foundation/foundation.dart';

// Project imports:
import 'package:boorusama/core/backups/data_io_handler.dart';
import 'package:boorusama/core/backups/types.dart';
import '../settings.dart';

class SettingsIOHandler {
  SettingsIOHandler({
    required this.handler,
  });

  final DataIOHandler handler;

  TaskEither<ExportError, Unit> export(
    Settings settings, {
    required String to,
  }) =>
      handler.export(
        data: [
          settings.toJson(),
        ],
        path: to,
      );

  TaskEither<ImportError, SettingsExportData> import({
    required String from,
  }) =>
      TaskEither.Do(
        ($) async {
          final data = await $(handler.import(path: from));

          final transformed = await $(Either.tryCatch(
            () => Settings.fromJson(data.data.first),
            (e, st) => const ImportInvalidJsonField(),
          ).toTaskEither());

          return SettingsExportData(
            data: transformed,
            exportData: data,
          );
        },
      );
}

//FIXME: need to be abstracted as well
class SettingsExportData {
  SettingsExportData({
    required this.data,
    required this.exportData,
  });

  final Settings data;
  final ExportDataPayload exportData;
}
