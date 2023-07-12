class UserModel {
  final String userId;
  final String name;
  final String age;
  final String fullBirthday;
  final String gender;
  final String phone;
  final String fullRegion;
  final String registerDate;

  UserModel({
    required this.userId,
    required this.name,
    required this.age,
    required this.fullBirthday,
    required this.gender,
    required this.phone,
    required this.fullRegion,
    required this.registerDate,
  });

  UserModel.empty()
      : userId = "",
        name = "",
        age = "",
        fullBirthday = "",
        gender = "",
        phone = "",
        fullRegion = "",
        registerDate = "";

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "name": name,
      "age": age,
      "fullBirthday": fullBirthday,
      "gender": gender,
      "phone": phone,
      "fullRegion": fullRegion,
      "registerDate": registerDate,
    };
  }

  UserModel.fromJson(Map<String, dynamic> json)
      : userId = json["userId"],
        name = json["name"],
        age = json["age"] ?? "정보 없음",
        fullBirthday = json["fullBirthday"] ?? "정보 없음",
        gender = json["gender"] ?? "정보 없음",
        phone = json["phone"] ?? "정보 없음",
        fullRegion = json["fullRegion"] ?? "정보 없음",
        registerDate = json["registerDate"] ?? "정보 없음";
}
