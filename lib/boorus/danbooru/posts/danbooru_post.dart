// Package imports:
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/foundation/image.dart';
import 'package:boorusama/foundation/video.dart';
import 'package:boorusama/functional.dart';
import 'post_variant.dart';

typedef DanbooruPostsOrError = PostsOrErrorCore<DanbooruPost>;

class DanbooruPost extends Equatable
    with
        MediaInfoMixin,
        TranslatedMixin,
        ImageInfoMixin,
        VideoInfoMixin,
        TagListCheckMixin
    implements Post, DanbooruTagDetails {
  DanbooruPost({
    required this.id,
    required this.thumbnailImageUrl,
    required this.sampleImageUrl,
    required this.originalImageUrl,
    required this.tags,
    required this.copyrightTags,
    required this.characterTags,
    required this.artistTags,
    required this.generalTags,
    required this.metaTags,
    required this.width,
    required this.height,
    required this.format,
    required this.md5,
    required this.lastCommentAt,
    required this.source,
    required this.createdAt,
    required this.score,
    required this.upScore,
    required this.downScore,
    required this.favCount,
    required this.uploaderId,
    required this.approverId,
    required this.rating,
    required this.fileSize,
    required this.isBanned,
    required this.hasChildren,
    required this.parentId,
    required this.hasLarge,
    required this.duration,
    required this.variants,
    required this.pixelHash,
    required this.metadata,
  });

  factory DanbooruPost.empty() => DanbooruPost(
        id: 0,
        thumbnailImageUrl: '',
        sampleImageUrl: '',
        originalImageUrl: '',
        tags: const {},
        copyrightTags: const {},
        characterTags: const {},
        artistTags: const {},
        generalTags: const {},
        metaTags: const {},
        width: 1,
        height: 1,
        format: 'png',
        md5: '',
        lastCommentAt: null,
        source: PostSource.none(),
        createdAt: DateTime.now(),
        score: 0,
        upScore: 0,
        downScore: 0,
        favCount: 0,
        uploaderId: 0,
        approverId: 0,
        rating: Rating.explicit,
        fileSize: 0,
        isBanned: false,
        hasChildren: false,
        hasLarge: false,
        parentId: null,
        duration: 0,
        variants: const [],
        pixelHash: '',
        metadata: null,
      );

  @override
  final int id;
  @override
  final String thumbnailImageUrl;
  @override
  final String sampleImageUrl;
  @override
  final String originalImageUrl;
  @override
  final Set<String> copyrightTags;
  @override
  final Set<String> characterTags;
  @override
  final Set<String> artistTags;
  @override
  final Set<String> generalTags;
  @override
  final Set<String> metaTags;
  @override
  final Set<String> tags;
  @override
  final double width;
  @override
  final double height;
  @override
  final String format;
  @override
  final String md5;
  final DateTime? lastCommentAt;
  @override
  final DateTime createdAt;
  @override
  final int score;
  final int upScore;
  final int downScore;
  final int favCount;
  @override
  final int uploaderId;
  final int? approverId;
  @override
  final Rating rating;
  @override
  final int fileSize;
  final bool isBanned;
  final bool hasChildren;
  @override
  final int? parentId;
  final bool hasLarge;
  @override
  final double duration;
  final List<PostVariant> variants;

  @override
  bool get hasComment => lastCommentAt != null;

  bool get hasParent => parentId != null;
  bool get hasBothParentAndChildren => hasChildren && hasParent;
  @override
  bool get hasParentOrChildren => hasChildren || hasParent;

  double get upvotePercent => totalVote > 0 ? upScore / totalVote : 1;
  int get totalVote => upScore + -downScore;
  bool get hasVoter => upScore != 0 || downScore != 0;
  bool get hasFavorite => favCount > 0;

  @override
  int? get downvotes => -downScore;

  @override
  bool? get hasSound => metaTags.contains('sound') ? true : null;
  @override
  String get videoUrl => sampleImageUrl;
  @override
  String get videoThumbnailUrl => url720x720;

  @override
  final PostSource source;

  final String pixelHash;

  bool get viewable => [
        thumbnailImageUrl,
        sampleImageUrl,
        originalImageUrl,
        md5,
      ].every((e) => e != '');

  @override
  String getLink(String baseUrl) =>
      baseUrl.endsWith('/') ? '${baseUrl}posts/$id' : '$baseUrl/posts/$id';

  @override
  Uri getUriLink(String baseUrl) => Uri.parse(getLink(baseUrl));

  @override
  final PostMetadata? metadata;

  @override
  List<Object?> get props => [
        id,
        tags,
        generalTags,
        artistTags,
        characterTags,
        copyrightTags,
        metaTags,
        rating,
      ];
}

const kCensoredTags = ['loli', 'shota'];

extension PostX on DanbooruPost {
  String get url180x180 =>
      variants.firstWhereOrNull((e) => e.is180x180)?.url ?? thumbnailImageUrl;

  String get url360x360 =>
      variants.firstWhereOrNull((e) => e.is360x360)?.url ?? thumbnailImageUrl;

  String get url720x720 =>
      variants.firstWhereOrNull((e) => e.is720x720)?.url ?? thumbnailImageUrl;

