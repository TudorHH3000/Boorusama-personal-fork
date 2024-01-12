// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:equatable/equatable.dart';

@immutable
class Pool extends Equatable {
  const Pool({
    required this.id,
    required this.postIds,
    required this.category,
    required this.description,
    required this.postCount,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Pool.empty() => Pool(
        id: -1,
        postIds: const [],
        category: PoolCategory.unknown,
        description: '',
        postCount: 0,
        name: '',
        createdAt: DateTime(1),
        updatedAt: DateTime(1),
      );

  Pool copyWith({
    PoolId? id,
    List<int>? postIds,
  }) =>
      Pool(
        id: id ?? this.id,
        postIds: postIds ?? this.postIds,
        category: category,
        description: description,
        postCount: postCount,
        name: name,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  final PoolId id;
  final List<int> postIds;
  final PoolCategory category;
  final PoolDescription description;
  final PoolPostCount postCount;
  final PoolName name;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
        id,
        postIds,
        category,
        description,
        postCount,
        name,
        createdAt,
        updatedAt,
      ];
}

enum PoolOrder {
  latest,
  newest,
  postCount,
  name,
}

typedef PoolName = String;
typedef PoolDescription = String;
typedef PoolPostCount = int;
typedef PoolId = int;

enum PoolCategory {
  unknown,
  collection,
  series;
}

typedef PoolCover = ({
  PoolId id,
  String? url,
  double? aspectRatio,
});
