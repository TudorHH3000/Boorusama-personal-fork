// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/e621/e621.dart';
import 'package:boorusama/boorus/e621/tags/e621_tag_repository.dart';
import 'package:boorusama/core/configs/config.dart';

final e621TagRepoProvider =
    Provider.family<E621TagRepository, BooruConfigAuth>((ref, config) {
  return E621TagRepositoryApi(
    ref.watch(e621ClientProvider(config)),
    config,
  );
});
