import 'package:flutter_app/src/article.dart';
import 'dart:convert' as  json;

class Article {
  final String by;
  final int id;
  final int score;
  final int time;
  final String title;
  final String url;

  const Article(
      { this.by,
        this.id,
        this.title,
        this.score,
        this.time,
        this.url,
      });

  factory Article.fromJson(Map<String, dynamic> json) {
    if (json == null)
      return null;

    return Article(
        title: json['title'] ?? '[null]',
        url: json['url'],
        by: json['by'],
        time: json['time'],
        score: json['score']);
  }
}

List<int> parseTopStories(String jsonStr) {
  final parsed = json.jsonDecode(jsonStr);
  final listOfIds = List<int>.from(parsed);
  return listOfIds;
}

Article parseArticle(String jsonStr) {
  final parsed = json.jsonDecode(jsonStr);
  Article article = Article.fromJson(parsed);
  return article;
}