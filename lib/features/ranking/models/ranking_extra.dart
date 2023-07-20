class RankingExtra {
  final String? userId;
  final String? userName;

  RankingExtra({required this.userId, required this.userName});

  RankingExtra.fromJson(Map<String, dynamic> json)
      : userId = json["userId"],
        userName = json["userName"];
}
