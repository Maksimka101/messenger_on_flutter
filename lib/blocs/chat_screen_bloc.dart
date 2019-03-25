import 'dart:core';
import 'package:messenger_for_nou/models/message_model.dart';
import 'package:messenger_for_nou/models/user_model.dart';
import 'package:messenger_for_nou/resources/firestore_repository.dart';
import 'package:messenger_for_nou/utils/sorting.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';

class ChatScreenBloc {
  ChatScreenBloc({
    this.chatId,
    this.friendName,
    this.messagesByDate,
  }) {
    final date = DateTime.now();
    _currentDate = "${date.day} ${date.month} ${date.year}";
    _lastLoadDateIndex = messagesByDate.length - 1;
    loadMoreMessages();
  }

  final String chatId;
  final String friendName;
  final List<String> messagesByDate;
  String _currentDate;
  List<Message> _previousMessages = [];
  int _lastLoadDateIndex;
  int _lastId = 0;
  int _lastSeenMessageId;
  var _newMessages = <Message>[];

  final _messagesStream = PublishSubject<List<Message>>();

  Observable<List<Message>> getStreamForUi() {
    _listenForLastSeenMessage();
    _listenForMessages();
    return _messagesStream.stream;
  }

  final _inputStream = PublishSubject<String>();

  StreamSink<String> getInputStream() {
    _listenForInput();
    return _inputStream.sink;
  }

  final _lastSeenMessageIdStream = PublishSubject<int>();

  StreamSink<int> getLastSeenMessageId() {
    _listenForLastSeenMessageId();
    return _lastSeenMessageIdStream.sink;
  }

  void _listenForLastSeenMessageId() => _lastSeenMessageIdStream.stream
      .listen((int id) => FirestoreRepository.setLastSeenMessageId(chatId, id));

  void loadMoreMessages() {
    if (_lastLoadDateIndex >= 0 &&
        messagesByDate[_lastLoadDateIndex] == _currentDate) {
      _lastLoadDateIndex--;
    }
    if (_lastLoadDateIndex >= 0) {
      FirestoreRepository.getMessages(
              chatId, messagesByDate[_lastLoadDateIndex])
          .listen((messages) {
        if (messages.isNotEmpty) {
          _previousMessages += sortMessagesById(messages);
          if (_previousMessages.first.id > _lastId)
            _lastId = _previousMessages.first.id + 1;
        }
        _messagesStream.sink.add(_newMessages + _previousMessages);
      });
      _lastLoadDateIndex--;
    }
  }

  void _listenForLastSeenMessage() =>
      FirestoreRepository.getLatSeenMessageId(chatId).listen((int lastSennId) {
        _lastSeenMessageId = lastSennId;
        _messagesStream.sink.add(_prepareMessages(
            _newMessages + _previousMessages, lastSennId));
      });

  void _listenForInput() => _inputStream.stream.listen((String messageText) {
        FirestoreRepository.sendMessage(
          createChatForNewDay: _currentDate != messagesByDate.last,
          chatName: chatId,
          data: messageText,
          time:
              "${DateTime.now().hour}:${DateTime.now().minute < 10 ? "0" : ""}"
              "${DateTime.now().minute}",
          senderId: User.userId,
          senderName: User.name,
          id: _lastId.toString(),
          currentDate: _currentDate,
        );
        _lastId++;
        if (_currentDate != messagesByDate.last)
          messagesByDate.add(_currentDate);
      });

  void _listenForMessages() =>
      FirestoreRepository.getMessages(chatId, _currentDate).listen((messages) {
        _newMessages = sortMessagesById(messages);
        _messagesStream.sink.add(_prepareMessages(
            _newMessages + _previousMessages, _lastSeenMessageId));
        if (_newMessages.first.id > _lastId) _lastId = _newMessages.first.id;
        _lastId++;
      });

  // add "isSeen" and "ifFirst"
  List<Message> _prepareMessages(
      List<Message> messages, int id) {
    final _messages = <Message>[];
    for (int i = 0; i < messages.length - 1; i++) {
      if (messages[i].isFromUser && id != null)
        messages[i].isSeen = messages[i].id <= id;
      else
        messages[i].isSeen = true;
      if (messages[i].isFromUser == messages[i + 1].isFromUser)
        messages[i].isFirst = false;
      else
        messages[i].isFirst = true;
        print(messages[i].messageText+" "+messages[i].isFirst.toString());
      _messages.add(messages[i]);
    }
    return _messages;
  }

  dispose() {
    _lastSeenMessageIdStream.close();
    _messagesStream.close();
    _inputStream.close();
  }
}
