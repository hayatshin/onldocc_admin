class PathExtra {
  final String? userId;
  final String? userName;

  PathExtra({required this.userId, required this.userName});

  PathExtra.fromJson(Map<String, dynamic> json)
      : userId = json["userId"],
        userName = json["userName"];
}
