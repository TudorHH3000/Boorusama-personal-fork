// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/wikis/wikis.dart';
import 'package:boorusama/core/configs/configs.dart';

class WikisNotifier
    extends FamilyNotifier<Map<String, Wiki?>, BooruConfigAuth> {
  @override
  Map<String, Wiki?> build(BooruConfigAuth arg) {
    return {};
  }

  Future<void> fetchWikiFor(String tag) async {
    if (state.containsKey(tag)) return;

    final wiki = await ref.read(danbooruWikiRepoProvider(arg)).getWikiFor(tag);
    if (wiki != null) {
      state = {
        ...state,
        tag: wiki,
      };
    }
  }
}
