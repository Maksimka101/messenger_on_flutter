import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:messenger_for_nou/models/user_model.dart';
import 'package:messenger_for_nou/resources/firestore_repository.dart';
import 'package:messenger_for_nou/utils/is_user_authorized.dart';
import 'package:rxdart/rxdart.dart';

enum AuthorizeState {
  signInWithGoogle,
  userInformationInput,
}

class AuthorizeBloc {
  final _authorizeStateStream = PublishSubject<AuthorizeState>();

  Stream<AuthorizeState> getAuthorizeStreamState() =>
      _authorizeStateStream.stream;

  bool isUserExist(String userId) {
    for (User usr in _users) if (usr.userId == userId) return true;
    return false;
  }

  String _userMail;
  var _users = <User>[];
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void registerUser(BuildContext context, String userName, String userId) {
    FirestoreRepository.addNewUser(userId, userName, _userMail);
    Authorization.authorizeUser(userName, userId, _userMail);
    Navigator.popAndPushNamed(context, "/main");
  }

  void handleSignIn(BuildContext context) async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser user = await _auth.signInWithCredential(credential);

    if (user != null) {
      FirestoreRepository.getAllUsers().then((users) {
        _users = users;
        for (User usr in _users) {
          if (usr.userMail == user.email) {
            Authorization.authorizeUser(usr.userName, usr.userId, user.email);
            Navigator.popAndPushNamed(context, "/main");
            return;
          }
        }
        _userMail = user.email;
        _authorizeStateStream.sink.add(AuthorizeState.userInformationInput);
      });
    }
  }

  void dispose() {
    _authorizeStateStream.close();
  }
}
