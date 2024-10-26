// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/comments/comments.dart';
import 'package:boorusama/core/comments/comments.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/widgets/widgets.dart';

class CommentList extends StatelessWidget {
  const CommentList({
    super.key,
    required this.comments,
    required this.authenticated,
    required this.onEdit,
    required this.onReply,
    required this.onDelete,
    required this.onUpvote,
    required this.onDownvote,
    required this.onClearVote,
  });

  final List<CommentData> comments;
  final bool authenticated;
  final void Function(CommentData comment) onReply;
  final void Function(CommentData comment) onEdit;
  final void Function(CommentData comment) onDelete;
  final void Function(CommentData comment) onUpvote;
  final void Function(CommentData comment) onDownvote;
  final void Function(CommentData comment, DanbooruCommentVote? commentVote)
      onClearVote;

  @override
  Widget build(BuildContext context) {
    return comments.isNotEmpty
        ? ListView.builder(
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              final comment = comments[index];

              return ListTile(
                title: CommentItem(
                  hasVoteSection: true,
                  onVoteChanged: (event, commentVote) => switch (event) {
                    VoteEvent.upvoted => onUpvote(comment),
                    VoteEvent.downvote => onDownvote(comment),
                    VoteEvent.voteRemoved => onClearVote(comment, commentVote),
                  },
                  comment: comment,
                  onReply: authenticated ? () => onReply(comment) : null,
                  moreBuilder: (context) => authenticated
                      ? BooruPopupMenuButton(
                          onSelected: (value) {
                            if (value == 'edit') {
                              onEdit(comment);
                            } else if (value == 'reply') {
                              onReply(comment);
                            } else if (value == 'delete') {
                              onDelete(comment);
                            }
                          },
                          itemBuilder: {
                            if (comment.isSelf)
                              'edit': const Text('comment.list.edit').tr(),
                            'reply': const Text('comment.list.reply').tr(),
                            if (comment.isSelf)
                              'delete': const Text('comment.list.delete').tr(),
                          },
                        )
                      : const SizedBox.shrink(),
                ),
              );
            },
            itemCount: comments.length,
          )
        : Center(child: Text('comment.list.noComments'.tr()));
  }
}
