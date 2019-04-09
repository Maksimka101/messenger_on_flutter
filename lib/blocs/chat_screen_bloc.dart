import 'dart:core';
import 'package:flutter/services.dart';
import 'package:messenger_for_nou/blocs/notification_bloc.dart';
import 'package:messenger_for_nou/models/message_model.dart';
import 'package:messenger_for_nou/models/user_model.dart';
import 'package:messenger_for_nou/resources/firestore_repository.dart';
import 'package:messenger_for_nou/utils/sorting.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';

class ChatScreenBloc {
  ChatScreenBloc({
    this.chatName,
    this.chatId,
    this.messagesByIdLastId,
  }) {
    _idForNewMessages = messagesByIdLastId;
    messagesByIdLastId -= 100;
    loadMoreMessages();
    _listenForLastSeenMessage();
    _listenForInput();
    _listenForCurrentLastSeenMessage();
    _listenForMessages();
  }

  final _selectedMessages = <int>{};
  final _dataForSelectedMessages = <int, Message>{};
  final String chatId;
  final String chatName;
  int messagesByIdLastId;
  int _idForNewMessages;
  var _previousMessages = <Message>[];
  int _lastId = 0;
  int _lastSeenMessageId;
  var _newMessages = <Message>[];

  final _messagesStream = BehaviorSubject<List<Message>>();

  Observable<List<Message>> getStreamForUi() {
    return _messagesStream.stream;
  }

  final _inputStream = BehaviorSubject<String>();

  StreamSink<String> getInputStream() {
    return _inputStream.sink;
  }

  final _lastSeenMessageIdStream = BehaviorSubject<int>();

  StreamSink<int> getLastSeenMessageId() {
    return _lastSeenMessageIdStream.sink;
  }

  // work with selected messages
  final _selectedMessagesStream = PublishSubject<Set<int>>();

  Stream<Set<int>> get selectedMessagesStream => _selectedMessagesStream.stream;

  void selectMessage(int messageId, Message message) async {
    _selectedMessages.add(messageId);
    _dataForSelectedMessages[messageId] = message;
    _selectedMessagesStream.sink.add(_selectedMessages);
  }

  void unselectMessage(int messageId) async {
    _selectedMessages.remove(messageId);
    _dataForSelectedMessages.remove(messageId);
    _selectedMessagesStream.sink.add(_selectedMessages);
  }

  void _listenForCurrentLastSeenMessage() => _lastSeenMessageIdStream.stream
      .listen((int id) => FirestoreRepository.setLastSeenMessageId(chatId, id));

  void deleteSelectedMessages() {
    if (_dataForSelectedMessages != null)
      _dataForSelectedMessages.forEach((key, msg) {
        FirestoreRepository.deleteMessage(
            chatId, msg.documentId, key.toString());
      });
    _previousMessages
        .removeWhere((message) => _selectedMessages.contains(message.id));
    _messagesStream.sink.add(_prepareMessages(
        (_newMessages + _previousMessages), _lastSeenMessageId));
    _dataForSelectedMessages.clear();
    _selectedMessages.clear();
    _selectedMessagesStream.sink.add(null);
  }

  void copySelectedMessages() {
    var clipboardText = "";
    if (_dataForSelectedMessages != null)
      for (final msg in _dataForSelectedMessages.values)
        clipboardText += msg.messageText + "\n";
    Clipboard.setData(ClipboardData(text: clipboardText.trimRight()));
    _dataForSelectedMessages.clear();
    _selectedMessages.clear();
    _selectedMessagesStream.sink.add(null);
  }
  // /work with selected messages

/*
  void _sendMessagesNotification() {
    print("send");
    final unreadMessages = <Message>[];
    for (final message in (_newMessages + _previousMessages)) {
      if (!message.isSeen) if (!message.isFromUser)
        unreadMessages.add(message);
      else
        break;
    }
    if (unreadMessages.isNotEmpty)
      Notifications.sendGoupMessage(
          chatId: chatId,
          senderName: unreadMessages.first.senderName,
          senderId: unreadMessages.first.senderId,
          messages: unreadMessages);
  }
*/

  void loadMoreMessages() {
    if (messagesByIdLastId > 0) {
      FirestoreRepository.getMessages(chatId, messagesByIdLastId.toString())
          .listen((messages) {
        if (messages.isNotEmpty) {
          if (_previousMessages.isNotEmpty &&
              _previousMessages.last.id < messages.first.id) return;
          _previousMessages += sortMessagesById(messages);
          if (_previousMessages.first.id > _lastId)
            _lastId = _previousMessages.first.id + 1;
          _messagesStream.sink.add(_prepareMessages(
              (_newMessages + _previousMessages), _lastSeenMessageId));
        }
      });
      messagesByIdLastId -= 100;
    }
  }

  void _listenForLastSeenMessage() =>
      FirestoreRepository.getLastSeenMessageId(chatId).listen((int lastSennId) {
        _lastSeenMessageId = lastSennId;

        _messagesStream.sink.add(
            _prepareMessages(_newMessages + _previousMessages, lastSennId));
      });

  void _listenForInput() => _inputStream.stream.listen((String messageText) {
        final msg = Message(
          sendTime:
              "${DateTime.now().hour}:${DateTime.now().minute < 10 ? "0" : ""}"
              "${DateTime.now().minute}",
          id: _lastId,
          messageText: messageText,
          senderName: User.name,
          senderId: User.id,
          isFromUser: true,
        );
        var newId = false;
        if (_idForNewMessages < _lastId) {
          newId = true;
          _idForNewMessages += 100;
          _previousMessages += _newMessages;
          _listenForMessages();
        }
        _newMessages.insert(0, msg);
        _messagesStream.add(_prepareMessages(
            _newMessages + _previousMessages, _lastSeenMessageId));
        FirestoreRepository.sendMessage(
          createChatForNewId: newId,
          chatName: chatId,
          data: messageText,
          time: msg.sendTime,
          senderId: User.id,
          senderName: User.name,
          id: _lastId,
        );
        _lastId++;
      });

  void _listenForMessages() =>
      FirestoreRepository.getMessages(chatId, _idForNewMessages.toString())
          .listen((messages) {
        // Если удалили что то из _previosMessages, то данные из него придут
        // и попадут в _newMessages. if ниже не дает этому случиться, вроде.
        if (messages != null &&
            messages.isNotEmpty &&
            messages.first.id < _idForNewMessages - 100) return;
        _newMessages = sortMessagesById(messages);
        _messagesStream.sink.add(_prepareMessages(
            (_newMessages + _previousMessages), _lastSeenMessageId));
        if (_newMessages.isNotEmpty && _newMessages.first.id > _lastId)
          _lastId = _newMessages.first.id;
        _lastId++;
      });

  // add "isSeen" and "isFirst"
  List<Message> _prepareMessages(List<Message> messages, int id) {
    final _messages = <Message>[];
    messages.add(null);
    for (int i = 0; i < messages.length - 1; i++) {
      if (id != null)
        messages[i].isSeen = messages[i].id <= id;
      else
        messages[i].isSeen = true;
      if (messages[i + 1] != null &&
          ((messages[i].isFromUser && !messages[i + 1].isFromUser) ||
              (!messages[i].isFromUser && messages[i + 1].isFromUser)))
        messages[i].isFirst = true;
      _messages.add(messages[i]);
    }
    return _messages;
  }

  dispose() {
    _lastSeenMessageIdStream.close();
    _selectedMessagesStream.close();
    _messagesStream.close();
    _inputStream.close();
  }
}
