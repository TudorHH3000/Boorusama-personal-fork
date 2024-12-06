// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs.dart';
import 'package:boorusama/functional.dart';
import 'users.dart';

class CreatorsNotifier
    extends FamilyNotifier<IMap<int, Creator>, BooruConfigAuth> {
  CreatorRepository get repo => ref.watch(danbooruCreatorRepoProvider(arg));

  @override
  IMap<int, Creator> build(BooruConfigAuth arg) {
    return <int, Creator>{}.lock;
  }

  Future<void> load(List<int> ids) async {
    // only load ids that are not already loaded
    final notInCached = ids.where((id) => !state.containsKey(id)).toList();

    final creators =
        await repo.getCreatorsByIdStringComma(notInCached.join(','));

    final map = {
      for (final creator in creators) creator.id: creator,
    }.lock;

    state = state.addAll(map);
  }
}
