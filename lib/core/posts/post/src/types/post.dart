// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../rating/rating.dart';
import '../../../sources/source.dart';
import '../mixins/image_info_mixin.dart';
import '../mixins/media_info_mixin.dart';
import '../mixins/video_info_mixin.dart';

class PostMetadata extends Equatable {
  const PostMetadata({
    this.page,
    this.search,
  });
  final int? page;
  final String? search;

  @override
  List<Object?> get props => [page, search];
}

abstract class Post
    with MediaInfoMixin, ImageInfoMixin, VideoInfoMixin
    implements TagDetails {
  int get id;
  DateTime? get createdAt;
  String get thumbnailImageUrl;
  String get sampleImageUrl;
  String get originalImageUrl;
  Set<String> get tags;
  Rating get rating;
  bool get hasComment;
  bool get isTranslated;
  bool get hasParentOrChildren;
  int? get parentId;
  PostSource get source;
  int get score;
  int? get downvotes;
  int? get uploaderId;

  PostMetadata? get metadata;

  String getLink(String baseUrl);
  Uri getUriLink(String baseUrl);
}

abstract interface class TagDetails {
  Set<String>? get artistTags;
  Set<String>? get characterTags;
  Set<String>? get copyrightTags;
}

extension PostImageX on Post {
  bool get hasFullView => originalImageUrl.isNotEmpty && !isVideo;

  bool get hasNoImage =>
      thumbnailImageUrl.isEmpty &&
      sampleImageUrl.isEmpty &&
      originalImageUrl.isEmpty;

  bool get hasParent => parentId != null && parentId! > 0;
}

extension PostX on Post {
  String get relationshipQuery => hasParent ? 'parent:$parentId' : 'parent:$id';
}
