// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/users/users.dart';
import 'package:boorusama/core/blacklists/blacklists.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/toast.dart';

class BlacklistedTagsNotifier
    extends FamilyAsyncNotifier<List<String>?, BooruConfig> {
  @override
  Future<List<String>?> build(BooruConfig arg) async {
    final user = await ref.watch(danbooruCurrentUserProvider(arg).future);

    if (user == null) return null;

    return user.blacklistedTags.toList();
  }

  Future<void> add({
    required Set<String> tagSet,
    void Function(List<String> tags)? onSuccess,
    void Function(Object e)? onFailure,
  }) async {
    final user = await ref.read(danbooruCurrentUserProvider(arg).future);
    final currentTags = state.value;

    if (currentTags == null || user == null) {
      onFailure?.call('Not logged in or no blacklisted tags found');

      return;
    }

    // Duplicate tags are not allowed
    final tags = [...currentTags, ...tagSet];

    try {
      await ref.read(danbooruClientProvider(arg)).setBlacklistedTags(
            id: user.id,
            blacklistedTags: tags,
          );

      onSuccess?.call(tags);

      state = AsyncValue.data(tags);
    } catch (e) {
      onFailure?.call(e);
    }
  }

  // remove a tag
  Future<void> remove({
    required String tag,
    void Function(List<String> tags)? onSuccess,
    void Function()? onFailure,
  }) async {
    final user = await ref.read(danbooruCurrentUserProvider(arg).future);
    final currentTags = state.value;

    if (currentTags == null || user == null) {
      onFailure?.call();

      return;
    }

    final tags = [...currentTags]..remove(tag);

    try {
      await ref
          .read(danbooruClientProvider(arg))
          .setBlacklistedTags(id: user.id, blacklistedTags: tags);

      onSuccess?.call(tags);

      state = AsyncValue.data(tags);
    } catch (e) {
      onFailure?.call();
    }
  }

  // replace a tag
  Future<void> replace({
    required String oldTag,
    required String newTag,
    void Function(List<String> tags)? onSuccess,
    void Function(String message)? onFailure,
  }) async {
    final user = await ref.read(danbooruCurrentUserProvider(arg).future);
    final currentTags = state.value;

    if (currentTags == null || user == null) {
      onFailure?.call('Fail to replace tag');

      return;
    }

    final tags = [
      ...[...currentTags]..remove(oldTag),
      newTag,
    ];

    try {
      await ref
          .read(danbooruClientProvider(arg))
          .setBlacklistedTags(id: user.id, blacklistedTags: tags);

      onSuccess?.call(tags);

      state = AsyncValue.data(tags);
    } catch (e) {
      onFailure?.call('Fail to replace tag');
    }
  }
}

extension BlacklistedTagsNotifierX on BlacklistedTagsNotifier {
  Future<void> addFromStringWithToast({
    required BuildContext context,
    required String tagString,
  }) async {
    final tags = sanitizeBlacklistTagString(tagString);

    if (tags == null) {
      showErrorToast(
        context,
        'Invalid tag format',
      );
      return;
    }

    await add(
      tagSet: tags.toSet(),
      onSuccess: (tags) =>
          showSuccessToast(context, 'blacklisted_tags.updated'.tr()),
      onFailure: (e) => showErrorToast(
        context,
        '${'blacklisted_tags.failed_to_add'.tr()}\n$e',
      ),
    );
  }

  Future<void> addWithToast({
    required BuildContext context,
    required String tag,
  }) =>
      add(
        tagSet: {tag},
        onSuccess: (tags) => showSuccessToast(
          context,
          'blacklisted_tags.updated'.tr(),
        ),
        onFailure: (e) => showErrorToast(
          context,
          '${'blacklisted_tags.failed_to_add'.tr()}\n$e',
        ),
      );

  Future<void> removeWithToast({
    required BuildContext context,
    required String tag,
  }) =>
      remove(
        tag: tag,
        onSuccess: (tags) => showSuccessToast(
          context,
          'blacklisted_tags.updated'.tr(),
        ),
        onFailure: () => showErrorToast(
          context,
          'blacklisted_tags.failed_to_remove'.tr(),
        ),
      );
}
