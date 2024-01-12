// Package imports:
import 'package:equatable/equatable.dart';

class DanbooruArtistUrl extends Equatable {
  const DanbooruArtistUrl({
    required this.url,
    required this.isActive,
  });

  final String url;
  final bool isActive;

  @override
  String toString() => '${isActive ? '' : 'inactive: '}$url}';

  @override
  List<Object?> get props => [url, isActive];
}

const _pixivStacc = '/stacc/';
const _twitterIntent = '/intent/user';
const _pawooAccount = '/web/accounts/';
const _misskeyAccount = '/users/';

extension DanbooruArtistUrlX on DanbooruArtistUrl {
  DanbooruArtistUrl copyWith({
    String? url,
    bool? isActive,
  }) =>
      DanbooruArtistUrl(
        url: url ?? this.url,
        isActive: isActive ?? this.isActive,
      );
}

extension DanbooruArtistUrlIterableX on Iterable<DanbooruArtistUrl> {
  Iterable<DanbooruArtistUrl> filterActive() {
    return where((element) => element.isActive).toList();
  }

  Iterable<DanbooruArtistUrl> filterDuplicates() => where((element) =>
      !element.url.contains(_pixivStacc) &&
      !element.url.contains(_pawooAccount) &&
      !element.url.contains(_misskeyAccount) &&
      !element.url.contains(_twitterIntent)).toList();
}
