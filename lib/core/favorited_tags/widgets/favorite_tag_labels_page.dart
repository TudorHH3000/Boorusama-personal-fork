// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../favorited_tags.dart';

class FavoriteTagLabelsPage extends ConsumerWidget {
  const FavoriteTagLabelsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(favoriteTagsProvider);
    final labels = ref.watch(favoriteTagLabelsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Labels'),
      ),
      body: labels.isNotEmpty
          ? ListView.builder(
              itemCount: labels.length,
              itemBuilder: (context, index) {
                final label = labels[index];
                final count = tags
                    .where((e) => e.labels?.contains(label) ?? false)
                    .length;
                return ListTile(
                  title: Text(label),
                  subtitle: Text('$count tags'),
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => FavoriteTagLabelDetailsPage(
                          label: label,
                        ),
                      ),
                    );
                  },
                );
              },
            )
          : const Center(
              child: Text('No labels'),
            ),
    );
  }
}
