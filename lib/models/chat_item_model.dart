class ChatItem {
  ChatItem(
      {this.chatId,
      this.chatName,
      this.senderName,
      this.senderId,
      this.chatsByDate,
      this.isPreloaded,});

  bool isPreloaded = false;
  final String chatId;
  final String chatName;
  final String senderName;
  final String senderId;
  final List<String> chatsByDate;

  static const _SENDER_NAME = "senderName";
  static const _SENDER_ID = "senderId";
  static const CHATS_BY_DATE = "chats_by_date";

  static ChatItem fromMap(String key, Map<dynamic, dynamic> data) {
    final List<String> chatsByData = [];
    for (final date in data[CHATS_BY_DATE]) {
      chatsByData.add(date.toString());
    }
    return ChatItem(
      chatId: key,
      chatName: data[_SENDER_NAME],
      senderName: data[_SENDER_NAME],
      senderId: data[_SENDER_ID],
      chatsByDate: chatsByData,
    );
  }

  Map<String, Map<String, dynamic>> toMap() => {
        chatId: {
          _SENDER_NAME: senderName,
          _SENDER_ID: senderId,
          CHATS_BY_DATE: chatsByDate,
        }
      };

  static ChatItem fromList(List<String> chatElems) {
    return ChatItem(
      chatId: chatElems[0],
      chatName: chatElems[1],
      senderName: chatElems[2],
      senderId: chatElems[3],
      chatsByDate: <String>[chatElems[4]],
      isPreloaded: true,
    );
  }

  List<String> toList() =>
      <String>[chatId, chatName, senderName, senderId, chatsByDate.last];
}
