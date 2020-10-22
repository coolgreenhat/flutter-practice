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

  final _isLoadingSubject = BehaviorSubject<bool>();

  final _articlesSubject = BehaviorSubject<UnmodifiableListView<Article>>();

  var _articles = <Article>[];

  final _storiesTypeController = StreamController<StoriesType>();

  // ignore: non_constant_identifier_names
  HackerNewsBloc() {
    _getArticlesAndUpdate(_topIds);
    
    _storiesTypeController.stream.listen((storiesType) {
      if (storiesType == StoriesType.newStories) {
        _getArticlesAndUpdate(_newIds);
      } else {
        _getArticlesAndUpdate(_topIds);
      }
    });
  }

 Sink<StoriesType> get storiesType => _storiesTypeController.sink;

 Stream<UnmodifiableListView<Article>> get articles => _articlesSubject.stream;

  Future<Article> _getArticle(int id) async {
    final storyUrl = 'https://hacker-news.firebaseio.com/v0/item/$id.json';
    final storyRes = await http.get(storyUrl);
    if (storyRes  .statusCode == 200 ) {
      return parseArticle(storyRes.body);
    }
    return null;
  }

 _getArticlesAndUpdate(List<int> ids) {
    _isLoadingSubject(true);
   _updateArticles(ids).then((_) {
     _articlesSubject.add(UnmodifiableListView(_articles));
   });
 }

  Future<Null> _updateArticles(List<int> articleIds) async{
    final futureArticles = articleIds.map((id) => _getArticle(id));
    final articles = await Future.wait(futureArticles);
    _articles = articles;
  }
}