import 'dart:convert';
import 'package:async/async.dart';
import 'package:http/http.dart' as http;

class PostsApi {
  final http.Client _client;
  String baseUrl;
  String post_type;

  PostsApi(this._client, this.baseUrl, this.post_type);

  // Product
  Future<Result<List<dynamic>>> findPosts({
    required int page,
    required int pageSize,
    required String searchTerm,
    String includeMetas = '',
  }) async {
    final String endpoint =
        '$baseUrl/wp-json/wpr-get-posts?post_type=$post_type&numberposts=$pageSize&page=$page&search=$searchTerm&include_metas=[$includeMetas]';
    final result = await _client.get(Uri.parse(endpoint),
        headers: {"Content-type": "application/json"});

    return _parsePostsJson(result);
  }

  Future<Result<List<dynamic>>> getAllPosts({
    required int page,
    required int pageSize,
    String includeMetas = '',
  }) async {
    final String endpoint =
        '$baseUrl/wp-json/wpr-get-posts?post_type=$post_type&numberposts=$pageSize&page=$page&include_metas=[$includeMetas]';
    http.Response result = await _client.get(Uri.parse(endpoint),
        headers: {"Content-type": "application/json"});

    return _parsePostsJson(result);
  }

  Future<Result<Map<String, dynamic>>> getPost({
    required String postId,
  }) async {
    final String endpoint = '$baseUrl/wp-json/wpr-get-post?post_id=$postId';
    http.Response result = await _client.get(Uri.parse(endpoint),
        headers: {"Content-type": "application/json"});

    final json = jsonDecode(result.body);

    if (result.statusCode != 200 || json['status'] != 'success') {
      Map map = jsonDecode(result.body);
      return Result.error(map);
    }

    return Result.value(json['message']);
  }

  // Helper
  Result<List<dynamic>> _parsePostsJson(http.Response result) {
    Map<String, dynamic> json = jsonDecode(result.body);

    if (result.statusCode != 200 || json['status'] != 'success') {
      Map map = jsonDecode(result.body);
      return Result.error(map);
    }

    List<dynamic> response = json['message'];

    return Result.value(response);
  }
}
