import 'package:flutter/material.dart';
import 'package:messenger_for_nou/blocs/chat_item_bloc.dart';
import 'package:messenger_for_nou/models/message_model.dart';
import 'package:messenger_for_nou/ui/messages_screen.dart';
import 'package:messenger_for_nou/models/chat_item_model.dart';

class ChatUnit extends StatefulWidget {
  ChatUnit({@required this.chatItem});
  final ChatItem chatItem;

  @override
  _ChatUnitState createState() => _ChatUnitState();
}

class _ChatUnitState extends State<ChatUnit> {

  ChatItemBloc _bloc;
  Stream<Message> _streamForLastMessage;
  String _userName;

  @override
  void initState() {
    _bloc = ChatItemBloc(
      chatId: widget.chatItem.chatId,
      date: widget.chatItem.chatsByDate.last,
    );
    _streamForLastMessage = _bloc.getLastMessageStream();
    _userName = widget.chatItem.senderName;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.black,
      child: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: CircleAvatar(
              radius: 24,
              child: Text(_userName[0].toUpperCase(), style: TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),),
              backgroundColor: Colors.white70,
            ),
          ),
          Flexible(
            child: StreamBuilder<Message>(
              stream: _streamForLastMessage,
              builder: (context, messageData) {
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
                        Padding(
                          padding: EdgeInsets.only(right: 7),
                          child: Text(
                            messageData.data != null
                                ? messageData.data.sendTime
                                : "",
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.all(1.0),
                      child: Text(messageData.data != null ? messageData.data.messageText : "", maxLines: 1,),
                    )
                  ],
                );
              },
            ),
          )
        ],
      ),
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MessagesScreen(
                    companionName: widget.chatItem.senderName,
                    chatId: widget.chatItem.chatId,
                    messagesByDate: widget.chatItem.chatsByDate,
                  ))),
    );
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
}
