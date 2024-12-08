// Package imports:
import 'package:booru_clients/danbooru.dart';

// Project imports:
import 'saved_search.dart';

abstract class SavedSearchRepository {
  Future<List<SavedSearch>> getSavedSearches({
    required int page,
  });

  Future<SavedSearch?> createSavedSearch({
    required String query,
    String? label,
  });

  Future<bool> updateSavedSearch(
    int id, {
    String? query,
    String? label,
  });

  Future<bool> deleteSavedSearch(int id);
}

class SavedSearchRepositoryApi implements SavedSearchRepository {
  const SavedSearchRepositoryApi(
    this.client,
  );

  final DanbooruClient client;

  @override
  Future<List<SavedSearch>> getSavedSearches({
    required int page,
  }) =>
      client
          .getSavedSearches(
            page: page,
            //TODO: shouldn't hardcode it
            limit: 1000,
          )
          .then((value) => value.map(savedSearchDtoToSaveSearch).toList());

  @override
  Future<SavedSearch?> createSavedSearch({
    required String query,
    String? label,
  }) =>
      client
          .postSavedSearch(
            query: query,
            label: label,
          )
          .then(savedSearchDtoToSaveSearch);

  @override
  Future<bool> updateSavedSearch(
    int id, {
    String? query,
    String? label,
  }) =>
      client
          .patchSavedSearch(
            id: id,
            query: query,
            label: label,
          )
          .then((value) => true)
          .catchError((obj) => false);

  @override
  Future<bool> deleteSavedSearch(int id) => client
      .deleteSavedSearch(id: id)
      .then((value) => true)
      .catchError((obj) => false);
}

SavedSearch savedSearchDtoToSaveSearch(SavedSearchDto dto) => SavedSearch(
      id: dto.id!,
      query: dto.query ?? '',
      labels: dto.labels ?? [],
      createdAt: dto.createdAt ?? DateTime(1),
      updatedAt: dto.updatedAt ?? DateTime(1),
      canDelete: dto.id! > 0,
    );
