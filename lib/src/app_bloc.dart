import 'dart:async';
import 'dart:collection';
import 'package:flutter_app/src/article.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;

class HackerNewsBloc {
  final _articlesSubject = BehaviorSubject<UnmodifiableListView<Article>>();

  var _articles = <Article>[];

  List<int> _ids = [ 24799660,24789865,24777268,24798302,24776748,24780798,24788850,24789379,24791357,24789070,24770617,24778073,24758772,24817304,24790055,24754662];

  // ignore: non_constant_identifier_names
  HackerNewsBloc() {
    _updateArticles().then((_){
      _articlesSubject.add(UnmodifiableListView(_articles));
    });
  }

  Stream<UnmodifiableListView<Article>> get articles => _articlesSubject.stream;

  Future<Article> _getArticle(int id) async {
    final storyUrl = 'https://hacker-news.firebaseio.com/v0/item/$id.json';
    final storyRes = await http.get(storyUrl);
    if (storyRes  .statusCode == 200 ) {
      return parseArticle(storyRes.body);
    }
    return null;
  }

  Future<Null> _updateArticles() async{
    final futureArticles = _ids.map((id) => _getArticle(id));
    final articles = await Future.wait(futureArticles);
    _articles = articles;
  }





}