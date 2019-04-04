import 'dart:async';
import 'package:flutter/material.dart';
import 'package:messenger_for_nou/blocs/chat_screen_bloc.dart';
import 'package:messenger_for_nou/models/message_model.dart';
import 'package:messenger_for_nou/ui/message_item.dart';

class MessagesScreen extends StatelessWidget {
  MessagesScreen({@required this.bloc});

  final ChatScreenBloc bloc;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ChatAppBar(
          bloc: bloc,
        ),
      ),
      body: ChatBody(
        bloc: bloc,
      ),
    );
  }
}

class ChatAppBar extends StatefulWidget {
  ChatAppBar({@required this.bloc});
  final ChatScreenBloc bloc;
  @override
  _ChatAppBarState createState() => _ChatAppBarState();
}

class _ChatAppBarState extends State<ChatAppBar> {
  Stream<Set<int>> _selectedMessages;

  @override
  void initState() {
    _selectedMessages = widget.bloc.selectedMessagesStream;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Set<int>>(
        stream: _selectedMessages,
        builder: (context, snapshot) {
          if (snapshot.data == null || snapshot.data.isEmpty)
            return Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.black87,
                  child: Text(
                    widget.bloc.chatName[0],
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(widget.bloc.chatName),
                  ),
                )
              ],
            );
          else
            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.content_copy),
                  onPressed: () => widget.bloc.copySelectedMessages(),
                ),
                IconButton(
                  icon: Icon(Icons.delete_forever),
                  onPressed: () {
                    widget.bloc.deleteSelectedMessages();
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text(snapshot.data.length.toString()),
                ),
              ],
            );
        });
  }
}

class ChatBody extends StatefulWidget {
  ChatBody({@required this.bloc});

  final ChatScreenBloc bloc;
  @override
  _ChatBodyState createState() => _ChatBodyState();
}

class _ChatBodyState extends State<ChatBody> {
  ChatScreenBloc _bloc;
  Stream<List<Message>> _uiBuildStream;
  StreamSink<String> _inputStream;
  StreamSink<int> _lastSeenMessageIdStream;
  Stream<Set<int>> _selectedMessagesStream;
  final _inputController = TextEditingController();
  int _lastSeenId = 0;

  @override
  void initState() {
    _bloc = widget.bloc;
    _uiBuildStream = _bloc.getStreamForUi();
    _inputStream = _bloc.getInputStream();
    _lastSeenMessageIdStream = _bloc.getLastSeenMessageId();
    _selectedMessagesStream = _bloc.selectedMessagesStream;
    super.initState();
  }

  Widget _inputMessageField() {
    return Column(
      children: <Widget>[
        Divider(
          height: 0,
          color: Colors.black38,
        ),
        Row(
          children: <Widget>[
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                ),
                child: TextFormField(
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  autocorrect: true,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  controller: _inputController,
                  decoration: InputDecoration.collapsed(hintText: "Message"),
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.send,
                color: Colors.black,
              ),
              onPressed: () {
                if (_inputController.text != "") {
                  _inputStream.add(_inputController.text.trim());
                  _inputController.clear();
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _messagesList() => Expanded(
        child: StreamBuilder<List<Message>>(
          stream: _uiBuildStream,
          builder: (context, messagesDoc) {
            if (messagesDoc.data != null && messagesDoc.hasData) {
              return StreamBuilder<Set<int>>(
                  stream: _selectedMessagesStream,
                  builder: (context, selectedMessages) {
                    return ListView.builder(
                      reverse: true,
                      itemCount: messagesDoc.data.length,
                      itemBuilder: (context, id) {
                        bool selectMode = false;
                        if (selectedMessages.data != null &&
                            selectedMessages.data.isNotEmpty) selectMode = true;
                        final currentMessage = messagesDoc.data[id];
                        if (!currentMessage.isFromUser &&
                            currentMessage.id > _lastSeenId &&
                            !currentMessage.isSeen) {
                          _lastSeenId = currentMessage.id;
                          _lastSeenMessageIdStream.add(currentMessage.id);
                        }
                        if (messagesDoc.data.length - 10 < id)
                          _bloc.loadMoreMessages();
                        if (selectedMessages.data != null &&
                            selectedMessages.data.contains(currentMessage.id))
                          return GestureDetector(
                            onTap: () {
                              _bloc.unselectMessage(currentMessage.id);
                            },
                            child: Container(
                              color: Colors.black38,
                              child: MessageItem.fromMessage(currentMessage,
                                  addKey: Key(id.toString())),
                            ),
                          );
                        else
                          return GestureDetector(
                            onTap: () {
                              if (selectMode) {
                                _bloc.selectMessage(
                                    currentMessage.id, currentMessage);
                              }
                            },
                            onLongPress: () {
                              if (!selectMode) {
                                _bloc.selectMessage(
                                    currentMessage.id, currentMessage);
                              }
                            },
                            child: Container(
                              color: Colors.white10,
                              child: MessageItem.fromMessage(currentMessage,
                                  addKey: Key(id.toString())),
                            ),
                          );
                      },
                    );
                  });
            } else
              return Center(
                child: Text("No messages yet"),
              );
          },
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _messagesList(),
        _inputMessageField(),
      ],
    );
  }
}
