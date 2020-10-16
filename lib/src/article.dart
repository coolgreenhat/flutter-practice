class Article {
  final String by;
  final int id;
  final int score;
  final int time;
  final String title;
  final String url;

  const Article({ this.by,
    this.id,
    this.title,
    this.score,
    this.time,
    this.url,
  });
}
  final articles = [
    new Article(
        by: "dhouston",
        id: 8863,
        score: 111,
        time: 1175714200,
        title: "My YC app: Dropbox - Throw away your USB drive",
        url: "http://www.getdropbox.com/u/2/screencast.html"

    )
  ];
