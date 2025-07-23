class DoctorModel {
  final String doctorId;
  final String name;
  final String avatar;
  final String profile;
  final String role;

  DoctorModel(
      {required this.doctorId,
      required this.name,
      required this.avatar,
      required this.profile,
      required this.role});

  DoctorModel.fromJson(Map<String, dynamic> json)
      : doctorId = json["doctorId"],
        name = json["name"],
        avatar = json["avatar"],
        profile = json["profile"],
        role = json["role"];

  @override
  String toString() {
    return "DoctorModel(doctorId: $doctorId, name: $name, avatar: $avatar, profile: $profile, role: $role)";
  }
}
