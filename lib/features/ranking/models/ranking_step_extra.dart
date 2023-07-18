class RankingStepExtra {
  final String? userId;
  final String? userName;

  RankingStepExtra({required this.userId, required this.userName});

  RankingStepExtra.fromJson(Map<String, dynamic> json)
      : userId = json["userId"],
        userName = json["userName"];
}
