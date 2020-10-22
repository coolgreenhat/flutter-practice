import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_app/src/app_bloc.dart';
import 'package:flutter_app/src/article.dart';
import 'package:url_launcher/url_launcher.dart';

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.green,

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: StreamBuilder<UnmodifiableListView<Article>>(
        stream: widget.bloc.articles,
        initialData: UnmodifiableListView<Article>([]),
        builder: (context, snapshot) => ListView(
          children: snapshot.data.map(_buildItem).toList(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(currentIndex: 0,
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
        },
      ),
    );
  }

  Widget _buildItem(Article article) {
    return Padding(
      key:Key(article.title),
      padding: const EdgeInsets.all(16.0),
      child: ExpansionTile(
        title: Text(article.title ?? '[null]', style: TextStyle(fontSize: 24.0)),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(article.type),
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
