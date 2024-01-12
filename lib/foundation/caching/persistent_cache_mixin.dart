// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import 'package:boorusama/foundation/path.dart';

mixin PersistentCacheMixin {
  Box<String>? _box;

  String get persistentStorageKey;

  Duration get persistentStaleDuration;

  bool _isStale(DateTime timestamp, Duration staleDuration) =>
      DateTime.now().difference(timestamp) > staleDuration;

  Future<Box<String>?> openBox() async {
    if (_box != null) return _box!;
    final dir = await getTemporaryDirectory();

    _box = await Hive.openBox(persistentStorageKey, path: dir.path);

    return _box;
  }

  Future<String?> load(String key) async {
    final box = await openBox();
    if (box == null) return null;

    var cachedValue = box.get(key);

    if (cachedValue == null) return null;

    // Use Hive timestamps to store the last access time
    var timestamp = box.get('${key}_timestamp');

    if (timestamp == null) {
      box.delete(key);
      return null;
    }

    final parsedTimestamp = DateTime.tryParse(timestamp);

    if (parsedTimestamp == null) {
      box.delete(key);
      return null;
    }

    if (_isStale(parsedTimestamp, persistentStaleDuration)) {
      box.delete(key);
      box.delete('${key}_timestamp');
      return null;
    }

    return cachedValue;
  }

  Future<void> save(String key, String value) async {
    final box = await openBox();

    if (box == null) return;

    box.put(key, value);
    box.put('${key}_timestamp', DateTime.now().toIso8601String());
  }

  Future<void> flush() async {
    final box = await openBox();

    if (box == null) return;

    box.clear();
  }
}

class PersistentCache with PersistentCacheMixin {
  PersistentCache({
    required this.persistentStorageKey,
    required this.persistentStaleDuration,
  });

  @override
  final String persistentStorageKey;

  @override
  final Duration persistentStaleDuration;
}
