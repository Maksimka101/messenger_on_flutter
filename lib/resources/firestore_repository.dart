import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:messenger_for_nou/models/chat_item_model.dart';
import 'package:messenger_for_nou/models/message_model.dart';
import 'package:messenger_for_nou/models/user_model.dart';

class FirestoreRepository {
  static const _USERS_CHATS = "users_chats";
  static const _USERS_CHATS_INFO = "users_chats_info";
  static const MESSAGES = "messages";
  static const _USERS = "users";
  static const _SENDER_NAME = "senderName";
  static const _SENDER_ID = "senderId";
  static const NAME = "name";
  static const MAIL = "mail";
  static const MESSAGES_BY_ID_LAST_ID = "messages_by_id_last_id";
  static const MESSAGES_BY_ID = "messages_by_id";
  static const LAST_SEEN_MESSAGE_ID = "last_seen_message_id";

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

  static Stream<int> getLastSeenMessageId(String chatId) => Firestore.instance
      .collection(_USERS_CHATS)
      .document(chatId)
      .snapshots()
      .map((lastSeenDoc) => lastSeenDoc.data != null
          ? lastSeenDoc.data[LAST_SEEN_MESSAGE_ID]
          : -1);

  static setLastSeenMessageId(String chatId, int id) => Firestore.instance
      .collection(_USERS_CHATS)
      .document(chatId)
      .updateData({LAST_SEEN_MESSAGE_ID: id});

  static Stream<List<Message>> getMessages(String chatName, String idForLoad) =>
      Firestore.instance
          .collection(_USERS_CHATS)
          .document(chatName)
          .collection(MESSAGES_BY_ID)
          .document(idForLoad)
          .snapshots()
          .map((snapshot) {
        final list = <Message>[];
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
      int id,
      String senderName,
      bool createChatForNewId}) async {
    if (createChatForNewId) {
      await Firestore.instance
          .collection(_USERS_CHATS)
          .document(chatName)
          .collection(MESSAGES_BY_ID)
          .document(((id ~/ 100 + 1) * 100).toString())
          .setData({});
      Firestore.instance
          .collection(_USERS_CHATS_INFO)
          .document(senderId)
          .get()
          .then((chatInfo) {
        chatInfo.data[chatName][MESSAGES_BY_ID_LAST_ID] = (id ~/ 100 + 1) * 100;
        Firestore.instance
            .collection(_USERS_CHATS_INFO)
            .document(senderId)
            .updateData(chatInfo.data);
        final user2Id = chatInfo.data[chatName][_SENDER_ID];
        print(user2Id);
        Firestore.instance
            .collection(_USERS_CHATS_INFO)
            .document(user2Id)
            .get()
            .then((chatinfo) {
          chatinfo.data[chatName][MESSAGES_BY_ID_LAST_ID] =
              (id ~/ 100 + 1) * 100;
          Firestore.instance
              .collection(_USERS_CHATS_INFO)
              .document(user2Id)
              .updateData(chatinfo.data);
        });
      });
    }

    Firestore.instance
        .collection(_USERS_CHATS)
        .document(chatName)
        .collection(MESSAGES_BY_ID)
        .document(((id ~/ 100 + 1) * 100).toString())
        .updateData({
      id.toString(): {
        Message.SENDER: senderId,
        Message.TEXT_FIELD: data,
        Message.TIME_FIELD: time,
        Message.SENDER_NAME: senderName,
      }
    });
  }

  static addNewUser(String userId, String userName, String userMail) async {
    final user =
        await Firestore.instance.collection(_USERS).document(userId).get();

    if (user.data == null) {
      Firestore.instance
          .collection(_USERS)
          .document(userId)
          .setData({NAME: userName, MAIL: userMail});
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

    var data =
        await Firestore.instance.collection(_USERS).document(sender1Id).get();
    sender1Name = data.data[NAME];
    data =
        await Firestore.instance.collection(_USERS).document(sender2Id).get();
    sender2Name = data.data[NAME];

    await _updateChatInfoForUser(
        chatId: chatId,
        userId: sender2Id,
        user2Id: sender1Id,
        user2Name: sender1Name,
        lastMessageId: -1);
    await _updateChatInfoForUser(
        chatId: chatId,
        userId: sender1Id,
        user2Id: sender2Id,
        user2Name: sender2Name,
        lastMessageId: -1);

    final chat = await Firestore.instance
        .collection(_USERS_CHATS)
        .document(chatId)
        .get();
    if (chat.data == null) {
      Firestore.instance
          .collection(_USERS_CHATS)
          .document(chatId)
          .collection(MESSAGES_BY_ID)
          .add({});
      Firestore.instance
          .collection(_USERS_CHATS)
          .document(chatId)
          .setData({LAST_SEEN_MESSAGE_ID: -1});
    }
  }

  static Future<List<User>> getAllUsers() =>
      Firestore.instance.collection(_USERS).getDocuments().then((usersDoc) {
        final userList = <User>[];
        for (final user in usersDoc.documents) {
          userList.add(User(
            userId: user.documentID,
            userName: user.data["name"],
            userMail: user.data["mail"],
          ));
        }
        return userList;
      });

  static Future<User> getUser(String userId) => Firestore.instance
          .collection(_USERS)
          .document(userId)
          .get()
          .then((userMap) {
        return User(
          userId: userId,
          userName: userMap.data[NAME],
          userMail: userMap.data[MAIL],
        );
      });

  static _updateChatInfoForUser(
      {String userId,
      String user2Id,
      String user2Name,
      String chatId,
      int lastMessageId}) {
    Firestore.instance
        .collection(_USERS_CHATS_INFO)
        .document(userId)
        .updateData({
      chatId: {
        _SENDER_ID: user2Id,
        _SENDER_NAME: user2Name,
        MESSAGES_BY_ID_LAST_ID: lastMessageId,
      }
    });
  }
}
