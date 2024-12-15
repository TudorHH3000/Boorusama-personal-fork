// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../foundation/animations.dart';
import '../../../../foundation/toast.dart';
import '../../../../theme.dart';

class FavoritePostButton extends StatelessWidget {
  const FavoritePostButton({
    super.key,
    required this.isFaved,
    required this.isAuthorized,
    required this.addFavorite,
    required this.removeFavorite,
  });

  final bool? isFaved;
  final bool isAuthorized;
  final Future<void> Function() addFavorite;
  final Future<void> Function() removeFavorite;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      splashRadius: 16,
      onPressed: isFaved != null
          ? () async {
              if (!isAuthorized) {
                showSimpleSnackBar(
                  context: context,
                  content: const Text(
                    'post.detail.login_required_notice',
                  ).tr(),
                  duration: AppDurations.shortToast,
                );

                return;
              }
              if (isFaved!) {
                removeFavorite();
              } else {
                addFavorite();
              }
            }
          : null,
      icon: isFaved == true
          ? Icon(
              Symbols.favorite,
              fill: 1,
              color: context.colors.upvoteColor,
              size: 20,
            )
          : const Icon(
              Symbols.favorite,
              size: 20,
            ),
    );
  }
}
