// Project imports:
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/foundation/loggers.dart';

class SettingsRepositoryLoggerInterceptor implements SettingsRepository {
  SettingsRepositoryLoggerInterceptor(
    this.repository, {
    required Logger logger,
  }) : _logger = logger;
  final SettingsRepository repository;
  final Logger _logger;

  @override
  Future<bool> save(Settings setting) async => repository.save(setting);

  @override
  SettingsOrError load() =>
      repository.load().map((settings) => settings).mapLeft((error) {
        _logger.logE('Settings', 'Failed to load settings: $error');
        return error;
      });
}
