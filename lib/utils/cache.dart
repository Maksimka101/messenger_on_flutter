import 'package:messenger_for_nou/models/chat_item_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Cache {

  static const CHATS_ID_LIST_NAME = "chats";

  static Future<List<ChatItem>> getChats() async {
    final _sp = await SharedPreferences.getInstance();
    final chatItems = <ChatItem>[];
    final chatsId = _sp.getStringList(CHATS_ID_LIST_NAME);
    if (chatsId != null) {
      for (final chatId in chatsId) {
        chatItems.add(ChatItem.fromList(_sp.getStringList(chatId)));
      }
    }
    return chatItems;
  }

  static addChat(ChatItem chatItem) async {
    final _sp = await SharedPreferences.getInstance();
    final chatsId = _sp.getStringList(CHATS_ID_LIST_NAME);
    if (chatsId != null) {
      if (chatsId.contains(chatItem.chatId))
        chatsId.remove(chatItem.chatId);
      chatsId.add(chatItem.chatId);
      _sp.setStringList(CHATS_ID_LIST_NAME, chatsId);
      _sp.setStringList(chatItem.chatId, chatItem.toList());
    } else {
      _sp.setStringList(CHATS_ID_LIST_NAME, <String>[chatItem.chatId]);
      _sp.setStringList(chatItem.chatId, chatItem.toList());
    }
  }

  /*
  updateChat(ChatItem chatItem, String lastMessage, String lastTime) async {
    final chatsId = _sp.getStringList(CHATS_ID_LIST_NAME);
    if (chatsId != null)
      _sp.setStringList(chatItem.chatId, chatItem.toList(lastMessage: lastMessage, lastTime: lastTime));
  }
  */

  static delChat(String id) async {
    final _sp = await SharedPreferences.getInstance();
    _sp.remove(id);
    final chatsId = _sp.getStringList(CHATS_ID_LIST_NAME);
    if (chatsId !=  null) {
      chatsId.remove(id);
      _sp.setStringList(CHATS_ID_LIST_NAME, chatsId);
    } 
  }
}