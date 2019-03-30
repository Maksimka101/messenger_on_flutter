import 'dart:async';
import 'package:flutter/material.dart';
import 'package:messenger_for_nou/blocs/chat_screen_bloc.dart';
import 'package:messenger_for_nou/models/message_model.dart';
import 'package:messenger_for_nou/ui/message_item.dart';

class MessagesScreen extends StatelessWidget {
  MessagesScreen(
      {@required this.companionName,
      @required this.chatId,
      @required this.bloc});

  final ChatScreenBloc bloc;
  final String companionName;
  final String chatId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.black87,
              child: Text(
                companionName[0],
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
                child: Text("Chat with $companionName"),
              ),
            )
          ],
        ),
      ),
      body: ChatBody(
        companionName: companionName,
        chatName: chatId,
        bloc: bloc,
      ),
    );
  }
}

class ChatBody extends StatefulWidget {
  ChatBody(
      {@required this.companionName,
      @required this.chatName,
      this.bloc});

  final ChatScreenBloc bloc;
  final String companionName;
  final String chatName;
  @override
  _ChatBodyState createState() => _ChatBodyState();
}

class _ChatBodyState extends State<ChatBody> {
  ChatScreenBloc _bloc;
  Stream<List<Message>> _uiBuildStream;
  StreamSink<String> _inputStream;
  StreamSink<int> _lastSeenMessageIdStream;
  final _listViewController = ScrollController();
  final _inputController = TextEditingController();
  int _lastSeenId = 0;

  @override
  void initState() {
    _bloc = widget.bloc;
    _uiBuildStream = _bloc.getStreamForUi();
    _inputStream = _bloc.getInputStream();
    _lastSeenMessageIdStream = _bloc.getLastSeenMessageId();
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
              return ListView.builder(
                reverse: true,
                controller: _listViewController,
                shrinkWrap: true,
                itemCount: messagesDoc.data.length,
                itemBuilder: (context, id) {
                  final currentMessage = messagesDoc.data[id];
                  if (!currentMessage.isFromUser &&
                      currentMessage.id > _lastSeenId &&
                      !currentMessage.isSeen) {
                    _lastSeenId = currentMessage.id;
                    _lastSeenMessageIdStream.add(currentMessage.id);
                  }
                  if (messagesDoc.data.length - 10 < id)
                    _bloc.loadMoreMessages();
                  return MessageItem.fromMessage(currentMessage);
                },
              );
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
