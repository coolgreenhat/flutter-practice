import 'dart:async';
import 'dart:collection';
import 'package:flutter_app/src/article.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;

enum StoriesType {
  topStories,
  newStories,
}

class HackerNewsBloc {
 static List<int> _newIds = [ 24789379,24791357,24789070,24770617,24778073,24758772,24817304,24790055,24754662];

 static List<int> _topIds = [
   24799660,24789865,24777268,24798302,24776748,24780798,24788850,
 ];

  Stream<bool> get isLoading => _isLoadingSubject.stream;

  final _isLoadingSubject = BehaviorSubject<bool>.seeded(false);

  final _articlesSubject = BehaviorSubject<UnmodifiableListView<Article>>();

  var _articles = <Article>[];

  final _storiesTypeController = StreamController<StoriesType>();

  // ignore: non_constant_identifier_names
  HackerNewsBloc() {
    _initializeArticles();

    _storiesTypeController.stream.listen((storiesType) async{
        _getArticlesAndUpdate(await _getIds(storiesType));
    });
  }

  Future<void> _initializeArticles() async {
    _getArticlesAndUpdate(await _getIds(StoriesType.topStories));
  }

  Stream<UnmodifiableListView<Article>> get articles => _articlesSubject.stream;

  Sink<StoriesType> get storiesType => _storiesTypeController.sink;

  void close() {
    _storiesTypeController.close();
  }

  Future <List<int>> _getIds(StoriesType type) async {
    final partUrl = type == StoriesType.topStories ? 'top' : 'new';
    final url = '$_baseUrl${partUrl}Stories.json';
    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw HackerNewsApiError("Stories couldn't be fetched.");
    }
    return parseTopStories(response.body).take(10).toList();
  }

  static const _baseUrl = 'https://hacker-news.firebaseio.com/v0/';

  Future<Article> _getArticle(int id) async {
    final storyUrl = '$_baseUrl/item/$id.json';
    final storyRes = await http.get(storyUrl);
    if (storyRes  .statusCode == 200 ) {
      return parseArticle(storyRes.body);
    }
    throw HackerNewsApiError("Article $id couldn't be fetched");
  }

 _getArticlesAndUpdate(List<int> ids) async {
    _isLoadingSubject.add(true);
   await _updateArticles(ids);
   _articlesSubject.add(UnmodifiableListView(_articles));
   _isLoadingSubject.add(false);
 }

  Future<Null> _updateArticles(List<int> articleIds) async{
    final futureArticles = articleIds.map((id) => _getArticle(id));
    final articles = await Future.wait(futureArticles);
    _articles = articles;
  }
}

class HackerNewsApiError extends Error {
  final String message;

  HackerNewsApiError(this.message);
}