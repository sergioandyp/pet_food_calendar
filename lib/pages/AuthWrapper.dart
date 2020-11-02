import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_food_calendar/pages/HomePage/HomePage.dart';
import 'package:pet_food_calendar/pages/LogInPage/LoginPage.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User>(
        stream: FirebaseAuth.instance.authStateChanges(),
        initialData: FirebaseAuth.instance.currentUser,   // Es necesario??
        builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
          print("Auth state: ${snapshot.data}");
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text(
                    "Error en el estado de autenticación: ${snapshot.error}"),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.active) {
            final User _user = snapshot.data;    // Checks authState
            if (_user != null) return HomePage();
            return LogInPage();
          }

          // Si no, esperamos
          return Scaffold(
            body: Center(child: CircularProgressIndicator(strokeWidth: 5.0,),),
          );

        });
  }
}
