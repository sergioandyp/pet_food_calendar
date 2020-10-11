import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:pet_food_calendar/LoginPage.dart';

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
            return Scaffold(body: Center(child: Text("Error de inicialización de Firebase: ${snapshot.error}"),),);
          }

          // Once complete, show your application
          if (snapshot.connectionState == ConnectionState.done) {
            if (FirebaseAuth.instance.currentUser != null) return HomePage();
            return LogInPage();
          }

          // Otherwise, show something whilst waiting for initialization to complete
          return Scaffold(body: Center(child: CircularProgressIndicator(strokeWidth: 5,)));
        },
      ),
    );
  }
}


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  CollectionReference foodCollection = FirebaseFirestore.instance.collection("foods");

  void _onFoodClick(int id, bool state) async {

    WriteBatch batch = FirebaseFirestore.instance.batch();

    if (state) {
      await foodCollection
          .where('position', isLessThanOrEqualTo: id)
          .where('state', isEqualTo: false)
          .get()
          .then((snapshot) {
        snapshot.docs.forEach((document) {
          batch.update(document.reference, {'state': true, 'time': Timestamp.now()});
        });
        return batch.commit();
      });
    } else {
      await foodCollection
          .where('position', isGreaterThanOrEqualTo: id)
          .where('state', isEqualTo: true)
          .get()
          .then((snapshot) {
        snapshot.docs.forEach((document) {
          batch.update(document.reference, {'state': false});
        });
        return batch.commit();
      });
    }

  }

  void signOutUser() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut().then(
            (_) => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LogInPage()))
    );
  }

  @override
  void initState() {
    FirebaseFirestore.instance.settings = Settings(persistenceEnabled: false); // Desactiva persistencia (para no ver datos desactualizados)
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bienvenido, ${FirebaseAuth.instance.currentUser.displayName}!"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            tooltip: "Log out",
            iconSize: 30,
            onPressed: signOutUser,
          ),
        ],
      ),
      body: Center(
          child: StreamBuilder<QuerySnapshot>(
              stream: foodCollection.where('name').orderBy('position').snapshots(),
              builder: (context, snapshot) {

                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.active) {
                  final documents = snapshot.data.docs;
                  final btnHeight = MediaQuery.of(context).size.height / (documents.length + 1);
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: List<Widget>.generate(
                        documents.length,
                            (index) =>
                            FoodCalendarButton(
                              id: index,
                              active: documents[index].data()['state'],
                              text: documents[index].data()['name'],
                              time: documents[index].data()['time'].toDate(),
                              height: btnHeight,
                              onPressed: _onFoodClick,
                            )),
                  );
                }

                // Otro caso, esperamos
                return Center(child: CircularProgressIndicator(strokeWidth: 5,));

              })
      ),
    );
  }
}


class FoodCalendarButton extends StatelessWidget {
  final int id;
  final bool active;
  final String text;
  final DateTime time;
  final double height;
  final Function(int, bool) onPressed;

  const FoodCalendarButton(
      {Key key,
      this.onPressed,
      this.text,
      this.height,
      @required this.id,
      @required this.active, this.time})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color enabledColor = Colors.green;
    final Color disabledColor = Theme.of(context).buttonColor;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: RaisedButton(
          child: !active ?
              Text(text, style: TextStyle(fontSize: 24,),)
          : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(text, style: TextStyle(fontSize: 24,),),
              Text(time!=null ? DateFormat.Hm().format(time) : "--:--", style: TextStyle(fontSize: 20, color: Colors.grey[700]),),
            ],
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          color: active ? enabledColor : disabledColor,
          onPressed: () => onPressed(id, !active),
        ),
      ),
    );
  }
}

