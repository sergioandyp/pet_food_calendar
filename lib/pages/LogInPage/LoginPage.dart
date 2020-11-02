import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LogInPage extends StatefulWidget {
  @override
  _LogInPageState createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {

  bool _processing = false;

  void _logWithGoogle() async {

    setState(() {
      _processing = true;
    });

    if (await signInWithGoogle() == null) {   // Si no se autenticó correctamente, dejo de procesar
      setState(() {
        _processing = false;
      });
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

    if (googleUser != null) {

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser
          .authentication;

      // Create a new credential
      final GoogleAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Log in"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(child: RaisedButton(child: Text("Sign in with Google"), onPressed: _processing? null : _logWithGoogle)),
          _processing? CircularProgressIndicator() : Container(),
        ],
      )
    );
  }
}