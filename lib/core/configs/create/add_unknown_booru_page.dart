// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/create/create.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/widgets/widgets.dart';

class AddUnknownBooruPage extends ConsumerWidget {
  const AddUnknownBooruPage({
    super.key,
    this.setCurrentBooruOnSubmit = false,
    this.backgroundColor,
  });

  final bool setCurrentBooruOnSubmit;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: backgroundColor,
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.viewPaddingOf(context).top,
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Text(
                    'Select a booru engine to continue',
                    style: context.textTheme.headlineSmall!
                        .copyWith(fontWeight: FontWeight.w900),
                  ),
                ),
                const Divider(
                  thickness: 2,
                  endIndent: 16,
                  indent: 16,
                ),
                const InvalidBooruWarningContainer(),
                const UnknownConfigBooruSelector(),
                const BooruConfigNameField(),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const BooruUrlField(),
                      if (ref.watch(booruEngineProvider) != BooruType.hydrus)
                        const SizedBox(height: 16),
                      if (ref.watch(booruEngineProvider) != BooruType.hydrus)
                        Text(
                          'Advanced options (optional)',
                          style: context.textTheme.titleMedium,
                        ),
                      if (ref.watch(booruEngineProvider) != BooruType.hydrus)
                        const DefaultBooruInstructionText(
                          '*These options only be used if the site allows it.',
                        ),
                      //FIXME: make this part of the config customisable
                      if (ref.watch(booruEngineProvider) != BooruType.hydrus)
                        const SizedBox(height: 16),
                      if (ref.watch(booruEngineProvider) != BooruType.hydrus)
                        const DefaultBooruLoginField(),
                      const SizedBox(height: 16),
                      const DefaultBooruApiKeyField(),
                      const SizedBox(height: 16),
                      const UnknownBooruSubmitButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.viewPaddingOf(context).top,
            right: 8,
            child: IconButton(
              onPressed: context.navigator.pop,
              icon: const Icon(Symbols.close),
            ),
          ),
        ],
      ),
    );
  }
}

final _targetConfigToValidateProvider =
    StateProvider.autoDispose<BooruConfig?>((ref) {
  return null;
});

final _validateConfigProvider = FutureProvider.autoDispose<bool?>((ref) async {
  final config = ref.watch(_targetConfigToValidateProvider);
  if (config == null) return null;
  final result = await ref.watch(booruSiteValidatorProvider(config).future);
  return result;
});

class UnknownBooruSubmitButton extends ConsumerWidget {
  const UnknownBooruSubmitButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editId = ref.watch(editBooruConfigIdProvider);
    final config = ref.watch(initialBooruConfigProvider);
    final auth = ref.watch(editBooruConfigProvider(editId)
        .select((value) => AuthConfigData.fromConfig(value)));
    final configName = ref
        .watch(editBooruConfigProvider(editId).select((value) => value.name));
    final url = ref.watch(_siteUrlProvider(config));
    final engine = ref.watch(booruEngineProvider);

    final isValid = engine != null &&
        //FIXME: make this check customisable
        (engine == BooruType.hydrus ? auth.apiKey.isNotEmpty : auth.isValid) &&
        configName.isNotEmpty;

    return ref.watch(_validateConfigProvider).when(
          data: (value) => value != null
              ? BooruConfigDataProvider(
                  builder: (data) => CreateBooruSubmitButton(
                    fill: true,
                    backgroundColor: value ? Colors.green : null,
                    onSubmit: isValid
                        ? () {
                            ref.read(booruConfigProvider.notifier).addOrUpdate(
                                  id: editId,
                                  newConfig: data.copyWith(
                                    booruIdHint: () => engine.toBooruId(),
                                  ),
                                );

                            context.navigator.pop();
                          }
                        : null,
                    child: value == true
                        ? const Text('booru.config_booru_confirm').tr()
                        : const Text('Verify'),
                  ),
                )
              : CreateBooruSubmitButton(
                  fill: true,
                  onSubmit: isValid
                      ? () {
                          ref
                              .read(_targetConfigToValidateProvider.notifier)
                              .state = BooruConfig.defaultConfig(
                            booruType: engine,
                            url: url!,
                            customDownloadFileNameFormat: null,
                          ).copyWith(
                            login: auth.login,
                            apiKey: auth.apiKey,
                          );
                        }
                      : null,
                  child: const Text('Verify'),
                ),
          loading: () => CreateBooruSubmitButton(
            fill: true,
            backgroundColor: context.colorScheme.hintColor,
            onSubmit: null,
            child: Center(
              child: SizedBox(
                height: 12,
                width: 12,
                child: CircularProgressIndicator(),
              ),
            ),
          ),
          error: (err, _) => CreateBooruSubmitButton(
            fill: true,
            onSubmit: isValid
                ? () {
                    ref.read(_targetConfigToValidateProvider.notifier).state =
                        null;
                    // clear selected engine
                    ref.read(booruEngineProvider.notifier).state = null;
                  }
                : null,
            child: const Text('Clear'),
          ),
        );
  }
}

class InvalidBooruWarningContainer extends ConsumerWidget {
  const InvalidBooruWarningContainer({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(_validateConfigProvider).maybeWhen(
          orElse: () => const SizedBox(),
          error: (error, st) => Stack(
            children: [
              WarningContainer(
                title: 'Error',
                contentBuilder: (context) => Text(
                  'It seems like the site is not running on the selected engine. Please try with another one.',
                  style: TextStyle(
                    color: context.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        );
  }
}

final _siteUrlProvider = StateProvider.autoDispose
    .family<String?, BooruConfig>((ref, config) => config.url);

class BooruUrlField extends ConsumerWidget {
  const BooruUrlField({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(initialBooruConfigProvider);

    return CreateBooruSiteUrlField(
      text: config.url,
      onChanged: (value) =>
          ref.read(_siteUrlProvider(config).notifier).state = value,
    );
  }
}

final booruEngineProvider =
    StateProvider.autoDispose<BooruType?>((ref) => null);

class UnknownConfigBooruSelector extends ConsumerWidget {
  const UnknownConfigBooruSelector({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engine = ref.watch(booruEngineProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 8,
      ),
      child: ListTile(
        title: const Text('booru.booru_engine_input_label').tr(),
        trailing: OptionDropDownButton(
          alignment: AlignmentDirectional.centerStart,
          value: engine,
          onChanged: (value) {
            ref.read(booruEngineProvider.notifier).state = value;
          },
          items: BooruType.values
              .where((e) =>
                  e != BooruType.unknown &&
                  e != BooruType.gelbooru &&
                  e != BooruType.animePictures)
              .sorted((a, b) => a.stringify().compareTo(b.stringify()))
              .map((value) => DropdownMenuItem(
                    value: value,
                    child: Text(value.stringify()),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
