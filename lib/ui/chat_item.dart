import 'package:flutter/material.dart';
import 'package:messenger_for_nou/ui/message_ui.dart';
import 'package:messenger_for_nou/models/chat_item_model.dart';

class ChatUnit extends StatelessWidget {

  ChatUnit({
    @required this.chatItem
  });
  final ChatItem chatItem;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.deepPurple,
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              child: CircleAvatar(
                child: Text(chatItem.chatName[0]),
                backgroundColor: Colors.blueGrey,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Center(child: Text(chatItem.chatName)),
                Divider(),
              ],
            ),
          ],
        ),
      ),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) =>
        ChatUi(companionName: chatItem.senderName, chatId: chatItem.chatId, messagesByDate: chatItem.chatsByDate,)
      )),
    );
  }
 }
