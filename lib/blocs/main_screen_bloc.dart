import 'dart:async';

import 'package:flutter/material.dart';
import 'package:messenger_for_nou/models/chat_item_model.dart';
import 'package:messenger_for_nou/models/user_model.dart';
import 'package:messenger_for_nou/resources/firestore_repository.dart';
import 'package:messenger_for_nou/ui/add_chat_popup_screen.dart';
import 'package:rxdart/rxdart.dart';

class MainScreenBloc {
  MainScreenBloc({
    this.user,
  }) {
    _loadChatItems();
  }

  final User user;
  final _chatItemsStream = BehaviorSubject<List<ChatItem>>();
  Stream<List<ChatItem>> getItemsStream() {
    return _chatItemsStream.stream;
  }

  _loadChatItems() {
    FirestoreRepository.getChats(User.id).listen((chatItems) {
      _chatItemsStream.sink.add(chatItems);
    });
  }

  addChat(BuildContext context) => Navigator.push(
      context,
      PageRouteBuilder(
          opaque: false, pageBuilder: (context, _, __) => AddChatScreen()));

  dispose() {
    _chatItemsStream.close();
  }
}
