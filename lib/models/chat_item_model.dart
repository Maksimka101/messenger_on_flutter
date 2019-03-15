class ChatItem {
  ChatItem({this.chatId, this.chatName, this.senderName, this.senderId});

  final String chatId;
  final String chatName;
  final String senderName;
  final String senderId;

  static const _SENDER_NAME = "senderName";
  static const _SENDER_ID = "senderId";

  static ChatItem fromMap(String key, Map<dynamic, dynamic> data) => ChatItem(
      chatId: key,
      chatName: data[_SENDER_NAME],
      senderName: data[_SENDER_NAME],
      senderId: data[_SENDER_ID]);
  Map<String, Map<String, String>> toMap() =>
      {chatId: {
        _SENDER_NAME: senderName,
        _SENDER_ID: senderId,
      }};

}
