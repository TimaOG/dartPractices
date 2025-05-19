import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/article.dart';
import '../services/favorite_manager.dart';

class ArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const ArticleCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Stack(
              children: [
                // Основное содержимое карточки (оставлено без изменений)
              Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Изображение статьи
                if (article.urlToImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: article.urlToImage!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      progressIndicatorBuilder: (context, url, progress) =>
                      const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                      const Icon(Icons.error),
                    ),
                  ),

                const SizedBox(height: 12),

                // Заголовок
                Text(
                  article.title ?? 'No title',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Дата публикации
                if (article.publishedAt != null)
                  Text(
                    DateFormat('dd MMM yyyy, HH:mm').format(article.publishedAt!),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),

                const SizedBox(height: 8),

                // Краткое описание
                if (article.description != null)
                  Text(
                    article.description!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),

                // Кнопка избранного
                Positioned(
                  top: 0,
                  right: 0,
                  child: FutureBuilder<bool>(
                    future: FavoriteManager.isFavorite(article.url),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox.shrink();
                      }
                      final isFav = snapshot.data!;
                      return IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.red : null,
                        ),
                        onPressed: () async {
                          await FavoriteManager.toggleFavorite(article);
                          // Опционально: обновление UI
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

        ),
      ),
    );
  }
}