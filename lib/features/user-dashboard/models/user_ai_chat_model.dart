class UserAiChatModel {
  final String roomId;
  final int chatTime;

  UserAiChatModel({
    required this.roomId,
    required this.chatTime,
  });

  UserAiChatModel.from(Map<String, dynamic> json)
      : roomId = json.containsKey("roomId") ? json["roomId"] : "",
        chatTime = json.containsKey("chatTime") ? json["chatTime"] : 0;
}
