// Package imports:
import 'package:collection/collection.dart';

// Project imports:
import 'booru.dart';

class BooruFactory {
  const BooruFactory._({
    required this.boorus,
  });

  factory BooruFactory.from(
    List<Booru> boorus,
  ) {
    return BooruFactory._(
      boorus: boorus,
    );
  }

  final List<Booru> boorus;

  Booru? getBooruFromUrl(String url) {
    for (final booru in boorus) {
      if (booru.hasSite(url)) {
        return booru;
      }
    }

    return null;
  }

  Booru? getBooruFromId(int id) => boorus.firstWhereOrNull((e) => e.id == id);

  Booru? create({
    required BooruType type,
  }) {
    final id = switch (type) {
      BooruType.danbooru => kDanbooruId,
      BooruType.gelbooru => kGelbooruId,
      BooruType.gelbooruV2 => kGelbooruV2Id,
      BooruType.moebooru => kMoebooruId,
      BooruType.e621 => kE621Id,
      BooruType.zerochan => kZerochanId,
      BooruType.gelbooruV1 => kGelbooruV1Id,
      BooruType.sankaku => kSankaku,
      BooruType.philomena => kPhilomenaId,
      BooruType.shimmie2 => kShimmie2Id,
      BooruType.szurubooru => kSzurubooruId,
      BooruType.hydrus => kHydrusId,
      BooruType.animePictures => kAnimePicturesId,
      BooruType.unknown => 0,
    };

    return getBooruFromId(id);
  }
}
