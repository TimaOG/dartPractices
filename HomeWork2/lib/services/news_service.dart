import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/article.dart';

class NewsService {
  final Dio _dio = Dio();

  Future<List<Article>> getTopHeadlines() async {
    final response = await _dio.get(
      'https://newsapi.org/v2/top-headlines',
      queryParameters: {
        'country': 'us',
        'apiKey': '98adb494d92b44cfaffb503a6145210f',
      },
    );

    return (response.data['articles'] as List)
        .map((article) => Article.fromJson(article))
        .toList();
  }
}