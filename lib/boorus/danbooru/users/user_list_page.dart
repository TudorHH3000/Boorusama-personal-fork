// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/post_votes/post_votes.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/users/users.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/users/users.dart';
import 'package:boorusama/widgets/widgets.dart';

class DanbooruVoterListPage extends ConsumerWidget {
  const DanbooruVoterListPage({
    super.key,
    required this.postId,
  });

  final int postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    final voteRepo = ref.watch(danbooruPostVoteRepoProvider(config));
    final userRepo = ref.watch(danbooruUserRepoProvider(config));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voters'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: InfoContainer(
              title: '',
              contentBuilder: (context) =>
                  const Text('Downvotes and private votes are hidden.'),
            ),
          ),
          DanbooruSliverUserListPage(
            fetchUsers: (page) async {
              final votes = await voteRepo.getPostVotes(postId, page: page);
              final userIds = votes.map((e) => e.userId).toList();
              final users = await userRepo.getUsersByIds(userIds);
              return users;
            },
          ),
        ],
      ),
    );
  }
}

class DanbooruFavoriterListPage extends ConsumerWidget {
  const DanbooruFavoriterListPage({
    super.key,
    required this.postId,
  });

  final int postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    final client = ref.watch(danbooruClientProvider(config));
    final userRepo = ref.watch(danbooruUserRepoProvider(config));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users who favorited'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: InfoContainer(
              title: '',
              contentBuilder: (context) => const Text(
                'Only public favorites are shown.',
              ),
            ),
          ),
          DanbooruSliverUserListPage(
            fetchUsers: (page) async {
              final votes =
                  await client.getFavorites(postId: postId, page: page);
              final userIds = votes.map((e) => e.userId).toList();
              final users = await userRepo.getUsersByIds(userIds);
              return users;
            },
          ),
        ],
      ),
    );
  }
}

class DanbooruSliverUserListPage extends ConsumerStatefulWidget {
  const DanbooruSliverUserListPage({
    super.key,
    required this.fetchUsers,
  });

  final Future<List<DanbooruUser>> Function(int page) fetchUsers;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DanbooruUserListPageState();
}

class _DanbooruUserListPageState
    extends ConsumerState<DanbooruSliverUserListPage> {
  final pagingController = PagingController<int, DanbooruUser>(
    firstPageKey: 1,
  );

  @override
  void initState() {
    super.initState();
    pagingController.addPageRequestListener(_onPageChanged);
  }

  void _onPageChanged(pageKey) {
    _fetchPage(pageKey);
  }

  @override
  void dispose() {
    super.dispose();
    pagingController.removePageRequestListener(_onPageChanged);
    pagingController.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    final users = await widget.fetchUsers(pageKey);
    if (users.isEmpty) {
      pagingController.appendLastPage(users);
    } else {
      final nextPageKey = pageKey + 1;
      pagingController.appendPage(users, nextPageKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PagedSliverList(
      pagingController: pagingController,
      builderDelegate: PagedChildBuilderDelegate<DanbooruUser>(
        newPageProgressIndicatorBuilder: (context) => _buildLoading(),
        firstPageProgressIndicatorBuilder: (context) => _buildLoading(),
        itemBuilder: (context, user, index) => ListTile(
          title: Text(
            user.name,
            style: TextStyle(
              color: user.level.toColor(context),
            ),
          ),
          onTap: () {
            goToUserDetailsPage(
              ref,
              context,
              uid: user.id,
              username: user.name,
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        height: 24,
        width: 24,
        child: const CircularProgressIndicator.adaptive(),
      ),
    );
  }
}
