import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:messenger_for_nou/blocs/chat_screen_bloc.dart';
import 'package:messenger_for_nou/models/message_model.dart';
import 'package:messenger_for_nou/ui/chat_screen.dart';
import 'package:messenger_for_nou/models/chat_item_model.dart';

class ChatUnit extends StatefulWidget {
  ChatUnit({@required this.chatItem});
  final ChatItem chatItem;

  @override
  _ChatUnitState createState() => _ChatUnitState();
  
}

class _ChatUnitState extends State<ChatUnit> {

  ChatScreenBloc _bloc;
  Stream<List<Message>> _streamForLastMessage;
  String _userName;


  _initState() {
    _bloc = ChatScreenBloc(
      chatName: _userName,
      chatId: widget.chatItem.chatId,
      messagesByIdLastId: widget.chatItem.messagesByIdLastMessageId,

    );
    _streamForLastMessage = _bloc.getStreamForUi();
    _userName = widget.chatItem.senderName;
  }

  @override
  void initState() {
    _initState();
    super.initState();
  }

  // return dot if message wasn't seen
  Widget _getIsSeenDot(List<Message> messages) {
    if (messages != null &&
        messages.isNotEmpty &&
        messages.first.isFromUser &&
        messages.first.isSeen != null &&
        !messages.first.isSeen)
      return Text(
        "・",
      );
    else if (messages != null &&
        messages.isNotEmpty &&
        !messages.first.isFromUser &&
        messages.first.isSeen != null &&
        !messages.first.isSeen) {
      int count = 0;
      for (int i = 0; i < messages.length; i++) {
        if (!messages[i].isFromUser &&
            messages[i].isSeen != null &&
            !messages[i].isSeen)
          count++;
        else if (i == messages.length - 1)
          _bloc.loadMoreMessages();
        else
          break;
      }
      return Padding(
        padding: const EdgeInsets.only(right: 5),
        child: CircleAvatar(
          radius: 8,
          backgroundColor: Colors.black45,
          child: Text(
            count.toString(),
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      );
    } else
      return Container();
  }

  Widget _getLastMessageText(Message message) {
    if (message != null) if (message.isFromUser)
      return Text(
        "You: ${message.messageText}",
        maxLines: 1,
      );
    else
      return Text(
        message.messageText,
        maxLines: 1,
      );
    else
      return Text("");
  }

  Widget _lastMessageWidget() => Flexible(
        child: StreamBuilder<List<Message>>(
          stream: _streamForLastMessage,
          builder: (context, messageData) {
            Message lastMessage;
            if (messageData.data != null && messageData.data.isNotEmpty)
              lastMessage = messageData.data.first;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(1.0),
                        child: Text(
                          _userName,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    _getIsSeenDot(messageData.data),
                    Padding(
                      padding: EdgeInsets.only(right: 7),
                      child: Text(
                        lastMessage != null ? lastMessage.sendTime : "",
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(1.0),
                  child: _getLastMessageText(lastMessage),
                )
              ],
            );
          },
        ),
      );

  @override
  Widget build(BuildContext context) {
    _initState();
    return InkWell(
      splashColor: Colors.black,
      child: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: CircleAvatar(
              radius: 24,
              child: Text(
                _userName[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
              backgroundColor: Colors.white70,
            ),
          ),
          _lastMessageWidget(),
        ],
      ),
      onTap: () => Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => MessagesScreen(
                  bloc: _bloc,
                ),
          )),
    );
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
}
