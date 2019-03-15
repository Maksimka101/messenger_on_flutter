import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:messenger_for_nou/resources/firestore_repository.dart';
import 'package:messenger_for_nou/ui/main_chats_screen.dart';
import 'package:messenger_for_nou/utils/is_user_authorized.dart';

class AuthorizeScreen extends StatefulWidget {
  @override
  _AuthorizeScreenState createState() => _AuthorizeScreenState();
}

class _AuthorizeScreenState extends State<AuthorizeScreen> {

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _userName;
  final _formKey = GlobalKey<FormState>();

  Future<FirebaseUser> _handleSignIn() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser user = await _auth.signInWithCredential(credential);
    return user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign in"),
      ),
      body:
      Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Enter your name low and sign in with google."),
            ),
            Form(
              key: _formKey,
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: "Enter u name here"
                ),
                validator: (String name) {
                  if (name.length < 3) return "Very short name";
                  else {
                    _userName = name;
                  }
                },
              ),
            ),
            FlatButton(
              child: Text("Sign in with Google"),
              onPressed: () {
                _formKey.currentState.validate();
                if (_userName != null)
                  _handleSignIn().then((user) {
                    FirestoreRepository.addNewUser(user.email.replaceAll(".", ""), _userName);
                    Authorization.authorizeUser(_userName, user.email.replaceAll(".", ""));
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => MainChatsScreen(),
                    ));
                  });
              },
            ),
          ],
        ),
      ),
    );
  }
}
