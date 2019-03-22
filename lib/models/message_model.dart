import 'package:messenger_for_nou/models/user_model.dart';

class Message {
  static const TIME_FIELD = "time";
  static const TEXT_FIELD = "text";
  static const SENDER = "sender";
  static const SENDER_NAME = "sender_name";

  Message({
    this.isFromUser,
    this.messageText,
    this.sendTime,
    this.id,
    this.senderId,
    this.senderName,
    this.isFirst,
  });

  final int id;
  final bool isFirst;
  final String senderId;
  final String senderName;
  final String messageText;
  final bool isFromUser;
  final String sendTime;

  static Message fromMap(String key, Map<dynamic, dynamic> value) => Message(
        id: int.parse(key),
        sendTime: value[TIME_FIELD],
        messageText: value[TEXT_FIELD],
        isFromUser: User.userId == value[SENDER],
        senderName: value[SENDER_NAME],
      );

  Map<String, Map<String, String>> toMap() => {
        id.toString(): {
          TEXT_FIELD: messageText,
          TIME_FIELD: sendTime,
          SENDER: senderId,
          SENDER_NAME: senderName,
        }
      };
}
