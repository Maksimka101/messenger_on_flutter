import 'package:messenger_for_nou/resources/firestore_repository.dart';

class ChatItem {
  ChatItem({
    this.chatId,
    this.chatName,
    this.senderName,
    this.senderId,
    this.isPreloaded,
    this.messagesByIdLastMessageId,
  });

  int messagesByIdLastMessageId;
  bool isPreloaded = false;
  final String chatId;
  final String chatName;
  final String senderName;
  final String senderId;

  static const _SENDER_NAME = "senderName";
  static const _SENDER_ID = "senderId";
  static const LAST_SEEN_MESSAGE_ID = FirestoreRepository.MESSAGES_BY_ID_LAST_ID;

  static ChatItem fromMap(String key, Map<dynamic, dynamic> data) {
    return ChatItem(
      chatId: key,
      chatName: data[_SENDER_NAME],
      senderName: data[_SENDER_NAME],
      senderId: data[_SENDER_ID],
      messagesByIdLastMessageId: data[LAST_SEEN_MESSAGE_ID],
    );
  }

  Map<String, Map<String, dynamic>> toMap() => {
        chatId: {
          _SENDER_NAME: senderName,
          _SENDER_ID: senderId,
          LAST_SEEN_MESSAGE_ID: messagesByIdLastMessageId,
        }
      };

  static ChatItem fromList(List<String> chatElems) {
    return ChatItem(
      chatId: chatElems[0],
      chatName: chatElems[1],
      senderName: chatElems[2],
      senderId: chatElems[3],
      messagesByIdLastMessageId: int.parse(chatElems[4]),
      isPreloaded: true,
    );
  }

  List<String> toList() => <String>[
        chatId,
        chatName,
        senderName,
        senderId,
        messagesByIdLastMessageId.toString(),
      ];
}
