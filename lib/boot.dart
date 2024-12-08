// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:fvp/fvp.dart' as fvp;
import 'package:hive/hive.dart';
import 'package:stack_trace/stack_trace.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/tags/user_metatags/user_metatag_repository.dart';
import 'package:boorusama/core/analytics.dart';
import 'package:boorusama/core/boorus.dart';
import 'package:boorusama/core/boorus/providers.dart';
import 'package:boorusama/core/configs/config.dart';
import 'package:boorusama/core/configs/current.dart';
import 'package:boorusama/core/configs/manage.dart';
import 'package:boorusama/core/configs/src/bootstrap.dart';
import 'package:boorusama/core/downloads/bulks/notifications.dart';
import 'package:boorusama/core/favorited_tags/favorited_tags.dart';
import 'package:boorusama/core/http/providers.dart';
import 'package:boorusama/core/settings.dart';
import 'package:boorusama/core/settings/data.dart';
import 'package:boorusama/core/tags/categories/providers.dart';
import 'package:boorusama/core/tags/configs/providers.dart';
import 'package:boorusama/core/tags/configs/tag_info_service.dart';
import 'package:boorusama/core/tracking.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/app_info.dart';
import 'package:boorusama/foundation/device_info.dart';
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/foundation/http.dart';
import 'package:boorusama/foundation/loggers.dart';
import 'package:boorusama/foundation/mobile.dart';
import 'package:boorusama/foundation/package_info.dart';
import 'package:boorusama/foundation/path.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/windows.dart' as window;
import 'app.dart';
import 'boorus/danbooru/tags/user_metatags/providers.dart';
import 'boorus/danbooru/users/creator/providers.dart';
import 'core/blacklists/hive/tag_repository.dart';
import 'core/blacklists/providers.dart';
import 'core/bookmarks/hive/object.dart';
import 'core/bookmarks/hive/repository.dart';
import 'core/bookmarks/providers.dart';
import 'core/cache/providers.dart';
import 'core/downloads/notifications.dart';
import 'core/search/boot.dart';

Future<void> failsafe(Object e, StackTrace st, BootLogger logger) async {
  final deviceInfo =
      await DeviceInfoService(plugin: DeviceInfoPlugin()).getDeviceInfo();
  final logs = logger.dump();

  runApp(
    ProviderScope(
      overrides: [
        deviceInfoProvider.overrideWithValue(deviceInfo),
      ],
      child: MaterialApp(
        theme: ThemeData.dark(),
        debugShowCheckedModeBanner: false,
        home: AppFailedToInitialize(
          error: e,
          stackTrace: st,
          logs: logs,
        ),
      ),
    ),
  );
}

