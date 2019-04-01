import 'dart:async';
import 'package:messenger_for_nou/models/user_model.dart';
import 'package:messenger_for_nou/resources/firestore_repository.dart';
import 'package:rxdart/rxdart.dart';

class AddChatBloc {
  AddChatBloc() {
    FirestoreRepository.getAllUsers().then((users) {
      _users = users;
    });
    _listenForUserIdInput();
  }

  var _users = <User>[];

  final _sortedUsers = PublishSubject<List<User>>();
  Observable<List<User>> getSuitableUsers() => _sortedUsers.stream;

  final _usersIdInput = PublishSubject<String>();
  StreamSink<String> sendUserIdFromUser() => _usersIdInput.sink;

  void _listenForUserIdInput() => _usersIdInput.stream.listen((userId) {
        final sortedUsers = <User>[];
        if (userId.length > 3)
          for (final user in _users)
            if (user.userId.contains(userId)) sortedUsers.add(user);

        _sortedUsers.sink.add(sortedUsers);
      });

  void dispose() {
    _sortedUsers.close();
    _usersIdInput.close();
  }
}
