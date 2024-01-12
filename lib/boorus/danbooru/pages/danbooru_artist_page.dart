// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/artists/artists.dart';
import 'package:boorusama/boorus/danbooru/pages/widgets/danbooru_artist_url_chips.dart';
import 'package:boorusama/boorus/danbooru/pages/widgets/danbooru_tag_details_page.dart';
import 'package:boorusama/core/widgets/widgets.dart';

class DanbooruArtistPage extends ConsumerStatefulWidget {
  const DanbooruArtistPage({
    super.key,
    required this.artistName,
    required this.backgroundImageUrl,
  });

  final String artistName;
  final String backgroundImageUrl;

  @override
  ConsumerState<DanbooruArtistPage> createState() => _DanbooruArtistPageState();
}

class _DanbooruArtistPageState extends ConsumerState<DanbooruArtistPage> {
  @override
  Widget build(BuildContext context) {
    final artist = ref.watch(danbooruArtistProvider(widget.artistName));

    return CustomContextMenuOverlay(
      child: DanbooruTagDetailsPage(
        tagName: widget.artistName,
        otherNamesBuilder: (_) => artist.when(
          data: (data) => data.otherNames.isNotEmpty
              ? TagOtherNames(otherNames: data.otherNames)
              : const SizedBox.shrink(),
          error: (error, stackTrace) => const SizedBox(height: 40, width: 40),
          loading: () => const TagOtherNames(otherNames: null),
        ),
        extraBuilder: (context) => [
          const SizedBox(height: 8),
          artist.when(
            data: (artist) => DanbooruArtistUrlChips(artist: artist),
            loading: () => const SizedBox(height: 24),
            error: (e, st) => const SizedBox.shrink(),
          ),
        ],
        backgroundImageUrl: widget.backgroundImageUrl,
      ),
    );
  }
}
