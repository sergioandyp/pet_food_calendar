
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pet_food_calendar/pages/NotInAFamilyHomePage.dart';

import 'FamilyMemberHomePage.dart';
import 'LoginPage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    FirebaseFirestore.instance.settings = Settings(persistenceEnabled: false); // Desactiva persistencia (para no ver datos desactualizados)
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    String userID = FirebaseAuth.instance.currentUser.uid;
    
    return FutureBuilder(
        future: users.doc(userID).get(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text("No se pudo verificar su información");
          }

          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data = snapshot.data.data();   // Me fijo si el usuario tiene familia
            if (data != null && data['family'] != null) return FamilyMemberHomePage();
            return NotInAFamilyHomePage();
          }
          // Mientras tanto, espero
          return Center(child: CircularProgressIndicator(strokeWidth: 5,),);
        },);
  }
}