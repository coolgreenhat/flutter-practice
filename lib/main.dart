import 'dart:collection';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/app_bloc.dart';
import 'package:flutter_app/src/article.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  final appBloc = HackerNewsBloc();
  runApp(MyApp(bloc:appBloc));
}

class MyApp extends StatelessWidget {
  final HackerNewsBloc bloc;

  MyApp({
    Key key,
    this.bloc,
  }) : super(key: key);

  static const appColor = Colors.white;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: appColor,
        scaffoldBackgroundColor: appColor,
        canvasColor: Colors.black,
        textTheme: Theme.of(context)
          .textTheme
          .copyWith(caption: TextStyle(color: Colors.white54),
          subtitle1: TextStyle(fontFamily: 'SansitaSwashed')
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Hacker News', bloc: bloc,),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final HackerNewsBloc bloc;
  MyHomePage({Key key, this.title, this.bloc}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: LoadingInfo(widget.bloc.isLoading),
        elevation: 0.0,
        actions: [
         Builder(
           builder: (context) => IconButton(
               icon: Icon(Icons.search),
               onPressed: () async {
                  final Article result = await showSearch(
                    context: context,
                    delegate: ArticleSearch(widget.bloc.articles)
                  );
             Scaffold.of(context)
                 .showSnackBar(SnackBar(content: Text(result.title)));
                  if(await canLaunch(result.url)) {
                    launch(result.url);
                  }
           },
           ),
         )
        ]
      ),
      body: StreamBuilder<UnmodifiableListView<Article>>(
        stream: widget.bloc.articles,
        initialData: UnmodifiableListView<Article>([]),
        builder: (context, snapshot) => ListView(
          children: snapshot.data.map(_buildItem).toList(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items:[
          BottomNavigationBarItem(label: 'Top Stories', icon: Icon(Icons.arrow_drop_up),),
          BottomNavigationBarItem(label: 'New Stories', icon: Icon(Icons.new_releases),),
        ],
        onTap: (index) {
        if (index == 0){
          widget.bloc.storiesType.add(StoriesType.topStories);
        }
        else {
          widget.bloc.storiesType.add(StoriesType.newStories);
        }
        setState(() {
          _currentIndex = index;
        });
        },
      ),
    );
  }

  Widget _buildItem(Article article) {
    return Padding(
      key:Key(article.title),
      padding: const EdgeInsets.symmetric(horizontal:4.0, vertical: 12.0),
      child: ExpansionTile(
        title: Text(article.title ?? '[null]', style: TextStyle(fontSize: 24.0)),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${article.descendants} comments'),
              SizedBox(width: 16.0),
              IconButton(
                icon: Icon(Icons.launch),
                color: Colors.green,
                onPressed: () async {
                  if(await canLaunch(article.url)) {
                  launch(article.url);
                  }
                },
              )
            ],
          )
        ],
      ),
    );
  }
}

class ArticleSearch extends SearchDelegate<Article> {
  final Stream<UnmodifiableListView<Article>> articles;

  ArticleSearch(this.articles);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(icon: Icon(Icons.clear), onPressed: () {
        query = '';
      }),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          close(context,null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return StreamBuilder<UnmodifiableListView<Article>>(
      stream: articles,
      builder: (context, AsyncSnapshot<UnmodifiableListView<Article>> snapshot){
        if(!snapshot.hasData){
          return Center(
            child: Text('No Data!',)
          );
        }

        final results = snapshot.data.where((a) => a.title.toLowerCase().contains(query));
        
        return ListView(
        children: results.map<Widget>((a) => ListTile(
            title:Text(a.title, style: Theme.of(context).textTheme.subtitle1.copyWith(fontSize: 16.0,color: Colors.green)),
            leading: Icon(Icons.book),
          onTap: () {
              close(context, a);
          }
        )).toList(),
        );
      },
    );
  }
  
}

class LoadingInfo extends StatefulWidget {
  final Stream<bool> _isLoading;

  LoadingInfo(this._isLoading);

  createState() => LoadingInfoState();
}

class LoadingInfoState extends State<LoadingInfo> with TickerProviderStateMixin {

  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this,
    duration: Duration(seconds: 1));
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: widget._isLoading,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          // if (snapshot.hasData && snapshot.data) {
            _controller.forward().then((f) {
              _controller.reverse();
            });
            return FadeTransition(
              child: Icon(FontAwesomeIcons.hackerNewsSquare),
              opacity: Tween(begin:0.5, end:1.0).animate(CurvedAnimation(
                curve: Curves.easeIn, parent: _controller)
              ), 
            );
          }
          // _controller.reverse();
          // return Container();
        // }
        );
    }
  }

