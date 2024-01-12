// Package imports:
import 'package:collection/collection.dart';
import 'package:hive/hive.dart';

// Project imports:
import 'package:boorusama/core/feats/blacklists/blacklists.dart';

class HiveBlacklistedTagRepository implements GlobalBlacklistedTagRepository {
  static const _boxName = 'blacklisted_tags';

  late Box<BlacklistedTagHiveObject> _box;

  Future<void> init() async {
    Hive.registerAdapter(BlacklistedTagHiveObjectAdapter());
    _box = await Hive.openBox<BlacklistedTagHiveObject>(_boxName);
  }

  @override
  Future<BlacklistedTag?> addTag(String tag) async {
    final existingTag = _box.values.firstWhereOrNull((e) => e.name == tag);

    if (existingTag != null) return null;

    final createdDate = DateTime.now();
    final obj = BlacklistedTagHiveObject(
      name: tag,
      isActive: true,
      createdDate: createdDate,
      updatedDate: createdDate,
    );
    final index = await _box.add(obj);
    return convertFromHiveObject(obj).copyWith(id: index);
  }

  @override
  Future<void> removeTag(int tagId) async {
    await _box.delete(tagId);
  }

  @override
  Future<List<BlacklistedTag>> getBlacklist() async {
    return _box.values.map(convertFromHiveObject).toList();
  }

  @override
  Future<BlacklistedTag> updateTag(int tagId, String newTag) async {
    final obj = _box.get(tagId)!;
    final updatedDate = DateTime.now();

    obj.name = newTag;
    obj.updatedDate = updatedDate;

    await _box.put(tagId, obj);
    return convertFromHiveObject(obj);
  }
}

BlacklistedTagHiveObject convertToHiveObject(BlacklistedTag blacklistedTag) {
  return BlacklistedTagHiveObject(
    name: blacklistedTag.name,
    isActive: blacklistedTag.isActive,
    createdDate: blacklistedTag.createdDate,
    updatedDate: blacklistedTag.updatedDate,
  );
}

BlacklistedTag convertFromHiveObject(BlacklistedTagHiveObject hiveObject) {
  return BlacklistedTag(
    id: hiveObject.key,
    name: hiveObject.name,
    isActive: hiveObject.isActive,
    createdDate: hiveObject.createdDate,
    updatedDate: hiveObject.updatedDate,
  );
}
