// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../info/device_info.dart';
import '../loggers.dart';
import 'device_storage_permission_notifier.dart';

final deviceStoragePermissionProvider = AsyncNotifierProvider<
    DeviceStoragePermissionNotifier, DeviceStoragePermissionState>(
  DeviceStoragePermissionNotifier.new,
  dependencies: [
    deviceInfoProvider,
    loggerProvider,
  ],
);
