import 'dart:core';
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
  final _dataForSelectedMessages = <Map<String, String>>{};
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

  final _selectedMessagesStream = PublishSubject<Set<int>>();

  Stream<Set<int>> get selectedMessagesStream => _selectedMessagesStream.stream;

  void selectMessage(int messageId, String documentId) async {
    _selectedMessages.add(messageId);
    _dataForSelectedMessages.add({
      "message": messageId.toString(),
      "document": documentId,
    });
    _selectedMessagesStream.sink.add(_selectedMessages);
  }

  void unselectMessage(int messageId, String documentId) async {
    _selectedMessages.remove(messageId);
    _dataForSelectedMessages.remove({
      "message": messageId.toString(),
      "document": documentId,
    });
    _selectedMessagesStream.sink.add(_selectedMessages);
  }

  void _listenForCurrentLastSeenMessage() => _lastSeenMessageIdStream.stream
      .listen((int id) => FirestoreRepository.setLastSeenMessageId(chatId, id));

  void deleteSelectedMessages() async {
    if (_dataForSelectedMessages != null)
      _dataForSelectedMessages.forEach((msg) {
        FirestoreRepository.deleteMessage(
            chatId, msg["document"], msg["message"]);
      });
    _dataForSelectedMessages.clear();
    _selectedMessages.clear();
    _selectedMessagesStream.sink.add(null);
  }

  void loadMoreMessages() {
    if (messagesByIdLastId > 0) {
      FirestoreRepository.getMessages(chatId, messagesByIdLastId.toString())
          .listen((messages) {
        if (messages.isNotEmpty) {
          _previousMessages += sortMessagesById(messages);
          if (_previousMessages.first.id > _lastId)
            _lastId = _previousMessages.first.id + 1;
        }
        _messagesStream.sink.add(_prepareMessages(
            (_newMessages + _previousMessages), _lastSeenMessageId));
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
        bool newId = false;
        if (_idForNewMessages < _lastId) {
          newId = true;
          _idForNewMessages += 100;
          _previousMessages += _newMessages;
          _listenForMessages();
        }
        FirestoreRepository.sendMessage(
          createChatForNewId: newId,
          chatName: chatId,
          data: messageText,
          time:
              "${DateTime.now().hour}:${DateTime.now().minute < 10 ? "0" : ""}"
              "${DateTime.now().minute}",
          senderId: User.id,
          senderName: User.name,
          id: _lastId,
        );
        _lastId++;
      });

  void _listenForMessages() =>
      FirestoreRepository.getMessages(chatId, _idForNewMessages.toString())
          .listen((messages) {
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
