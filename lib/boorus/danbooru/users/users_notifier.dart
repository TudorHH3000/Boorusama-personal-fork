// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/users/users.dart';
import 'package:boorusama/core/configs/providers.dart';

class UserNotifier extends AutoDisposeFamilyAsyncNotifier<DanbooruUser, int> {
  @override
  Future<DanbooruUser> build(int arg) async {
    final config = ref.watchConfigAuth;
    final user =
        await ref.watch(danbooruUserRepoProvider(config)).getUserById(arg);
    return user;
  }
}
