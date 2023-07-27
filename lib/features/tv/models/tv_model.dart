class TvModel {
  final int? index;
  final String thumbnail;
  final String title;
  final String link;
  final bool allUser;
  final String documentId;

  TvModel({
    required this.index,
    required this.thumbnail,
    required this.title,
    required this.link,
    required this.allUser,
    required this.documentId,
  });

  TvModel.empty()
      : index = 0,
        thumbnail = "",
        title = "",
        link = "",
        allUser = false,
        documentId = "";

  Map<String, dynamic> toJson() {
    return {
      "index": index,
      "thumbnail": thumbnail,
      "title": title,
      "link": link,
      "allUser": allUser,
      "documentId": documentId,
    };
  }

  TvModel.fromJson(Map<String, dynamic> json)
      : index = json["index"],
        thumbnail = json["thumbnail"],
        title = json["title"],
        link = json["link"],
        allUser = json["allUser"],
        documentId = json["documentId"];

  TvModel copyWith({
    final int? index,
    final String? thumbnail,
    final String? title,
    final String? link,
    final bool? allUser,
    final String? documentId,
  }) {
    return TvModel(
      index: index ?? this.index,
      thumbnail: thumbnail ?? this.thumbnail,
      title: title ?? this.title,
      link: link ?? this.link,
      allUser: allUser ?? this.allUser,
      documentId: documentId ?? this.documentId,
    );
  }
}
