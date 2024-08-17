class PathExtra {
  final String? userId;
  final String? userName;

  PathExtra({required this.userId, required this.userName});

  PathExtra.fromJson(Map<String, dynamic> json)
      : userId = json["userId"],
        userName = json["userName"];
}

class RankingPathExtra {
  final String? userId;
  final String? userName;
  final String? dateRange;

  RankingPathExtra({
    required this.userId,
    required this.userName,
    required this.dateRange,
  });

  RankingPathExtra.fromJson(Map<String, String> json)
      : userId = json["userId"],
        userName = json["userName"],
        dateRange = json["dateRange"];
}
