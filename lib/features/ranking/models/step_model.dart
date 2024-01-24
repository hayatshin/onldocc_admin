class StepModel {
  final String date;
  final int? dailyStep;

  StepModel({required this.date, required this.dailyStep});

  StepModel.empty()
      : date = "",
        dailyStep = 0;

  Map<String, dynamic> toJson() {
    return {
      "date": date,
      "dailyStep": dailyStep,
    };
  }

  StepModel.fromJson(Map<String, dynamic> json)
      : date = json["date"],
        dailyStep = json["step"];

  StepModel copyWith({
    final String? date,
    final int? dailyStep,
  }) {
    return StepModel(
      date: date ?? this.date,
      dailyStep: dailyStep ?? this.dailyStep,
    );
  }
}
