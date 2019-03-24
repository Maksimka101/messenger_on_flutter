import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:messenger_for_nou/models/chat_item_model.dart';
import 'package:messenger_for_nou/models/message_model.dart';
import 'package:messenger_for_nou/models/user_model.dart';

class FirestoreRepository {
  static const _USERS_CHATS = "users_chats";
  static const _USERS_CHATS_INFO = "users_chats_info";
  static const MESSAGES = "messages";
  static const _USERS = "users";
  static const _NAME = "name";
  static const _MESSAGES_BY_DATE = "messages_by_date";

  static Stream<List<String>> getAllUsersId() =>
      Firestore.instance.collection(_USERS).snapshots().map((users) {
        final list = List<String>();
        users.documents.map((doc) {
          list.add(doc.documentID);
        }).toList();
        return list;
      });

  static Stream<List<ChatItem>> getChats(String userId) => Firestore.instance
          .collection(_USERS_CHATS_INFO)
          .document(userId)
          .snapshots()
          .map((snapshot) {
        final list = List<ChatItem>();
        if (snapshot.data != null)
          snapshot.data.forEach((key, chatItemData) {
            list.add(ChatItem.fromMap(key, chatItemData));
          });
        return list;
      });

  static Stream<List<Message>> getMessages(
          String chatName, String dateForLoad) =>
      Firestore.instance
          .collection(_USERS_CHATS)
          .document(chatName)
          .collection(_MESSAGES_BY_DATE)
          .document(dateForLoad)
          .snapshots()
          .map((snapshot) {
        final list = List<Message>();
        if (snapshot.data != null)
          snapshot.data.forEach((key, value) {
            list.add(Message.fromMap(key, value));
          });
        return list;
      });

  static sendMessage(
      {String chatName,
      String senderId,
      String data,
      String time,
      String id,
      String senderName,
      bool createChatForNewDay,
      String currentDate}) async {
    if (createChatForNewDay) {
      await Firestore.instance
          .collection(_USERS_CHATS)
          .document(chatName)
          .collection(_MESSAGES_BY_DATE)
          .document(currentDate)
          .setData({});
      Firestore.instance
        .collection(_USERS_CHATS_INFO)
        .document(senderId).get().then((chatInfo) {
          final list = chatInfo.data[chatName][ChatItem.CHATS_BY_DATE]
            .map((date) => date.toString()).toList();
          list.add(currentDate);
          chatInfo.data[chatName][ChatItem.CHATS_BY_DATE] = list;
          Firestore.instance.collection(_USERS_CHATS_INFO)
            .document(senderId).updateData(chatInfo.data);
        });
          
    }

    Firestore.instance
        .collection(_USERS_CHATS)
        .document(chatName)
        .collection(_MESSAGES_BY_DATE)
        .document(currentDate)
        .updateData({
      id: {
        Message.SENDER: senderId,
        Message.TEXT_FIELD: data,
        Message.TIME_FIELD: time,
        Message.SENDER_NAME: senderName,
      }
    });
  }

  static addNewUser(String userId, String userName) async {
    final user =
        await Firestore.instance.collection(_USERS).document(userId).get();

    if (user.data == null) {
      Firestore.instance
          .collection(_USERS)
          .document(userId)
          .setData({_NAME: userName});
      Firestore.instance
          .collection(_USERS_CHATS_INFO)
          .document(userId)
          .setData({});
    }
  }

  static addNewChat({String sender1Id, String sender2Id}) async {
    final chatId = sender1Id + sender2Id;
    String sender1Name;
    String sender2Name;
    final date = DateTime.now();
    final currentDate = "${date.day} ${date.month} ${date.year}";

    var data =
        await Firestore.instance.collection(_USERS).document(sender1Id).get();
    sender1Name = data.data[_NAME];
    data =
        await Firestore.instance.collection(_USERS).document(sender2Id).get();
    sender2Name = data.data[_NAME];

    await _updateChatInfoForUser(
        chatId: chatId,
        userId: sender2Id,
        user2Id: sender1Id,
        user2Name: sender1Name,
        currentDate: currentDate);
    await _updateChatInfoForUser(
        chatId: chatId,
        userId: sender1Id,
        user2Id: sender2Id,
        user2Name: sender2Name,
        currentDate: currentDate);

    final chat = await Firestore.instance
        .collection(_USERS_CHATS)
        .document(chatId)
        .get();
    if (chat.data == null)
      Firestore.instance
          .collection(_USERS_CHATS)
          .document(chatId)
          .collection(_MESSAGES_BY_DATE)
          .document(currentDate)
          .setData({});
  }

  static Future<User> getUser(String userId) => Firestore.instance
          .collection(_USERS)
          .document(userId)
          .get()
          .then((userMap) {
        User.userId = userId;
        User.name = userMap.data["name"];
        return User(
          userIdentity: userId,
          userName: userMap.data["name"],
        );
      });

  static _updateChatInfoForUser(
      {String userId,
      String user2Id,
      String user2Name,
      String chatId,
      String currentDate}) {
    Firestore.instance
        .collection(_USERS_CHATS_INFO)
        .document(userId)
        .updateData({
      chatId: {
        "senderId": user2Id,
        "senderName": user2Name,
        ChatItem.CHATS_BY_DATE: [currentDate],
      }
    });
  }
}
