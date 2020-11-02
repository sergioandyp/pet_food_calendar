import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pet_food_calendar/pages/AuthWrapper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet food calendar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        buttonColor: Colors.lightBlue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData.dark(),
      home: FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          // Check for errors
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text(
                    "Error de inicialización de Firebase: ${snapshot.error}"),
              ),
            );
          }

          // Once complete, show your application
          if (snapshot.connectionState == ConnectionState.done) {
            print("Firebase initialized");
            return AuthWrapper();
          }

          // Otherwise, show something whilst waiting for initialization to complete
          return Scaffold(
              body: Center(
                  child: CircularProgressIndicator(
            strokeWidth: 5,
          )));
        },
      ),
    );
  }
}