  String get urlSample =>
      variants.firstWhereOrNull((e) => e.isSample)?.url ?? sampleImageUrl;

  String get urlOriginal =>
      variants.firstWhereOrNull((e) => e.isOriginal)?.url ?? originalImageUrl;

  bool get hasCensoredTags {
    final tagSet = tags.toSet();

    return kCensoredTags.any(tagSet.contains);
  }

  List<Tag> extractTags() {
    final tags = <Tag>[];

    for (final t in artistTags) {
      tags.add(Tag.noCount(
        name: t,
        category: TagCategory.artist(),
      ));
    }

    for (final t in copyrightTags) {
      tags.add(Tag.noCount(
        name: t,
        category: TagCategory.copyright(),
      ));
    }

    for (final t in characterTags) {
      tags.add(Tag.noCount(
        name: t,
        category: TagCategory.character(),
      ));
    }

    for (final t in metaTags) {
      tags.add(Tag.noCount(
        name: t,
        category: TagCategory.meta(),
      ));
    }

    for (final t in generalTags) {
      tags.add(Tag.noCount(
        name: t,
        category: TagCategory.general(),
      ));
    }

    return tags;
  }

  DanbooruPost copyWith({
    int? id,
    Set<String>? tags,
    Set<String>? copyrightTags,
    Set<String>? characterTags,
    Set<String>? artistTags,
    Set<String>? generalTags,
    Set<String>? metaTags,
    String? format,
    String? md5,
    DateTime? lastCommentAt,
    String? sampleImageUrl,
    String? originalImageUrl,
    int? upScore,
    int? downScore,
    int? score,
    int? favCount,
    bool? hasChildren,
    PostSource? source,
    int? parentId,
    Rating? rating,
    int? fileSize,
    double? width,
    double? height,
  }) =>
      DanbooruPost(
        id: id ?? this.id,
        thumbnailImageUrl: thumbnailImageUrl,
        sampleImageUrl: sampleImageUrl ?? this.sampleImageUrl,
        originalImageUrl: originalImageUrl ?? this.originalImageUrl,
        tags: tags ?? this.tags,
        copyrightTags: copyrightTags ?? this.copyrightTags,
        characterTags: characterTags ?? this.characterTags,
        artistTags: artistTags ?? this.artistTags,
        generalTags: generalTags ?? this.generalTags,
        metaTags: metaTags ?? this.metaTags,
        width: width ?? this.width,
        height: height ?? this.height,
        format: format ?? this.format,
        md5: md5 ?? this.md5,
        lastCommentAt: lastCommentAt ?? this.lastCommentAt,
        source: source ?? this.source,
        createdAt: createdAt,
        score: score ?? this.score,
        upScore: upScore ?? this.upScore,
        downScore: downScore ?? this.downScore,
        favCount: favCount ?? this.favCount,
        uploaderId: uploaderId,
        approverId: approverId,
        rating: rating ?? this.rating,
        fileSize: fileSize ?? this.fileSize,
        isBanned: isBanned,
        hasChildren: hasChildren ?? this.hasChildren,
        hasLarge: hasLarge,
        parentId: parentId ?? this.parentId,
        duration: duration,
        variants: variants,
        pixelHash: pixelHash,
        metadata: metadata,
      );
}

extension DanbooruPostImageX on DanbooruPost {
  String _thumbnailFromImageQuality(ImageQuality quality) => switch (quality) {
        ImageQuality.low => url360x360,
        ImageQuality.high => url720x720,
        ImageQuality.highest => isVideo ? url720x720 : urlSample,
        ImageQuality.original => urlOriginal,
        ImageQuality.automatic => url720x720
      };

  String thumbnailFromImageQuality(ImageQuality quality) {
    if (isGif) return urlSample;
    return _thumbnailFromImageQuality(quality);
  }
}

abstract interface class DanbooruTagDetails implements TagDetails {
  Set<String>? get generalTags;
  Set<String>? get metaTags;
  Rating get rating;
}

extension DanbooruTagDetailsX on DanbooruTagDetails {
  Set<String> get allTags => {
        ...artistTags ?? {},
        ...characterTags ?? {},
        ...copyrightTags ?? {},
        ...generalTags ?? {},
        ...metaTags ?? {},
      };
}

extension DanbooruIdsX on List<DanbooruPost> {
  List<int> extractEmbeddedUserIds() => map((e) => [
        e.uploaderId,
        if (e.approverId != null) e.approverId!,
      ]).expand((e) => e).toSet().toList();
}

mixin DanbooruPostRepositoryMixin {
  PostRepository<DanbooruPost> get postRepository;

  Future<PostResult<DanbooruPost>> getPostsOrEmpty(String tags, int page) =>
      postRepository.getPosts(tags, page).run().then((value) => value.fold(
            (l) => <DanbooruPost>[].toResult(),
            (r) => r,
          ));
}

extension DanbooruRepoX on PostRepository<DanbooruPost> {
  PostsOrError<DanbooruPost> getPostsFromIds(List<int> ids) => getPosts(
        'id:${ids.join(',')}',
        1,
        limit: ids.length,
      );
}

Option<String> tagFilterCategoryToString(TagFilterCategory category) =>
    category == TagFilterCategory.popular ? const Some('order:score') : none();
