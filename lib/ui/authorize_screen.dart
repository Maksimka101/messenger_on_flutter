import 'package:flutter/material.dart';
import 'package:messenger_for_nou/blocs/authorize_bloc.dart';
import 'package:connectivity/connectivity.dart';

class AuthorizeScreen extends StatefulWidget {
  @override
  _AuthorizeScreenState createState() => _AuthorizeScreenState();
}

class _AuthorizeScreenState extends State<AuthorizeScreen> {
  final _authBloc = AuthorizeBloc();
  final _formKey = GlobalKey<FormState>();
  String _userName;
  String _userId;
  final _idFocus = FocusNode();
  bool _isConnected;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Stream<AuthorizeState> _authStateStream;

  void _googleSignIn(BuildContext context) {
    _checkConnection();
    if (_isConnected == null || !_isConnected)
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("No inthernet conntection."),
        backgroundColor: Colors.red,
        duration: Duration(hours: 1),
      ));
    else
      _authBloc.handleSignIn(context);
  }

  void _registerNewUser(BuildContext context) {
    print(_userName);
    if (_userName != null && _userId != null)
      _authBloc.registerUser(context, _userName, _userId);
  }

  void _checkConnection() =>
      Connectivity().checkConnectivity().then((connection) {
        _isConnected = connection != ConnectivityResult.none;
        setState(() {});
      });

  @override
  void initState() {
    _authStateStream = _authBloc.getAuthorizeStreamState();
    _checkConnection();
    super.initState();
  }

  Widget _appLogo() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: CircleAvatar(
          maxRadius: 80,
          backgroundColor: Colors.black,
          child: Text(
            "My app logo",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );

  Widget _signInWithGoogle() => Padding(
        padding: const EdgeInsets.only(top: 60),
        child: RaisedButton(
          child: Text(
            "Sign in with Google",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          onPressed: () => _googleSignIn(context),
        ),
      );

  Widget _userInformationInput() => Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: TextFormField(
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(),
                    hintText: "Enter your name here",
                    prefixIcon: Icon(
                      Icons.person,
                      color: Colors.black54,
                    )),
                validator: (String name) {
                  if (name.length < 3) return "Too short name";
                  if (name.length > 20)
                    return "Too long name";
                  else
                    _userName = name;
                },
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_idFocus);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 40),
              child: TextFormField(
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(),
                    alignLabelWithHint: false,
                    hintText: "Enter your id",
                    prefixIcon: Icon(
                      Icons.local_offer,
                      color: Colors.black54,
                    )),
                validator: (String id) {
                  if (id.length < 5)
                    return "It must be longer than 5 characters";
                  else if (id.contains("."))
                    return "It mustn't contains dots";
                  else if (id.length > 16)
                    return "Too long id";
                  else if (id.contains(" "))
                    return "Id mustn't contain space";
                  else
                    _userId = id;
                },
                focusNode: _idFocus,
                onFieldSubmitted: (_) {
                  _idFocus.unfocus();
                  _registerNewUser(context);
                },
              ),
            ),
            RaisedButton(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: Text(
                "Sign in",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              onPressed: () {
                _formKey.currentState.validate();
                _registerNewUser(context);
              },
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Sign in"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _appLogo(),
            StreamBuilder<AuthorizeState>(
              stream: _authStateStream,
              initialData: AuthorizeState.signInWithGoogle,
              builder: (context, state) {
                if (state.data == AuthorizeState.signInWithGoogle)
                  return _signInWithGoogle();
                else if (state.data == AuthorizeState.userInformationInput)
                  return _userInformationInput();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _authBloc.dispose();
    super.dispose();
  }
}
