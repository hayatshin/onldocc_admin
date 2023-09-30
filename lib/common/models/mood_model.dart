class MoodModel {
  final String description;
  final int position;

  MoodModel({
    required this.description,
    required this.position,
  });
}

final List<MoodModel> moodeList = [
  MoodModel(description: "기뻐요", position: 0),
  MoodModel(description: "설레요", position: 1),
  MoodModel(description: "감사해요", position: 2),
  MoodModel(description: "평온해요", position: 3),
  MoodModel(description: "그냥 그래요", position: 4),
  MoodModel(description: "외로워요", position: 5),
  MoodModel(description: "불안해요", position: 6),
  MoodModel(description: "우울해요", position: 7),
  MoodModel(description: "슬퍼요", position: 8),
  MoodModel(description: "화나요", position: 9),
];
