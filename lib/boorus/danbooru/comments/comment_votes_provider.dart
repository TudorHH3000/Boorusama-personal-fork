// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/clients/danbooru/types/types.dart';
import 'package:boorusama/core/comments/comments.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/manage/manage.dart';
import 'comments.dart';

final danbooruCommentVoteRepoProvider = Provider.family<
    CommentVoteRepository<DanbooruCommentVote>, BooruConfigAuth>((ref, config) {
  final client = ref.watch(danbooruClientProvider(config));

  return CommentVoteRepositoryBuilder(
    fetch: (commentIds) => client
        .getCommentVotes(
          commentIds: commentIds,
          isDeleted: false,
        )
        .then((value) => value.map(commentVoteDtoToCommentVote).toList()),
    unvote: (commentId) =>
        client.removeCommentVote(commentId: commentId).then((_) => true),
    upvote: (commentId) => client
        .upvoteComment(commentId: commentId)
        .then(commentVoteDtoToCommentVote),
    downvote: (commentId) => client
        .downvoteComment(commentId: commentId)
        .then(commentVoteDtoToCommentVote),
  );
});

final danbooruCommentVotesProvider = NotifierProvider.family<
    CommentVotesNotifier, Map<CommentId, DanbooruCommentVote>, BooruConfigAuth>(
  CommentVotesNotifier.new,
  dependencies: [
    currentBooruConfigProvider,
  ],
);

// comment vote for a single comment
final danbooruCommentVoteProvider = Provider.autoDispose
    .family<DanbooruCommentVote?, CommentId>((ref, commentId) {
  final config = ref.watchConfigAuth;
  final votes = ref.watch(danbooruCommentVotesProvider(config));
  return votes[commentId];
});

DanbooruCommentVote commentVoteDtoToCommentVote(CommentVoteDto d) {
  return DanbooruCommentVote(
    id: d.id ?? 0,
    commentId: d.commentId ?? 0,
    userId: d.userId ?? 0,
    score: d.score ?? 0,
    createdAt: d.createdAt ?? DateTime.now(),
    updatedAt: d.updatedAt ?? DateTime.now(),
    isDeleted: d.isDeleted ?? false,
  );
}
