import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/article.dart';

class FavoriteManager {
  static const String _favoritesKey = 'favorites';

  // Переключение статуса избранного
  static Future<void> toggleFavorite(Article article) async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];

    List<Article> existingFavorites = favoritesJson.map((jsonString) {
      final map = json.decode(jsonString);
      return Article.fromJson(map);
    }).toList();

    bool found = existingFavorites.any((fav) => fav.url == article.url);

    List<Article> newFavorites;
    if (found) {
      newFavorites = existingFavorites.where((fav) => fav.url != article.url).toList();
    } else {
      newFavorites = [...existingFavorites, article];
    }

    final newJsonList = newFavorites.map((art) => json.encode(art.toJson())).toList();
    await prefs.setStringList(_favoritesKey, newJsonList);
  }

  // Получение списка избранных новостей
  static Future<List<Article>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];

    return favoritesJson.map((jsonString) {
      final map = json.decode(jsonString);
      return Article.fromJson(map);
    }).toList();
  }

  // Проверка, является ли статья избранной
  static Future<bool> isFavorite(String? url) async {
    if (url == null) return false;
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];

    for (var jsonStr in favoritesJson) {
      final map = json.decode(jsonStr);
      if (map['url'] == url) return true;
    }
    return false;
  }
}