Future<void> boot(BootLogger bootLogger) async {
  final appLogger = AppLogger();
  bootLogger.l('Initialize app logger');
  final logger = await loggerWith(appLogger);
  final stopwatch = Stopwatch()..start();
  logger.logI('Start up', 'App Start up');

  if (isDesktopPlatform()) {
    await window.initialize();
  }

  bootLogger.l("Load database's directory");
  final dbDirectory = isAndroid()
      ? await getApplicationDocumentsDirectory()
      : await getApplicationSupportDirectory();

  bootLogger.l('Initialize Hive');
  Hive.init(dbDirectory.path);

  bootLogger.l('Register bookmark adapter');
  Hive.registerAdapter(BookmarkHiveObjectAdapter());
  bootLogger.l('Register favorite tag adapter');
  Hive.registerAdapter(FavoriteTagHiveObjectAdapter());

  if (isDesktopPlatform() || isIOS()) {
    fvp.registerWith(
      options: {
        'platforms': [
          'linux',
          'ios',
          'windows',
          'macos',
        ],
      },
    );
  }

  bootLogger.l('Load app info');
  final appInfo = await getAppInfo();

  bootLogger.l('Load boorus from assets');
  final boorus = await loadBoorusFromAssets();

  bootLogger.l('Create booru factory');
  final booruFactory = BooruFactory.from(boorus);

  bootLogger.l('Initialize settings repository');
  final settingRepository = SettingsRepositoryLoggerInterceptor(
    SettingsRepositoryHive(
      Hive.openBox('settings'),
    ),
    logger: logger,
  );

  bootLogger.l('Set certificate to trusted certificates');
  try {
    // https://stackoverflow.com/questions/69511057/flutter-on-android-7-certificate-verify-failed-with-letsencrypt-ssl-cert-after-s
    // On Android 7 and below, the Let's Encrypt certificate is not trusted by default and needs to be added manually.
    final cert = await rootBundle.load('assets/ca/isrgrootx1.pem');

    SecurityContext.defaultContext
        .setTrustedCertificatesBytes(cert.buffer.asUint8List());
  } catch (e) {
    // ignore errors here, maybe it's already trusted
  }

  final booruUserRepo = await createBooruConfigsRepo(
    logger: bootLogger,
    booruFactory: booruFactory,
    onCreateNew: (id) async {
      final settings =
          await settingRepository.load().run().then((value) => value.fold(
                (l) => Settings.defaultSettings,
                (r) => r,
              ));

      bootLogger.l('Save default booru config');
      await settingRepository.save(settings.copyWith(currentBooruConfigId: id));
    },
  );

  bootLogger.l('Load settings');
  final settings =
      await settingRepository.load().run().then((value) => value.fold(
            (l) => Settings.defaultSettings,
            (r) => r,
          ));

  bootLogger.l('Settings: ${settings.toJson()}');

  // start
  bootLogger.l('Load current booru config');
  final initialConfig = await booruUserRepo.getCurrentBooruConfigFrom(settings);

  bootLogger.l('Load all configs');
  final allConfigs = await booruUserRepo.getAll();
  //end

  Box<String> userMetatagBox;
  bootLogger.l('Initialize user metatag box');
  if (await Hive.boxExists('user_metatags')) {
    bootLogger.l('Open user metatag box');
    userMetatagBox = await Hive.openBox<String>('user_metatags');
  } else {
    bootLogger.l('Create user metatag box');
    userMetatagBox = await Hive.openBox<String>('user_metatags');
    for (final e in [
      'age',
      'rating',
      'order',
      'score',
      'id',
      'user',
    ]) {
      await userMetatagBox.put(e, e);
    }
  }
  final userMetatagRepo = UserMetatagRepository(box: userMetatagBox);

  final searchHistoryRepoOverride = await createSearchHistoryRepoOverride(
    logger: bootLogger,
  );

  bootLogger.l('Initialize favorite tag repository');
  final favoriteTagsBox =
      await Hive.openBox<FavoriteTagHiveObject>('favorite_tags');
  final favoriteTagsRepo = FavoriteTagRepositoryHive(
    favoriteTagsBox,
  );

  bootLogger.l('Initialize global blacklisted tag repository');
  final globalBlacklistedTags = HiveBlacklistedTagRepository();
  await globalBlacklistedTags.init();

  bootLogger.l('Initialize bookmark repository');
  final bookmarkBox = await Hive.openBox<BookmarkHiveObject>('favorites');
  final bookmarkRepo = BookmarkHiveRepository(bookmarkBox);

  final tempPath = await getAppTemporaryDirectory();

  bootLogger.l('Initialize misc data box');
  final miscDataBox = await Hive.openBox<String>(
    'misc_data_v1',
    path: tempPath.path,
  );

  bootLogger.l('Initialize danbooru creator box');
  final danbooruCreatorBox = await Hive.openBox(
    '${Uri.encodeComponent(initialConfig?.url ?? 'danbooru')}_creators_v1',
    path: tempPath.path,
  );

  bootLogger.l('Initialize package info');
  final packageInfo = await PackageInfo.fromPlatform();

  bootLogger.l('Initialize tag info');
  final tagInfo =
      await TagInfoService.create().then((value) => value.getInfo());

  bootLogger.l('Initialize device info');
  final deviceInfo =
      await DeviceInfoService(plugin: DeviceInfoPlugin()).getDeviceInfo();

  bootLogger.l('Initialize i18n');
  await ensureI18nInitialized();

  bootLogger.l('Load supported languages');
  final supportedLanguages = await loadLanguageNames();

  bootLogger.l('Initialize tracking');
  final (firebaseAnalytics, crashlyticsReporter) =
      await initializeTracking(settings);

  bootLogger.l('Initialize error handlers');
  initializeErrorHandlers(
    settings.dataCollectingStatus == DataCollectingStatus.allow,
    crashlyticsReporter,
  );

  bootLogger.l('Initialize download notifications');
  final downloadNotifications = await DownloadNotifications.create();
  final bulkDownloadNotifications = await BulkDownloadNotifications.create();

  FlutterError.demangleStackTrace = (stack) {
    if (stack is Trace) return stack.vmTrace;
    if (stack is Chain) return stack.toTrace().vmTrace;
    return stack;
  };

  if (settings.clearImageCacheOnStartup) {
    logger.logI('Start up', 'Clearing image cache on startup');
    bootLogger.l('Clear image cache');
    await clearImageCache();
  }

  HttpOverrides.global = AppHttpOverrides();

  // Prepare for Android 15
  showSystemStatus();

  logger.logI('Start up',
      'Initialization done in ${stopwatch.elapsed.inMilliseconds}ms');
  stopwatch.stop();

  void run() {
    runApp(
      Reboot(
        initialConfigs: allConfigs,
        initialConfig: initialConfig ?? BooruConfig.empty,
        builder: (context, config, configs) => BooruLocalization(
          child: ProviderScope(
            overrides: [
              favoriteTagRepoProvider.overrideWithValue(favoriteTagsRepo),
              searchHistoryRepoOverride,
              booruFactoryProvider.overrideWithValue(booruFactory),
              tagInfoProvider.overrideWithValue(tagInfo),
              settingsRepoProvider.overrideWithValue(settingRepository),
              settingsNotifierProvider
                  .overrideWith(() => SettingsNotifier(settings)),
              booruConfigRepoProvider.overrideWithValue(booruUserRepo),
              booruConfigProvider.overrideWith(() => BooruConfigNotifier(
                    initialConfigs: configs,
                  )),
              initialSettingsBooruConfigProvider.overrideWithValue(config),
              globalBlacklistedTagRepoProvider
                  .overrideWithValue(globalBlacklistedTags),
              httpCacheDirProvider.overrideWithValue(tempPath),
              loggerProvider.overrideWithValue(logger),
              bookmarkRepoProvider.overrideWithValue(bookmarkRepo),
              downloadNotificationProvider
                  .overrideWithValue(downloadNotifications),
              bulkDownloadNotificationProvider
                  .overrideWithValue(bulkDownloadNotifications),
              deviceInfoProvider.overrideWithValue(deviceInfo),
              danbooruUserMetatagRepoProvider
                  .overrideWithValue(userMetatagRepo),
              packageInfoProvider.overrideWithValue(packageInfo),
              appInfoProvider.overrideWithValue(appInfo),
              appLoggerProvider.overrideWithValue(appLogger),
              supportedLanguagesProvider.overrideWithValue(supportedLanguages),
              danbooruCreatorHiveBoxProvider
                  .overrideWithValue(danbooruCreatorBox),
              miscDataBoxProvider.overrideWithValue(miscDataBox),
              booruTagTypePathProvider.overrideWithValue(dbDirectory.path),
              if (firebaseAnalytics != null)
                analyticsProvider.overrideWithValue(firebaseAnalytics),
              if (crashlyticsReporter != null)
                errorReporterProvider.overrideWithValue(crashlyticsReporter),
            ],
            child: const App(),
          ),
        ),
      ),
    );
  }

  bootLogger.l('Run app');
  run();
}
