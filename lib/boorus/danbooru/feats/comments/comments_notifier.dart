// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/comments/comments.dart';
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/comments/comments.dart';

const youtubeUrl = 'www.youtube.com';

class CommentsNotifier
    extends FamilyNotifier<Map<int, List<CommentData>?>, BooruConfig> {
  @override
  Map<int, List<CommentData>?> build(BooruConfig arg) {
    return {};
  }

  CommentRepository<DanbooruComment> get repo =>
      ref.read(danbooruCommentRepoProvider(arg));

  Future<void> load(
    int postId, {
    bool force = false,
  }) async {
    if (state.containsKey(postId) && !force) return;

    final user = await ref.read(danbooruCurrentUserProvider(arg).future);

    final comments = await repo
        .getComments(postId)
        .then(filterDeleted())
        .then((comments) => comments
            .map((comment) => CommentData(
                  id: comment.id,
                  score: comment.score,
                  authorName: comment.creator?.name ?? 'User',
                  authorLevel: comment.creator?.level ?? UserLevel.member,
                  authorId: comment.creator?.id ?? 0,
                  body: comment.body,
                  createdAt: comment.createdAt,
                  updatedAt: comment.updatedAt,
                  isSelf: comment.creator?.id == user?.id,
                  isEdited: comment.isEdited,
                  uris: RegExp(urlPattern)
                      .allMatches(comment.body)
                      .map((match) => Uri.tryParse(
                          comment.body.substring(match.start, match.end)))
                      .whereNotNull()
                      .where((e) => e.host.contains(youtubeUrl))
                      .toList(),
                ))
            .toList())
        .then(_sortDescById);

    state = {
      ...state,
      postId: comments,
    };

    // fetch comment votes
    ref
        .read(danbooruCommentVotesProvider(arg).notifier)
        .fetch(comments.map((e) => e.id).toList());
  }

  Future<void> send({
    required int postId,
    required String content,
    CommentData? replyTo,
  }) async {
    await repo.createComment(
      postId,
      buildCommentContent(content: content, replyTo: replyTo),
    );
    await load(postId, force: true);
  }

  Future<void> delete({
    required int postId,
    required CommentData comment,
  }) async {
    await repo.deleteComment(comment.id);
    await load(postId, force: true);
  }

  Future<void> update({
    required int postId,
    required CommentId commentId,
    required String content,
  }) async {
    await repo.updateComment(commentId, content);
    await load(postId, force: true);
  }
}

List<CommentData> _sortDescById(List<CommentData> comments) =>
    comments..sort((b, a) => b.id.compareTo(a.id));

String buildCommentContent({
  required String content,
  CommentData? replyTo,
}) {
  var c = content;
  if (replyTo != null) {
    c = '[quote]\n${replyTo.authorName} said:\n\n${replyTo.body}\n[/quote]\n\n$content';
  }

  return c;
}
