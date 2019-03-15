import 'package:flutter/material.dart';
import 'package:messenger_for_nou/ui/message_ui.dart';

class ChatUnit extends StatelessWidget {

  ChatUnit({
    @required this.chatName,
    @required this.chatId,
    @required this.companionName,
  });
  final String chatId;
  final String chatName;
  final String companionName;

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
                child: Text(chatName[0]),
                backgroundColor: Colors.blueGrey,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Center(child: Text(chatName)),
                Divider(),
              ],
            ),
          ],
        ),
      ),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) =>
        ChatUi(companionName: companionName, chatId: chatId,)
      )),
    );
  }
}
