import 'package:dio/dio.dart';
import 'types/post_dto.dart';

class EShuushuuClient {
  EShuushuuClient({
    Dio? dio,
  }) : _dio = dio ?? Dio(BaseOptions(baseUrl: 'https://e-shuushuu.net'));

  final Dio _dio;

  Future<List<PostDto>> getPosts({
    int? page,
    int? limit,
  }) async {
    final response = await _dio.get(
      '/search/results',
      queryParameters: {
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      },
    );

    return parsePosts(response.data);
  }
}
