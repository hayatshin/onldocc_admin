class UserStepDataModel {
  final String date;
  final int step;

  UserStepDataModel({
    required this.date,
    required this.step,
  });

  UserStepDataModel.from(Map<String, dynamic> json)
      : date = json.containsKey("date") ? json["date"] : "",
        step = json.containsKey("step") ? json["step"] : "";
}
