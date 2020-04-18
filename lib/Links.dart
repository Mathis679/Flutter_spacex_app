class Links {

  final String mission_patch;
  final String article_link;

  Links({this.mission_patch, this.article_link});

  factory Links.fromJson(Map<String, dynamic> json) {
    return Links(
      mission_patch: json['mission_patch'],
        article_link: json['article_link']
    );
  }
}
