import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pet_food_calendar/main.dart';

class LogInPage extends StatefulWidget {
  @override
  _LogInPageState createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {

  void logWithGoogle() async {

    await signInWithGoogle();

    // signInWithGoogle().then((userCredential) {
    //   if (userCredential != null) {
    //       Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
    //   }
    //   else {
    //     Scaffold.of(context).showSnackBar(SnackBar(content: Text("No se a podido iniciar sesión")));
    //   }
    // });

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
      body: Center(
        child: StreamBuilder<User>(
          stream: FirebaseAuth.instance.authStateChanges(),
          initialData: FirebaseAuth.instance.currentUser,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text("Error");
            }

            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.data != null) {    // Usuario logeado
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => NewHomePage()));
              }
              // signInWithGoogle();
              return RaisedButton(child: Text("Sign in with Google"), onPressed: signInWithGoogle);
            }

            return CircularProgressIndicator();
          },
        ),
      )
    );
  }
}

//
// class NewLogInPage extends StatelessWidget {
//   final Future<FirebaseApp> _initialization = Firebase.initializeApp();
//   final GoogleSignIn _googleSignIn = GoogleSignIn();
//
//   Future<UserCredential> _signInWithGoogle() async {
//     // Trigger the authentication flow
//     final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
//
//     // Obtain the auth details from the request
//     final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//
//     // Create a new credential
//     final GoogleAuthCredential credential = GoogleAuthProvider.credential(
//       accessToken: googleAuth.accessToken,
//       idToken: googleAuth.idToken,
//     );
//
//     // Once signed in, return the UserCredential
//     return FirebaseAuth.instance.signInWithCredential(credential);
//   }
//
//   void _handleSignIn(BuildContext context) async {
//     if (await _signInWithGoogle() != null){
//       Navigator.of(context).push(MaterialPageRoute(builder: (context) => TestPage(googleSignIn: _googleSignIn,),));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("New Log in"),),
//       body: Center(
//         child: FutureBuilder(
//           future: _initialization,
//           builder: (context, snapshot) {
//             // Check for errors
//             if (snapshot.hasError) {
//               return Text("Error de inicialización de Firebase: ${snapshot.error}");
//             }
//
//             // Once complete, show your application
//             if (snapshot.connectionState == ConnectionState.done) {
//               return Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   RaisedButton(child: Text("Sign in with Google"), onPressed: () => _handleSignIn(context)),
//                   RaisedButton(child: Text("Logged?"), onPressed: () => Scaffold.of(context).showSnackBar(SnackBar(content: Text("${FirebaseAuth.instance.currentUser!=null}")))),
//                 ],
//               );
//             }
//
//             // Otherwise, show something whilst waiting for initialization to complete
//             return CircularProgressIndicator();
//           },
//         ),
//       ),
//     );
//   }
// }

// /////////////////// BORRAR DESPUES
//
// class TestPage extends StatefulWidget {
//   final GoogleSignIn googleSignIn;
//
//   const TestPage({Key key, this.googleSignIn}) : super(key: key);
//
//
//   @override
//   _TestPageState createState() => _TestPageState();
// }
//
// class _TestPageState extends State<TestPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("TestPage"),),
//       body: TestBody(googleSignIn: widget.googleSignIn,),
//     );
//   }
// }
//
// class TestBody extends StatefulWidget {
//   final GoogleSignIn googleSignIn;
//
//   const TestBody({Key key, this.googleSignIn}) : super(key: key);
//
//   @override
//   _TestBodyState createState() => _TestBodyState();
// }
//
// class _TestBodyState extends State<TestBody> {
//
//   void _handleSignOut() async {
//     await GoogleSignIn().signOut();
//     await FirebaseAuth.instance.signOut();
//     setState(() {
//
//     });
//   }
//
//   void _logged(BuildContext context) async {
//     bool logged = await widget.googleSignIn.isSignedIn();
//     Scaffold.of(context).showSnackBar(SnackBar(content: Text("Para Google: $logged, para Firebase: ${FirebaseAuth.instance.currentUser!=null}"), duration: Duration(seconds: 1),));
//     setState(() {});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Center(child: Text("Hola ${FirebaseAuth.instance.currentUser?? "desconocido"}!")),
//         RaisedButton(child: Text("Sign out"), onPressed: _handleSignOut),
//         RaisedButton(child: Text("Logged?"), onPressed: () => _logged(context)),
//       ],
//     );
//   }
// }
