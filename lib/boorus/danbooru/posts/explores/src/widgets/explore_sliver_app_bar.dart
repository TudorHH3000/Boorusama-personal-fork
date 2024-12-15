// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:

class ExploreSliverAppBar extends StatelessWidget {
  const ExploreSliverAppBar({
    super.key,
    required this.title,
    required this.onBack,
  });

  final String title;
  final void Function()? onBack;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
      floating: true,
      leading: onBack != null
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBack,
            )
          : null,
      backgroundColor: Theme.of(context).colorScheme.surface,
    );
  }
}
