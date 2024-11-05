// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/create/create.dart';
import 'package:boorusama/core/configs/export_import/export_import.dart';
import 'package:boorusama/core/configs/manage/manage.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/analytics.dart';

class BooruConfigNotifier extends Notifier<List<BooruConfig>?>
    with BooruConfigExportImportMixin {
  @override
  List<BooruConfig>? build() {
    fetch();
    return null;
  }

  Future<void> fetch() async {
    final configs = await ref.read(booruConfigRepoProvider).getAll();
    state = configs;
  }

  Future<void> _add(BooruConfig booruConfig) async {
    final orders = ref.read(settingsProvider).booruConfigIdOrderList;
    final newOrders = [...orders, booruConfig.id];

    await ref.read(settingsProvider.notifier).updateOrder(newOrders);

    state = [...state ?? [], booruConfig];
  }

  Future<void> duplicate({
    required BooruConfig config,
  }) {
    final copyData = config.copyWith(
      name: '${config.name} copy',
    );

    return add(
      data: copyData.toBooruConfigData(),
    );
  }

  Future<void> delete(
    BooruConfig config, {
    void Function(String message)? onFailure,
    void Function(BooruConfig booruConfig)? onSuccess,
  }) async {
    if (state == null) return;
    try {
      // check if deleting the last config
      if (state!.length == 1) {
        await ref.read(booruConfigRepoProvider).remove(config);
        state = null;
        // reset order
        await ref.read(settingsProvider.notifier).updateOrder([]);
        await ref.read(currentBooruConfigProvider.notifier).setEmpty();

        onSuccess?.call(config);

        return;
      }

      // check if deleting current config, if so, set current to the first config
      final currentConfig = ref.read(currentBooruConfigProvider);
      if (currentConfig.id == config.id) {
        final firstConfig = state!.first;

        // check if deleting the first config
        final targetConfig =
            firstConfig.id == config.id ? state!.skip(1).first : firstConfig;

        await ref
            .read(currentBooruConfigProvider.notifier)
            .update(targetConfig);
      }

      await ref.read(booruConfigRepoProvider).remove(config);
      final orders = ref.read(settingsProvider).booruConfigIdOrderList;
      final newOrders = [...orders..remove(config.id)];

      await ref.read(settingsProvider.notifier).updateOrder(newOrders);

      final tmp = [...state!];
      tmp.remove(config);
      state = tmp;
      onSuccess?.call(config);
    } catch (e) {
      onFailure?.call(e.toString());
    }
  }

  Future<void> update({
    required BooruConfigData booruConfigData,
    required int oldConfigId,
    void Function(String message)? onFailure,
    void Function(BooruConfig booruConfig)? onSuccess,
  }) async {
    if (state == null) return;
    final updatedConfig = await ref
        .read(booruConfigRepoProvider)
        .update(oldConfigId, booruConfigData);

    if (updatedConfig == null) {
      onFailure?.call('Failed to update account');

      return;
    }

    final newConfigs =
        state!.replaceFirst(updatedConfig, (item) => item.id == oldConfigId);

    onSuccess?.call(updatedConfig);

    state = newConfigs;
  }

  Future<void> add({
    required BooruConfigData data,
    void Function(String message)? onFailure,
    void Function(BooruConfig booruConfig)? onSuccess,
    bool setAsCurrent = false,
  }) async {
    try {
      final config = await ref.read(booruConfigRepoProvider).add(data);

      if (config == null) {
        onFailure?.call('Fail to add account. Account might be incorrect');

        return;
      }

      onSuccess?.call(config);
      ref.read(analyticsProvider).sendBooruAddedEvent(
            url: config.url,
            hintSite: config.booruType.name,
            totalSites: state?.length ?? 0,
            hasLogin: config.hasLoginDetails(),
          );

      await _add(config);

      if (setAsCurrent || state?.length == 1) {
        await ref.read(currentBooruConfigProvider.notifier).update(config);
      }
    } catch (e) {
      onFailure?.call('Failed to add account');
    }
  }
}

extension BooruConfigNotifierX on BooruConfigNotifier {
  void addOrUpdate({
    required EditBooruConfigId id,
    required BooruConfigData newConfig,
  }) {
    if (id.isNew) {
      ref.read(booruConfigProvider.notifier).add(
            data: newConfig,
          );
    } else {
      ref.read(booruConfigProvider.notifier).update(
            booruConfigData: newConfig,
            oldConfigId: id.id,
            onSuccess: (booruConfig) {
              // if edit current config, update current config
              final currentConfig = ref.read(currentBooruConfigProvider);

              if (currentConfig.id == booruConfig.id) {
                ref
                    .read(currentBooruConfigProvider.notifier)
                    .update(booruConfig);
              }
            },
          );
    }
  }
}
