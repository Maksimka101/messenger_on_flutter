import 'package:messenger_for_nou/models/user_model.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as NotificationMesg;

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
    this.isSeen,
    this.documentId,
  });

  final String documentId;
  bool isSeen = true;
  final int id;
  bool isFirst;
  final String senderId;
  final String senderName;
  final String messageText;
  final bool isFromUser;
  final String sendTime;

  static Message fromMap(String key, Map<dynamic, dynamic> value) => Message(
        id: int.parse(key),
        sendTime: value[TIME_FIELD],
        messageText: value[TEXT_FIELD],
        isFromUser: User.id == value[SENDER],
        senderName: value[SENDER_NAME],
        documentId: value["doc_id"],
      );

  Map<String, Map<String, String>> toMap() => {
        id.toString(): {
          TEXT_FIELD: messageText,
          TIME_FIELD: sendTime,
          SENDER: senderId,
          SENDER_NAME: senderName,
          "doc_id": documentId,
        }
      };

  NotificationMesg.Message toNotificationMessage() =>
      NotificationMesg.Message(messageText, DateTime.now(), null);
}
