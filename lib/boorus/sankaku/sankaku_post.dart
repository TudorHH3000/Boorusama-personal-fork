// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/foundation/image.dart';
import 'package:boorusama/foundation/video.dart';

class SankakuPost extends Equatable
    with
        MediaInfoMixin,
        TranslatedMixin,
        ImageInfoMixin,
        VideoInfoMixin,
        TagListCheckMixin
    implements Post {
  SankakuPost({
    required this.id,
    this.createdAt,
    required this.thumbnailImageUrl,
    required this.sampleImageUrl,
    required this.originalImageUrl,
    required this.tags,
    required this.rating,
    required this.hasComment,
    required this.isTranslated,
    required this.hasParentOrChildren,
    this.parentId,
    required this.source,
    required this.score,
    this.downvotes,
    required this.duration,
    required this.fileSize,
    required this.format,
    required this.hasSound,
    required this.height,
    required this.md5,
    required this.videoThumbnailUrl,
    required this.videoUrl,
    required this.width,
    required Function(String baseUrl) getLink,
    required this.artistDetailsTags,
    required this.characterDetailsTags,
    required this.copyrightDetailsTags,
    required this.uploaderId,
  })  : _getLink = getLink,
        artistTags = artistDetailsTags.map((e) => e.name).toList(),
        characterTags = characterDetailsTags.map((e) => e.name).toList(),
        copyrightTags = copyrightDetailsTags.map((e) => e.name).toList();

  @override
  final int id;
  @override
  final DateTime? createdAt;
  @override
  final String thumbnailImageUrl;
  @override
  final String sampleImageUrl;
  @override
  final String originalImageUrl;
  @override
  final List<String> tags;
  @override
  final Rating rating;
  @override
  final bool hasComment;
  @override
  final bool isTranslated;
  @override
  final bool hasParentOrChildren;
  @override
  final int? parentId;
  @override
  final PostSource source;
  @override
  final int score;
  @override
  final int? downvotes;
  @override
  final double duration;
  @override
  final int fileSize;
  @override
  final String format;
  @override
  final bool? hasSound;
  @override
  final double height;
  @override
  final String md5;
  @override
  final String videoThumbnailUrl;
  @override
  final String videoUrl;
  @override
  final double width;

  final Function(String baseUrl) _getLink;

  get posts => null;

  @override
  String getLink(String baseUrl) => _getLink(baseUrl);

  @override
  Uri getUriLink(String baseUrl) => Uri.parse(getLink(baseUrl));

  @override
  List<Object?> get props => [id];

  @override
  final List<String> artistTags;

  @override
  final List<String> characterTags;

  @override
  final List<String> copyrightTags;

  final List<Tag> artistDetailsTags;

  final List<Tag> characterDetailsTags;

  final List<Tag> copyrightDetailsTags;

  @override
  final int? uploaderId;
}
