// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs.dart';
import 'package:boorusama/core/favorites/favorites.dart';
import 'package:boorusama/core/posts/details.dart';
import 'package:boorusama/core/posts/shares.dart';
import 'package:boorusama/core/posts/votes.dart';
import 'package:boorusama/router.dart';
import '../favorites/favorites.dart';
import '../szurubooru_post.dart';
import 'post_votes.dart';

class SzurubooruPostActionToolbar extends ConsumerWidget {
  const SzurubooruPostActionToolbar({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<SzurubooruPost>(context);

    final config = ref.watchConfigAuth;
    final isFaved = ref.watch(szurubooruFavoriteProvider(post.id));
    final postVote = ref.watch(szurubooruPostVoteProvider(post.id));
    final voteState = postVote?.voteState ?? VoteState.unvote;

    final favNotifier = ref.watch(szurubooruFavoritesProvider(config).notifier);
    final voteNotifier =
        ref.watch(szurubooruPostVotesProvider(config).notifier);

    return SliverToBoxAdapter(
      child: PostActionToolbar(
        children: [
          if (config.hasLoginDetails())
            FavoritePostButton(
              isFaved: isFaved,
              isAuthorized: config.hasLoginDetails(),
              addFavorite: () => favNotifier.add(post.id),
              removeFavorite: () => favNotifier.remove(post.id),
            ),
          if (config.hasLoginDetails())
            UpvotePostButton(
              voteState: voteState,
              onUpvote: () => voteNotifier.upvote(post.id),
              onRemoveUpvote: () => voteNotifier.removeVote(post.id),
            ),
          if (config.hasLoginDetails())
            DownvotePostButton(
              voteState: voteState,
              onDownvote: () => voteNotifier.downvote(post.id),
              onRemoveDownvote: () => voteNotifier.removeVote(post.id),
            ),
          BookmarkPostButton(post: post),
          CommentPostButton(
            onPressed: () => goToCommentPage(context, ref, post.id),
          ),
          DownloadPostButton(post: post),
          SharePostButton(post: post),
        ],
      ),
    );
  }
}
