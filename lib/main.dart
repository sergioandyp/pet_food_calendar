import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:pet_food_calendar/LoginPage.dart';
import 'package:pet_food_calendar/LogoutPage.dart';

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
      home: LogInPage(),
    );
  }
}

class HomePage extends StatefulWidget {
  final User user;

  const HomePage({Key key, @required this.user})
      : assert(user != null),
        super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Set default `_initialized` and `_error` state to false
  bool _initialized = true;    // TESTING
  bool _error = false;
/*
  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      FirebaseFirestore.instance.settings = Settings(persistenceEnabled: false); // Desactiva persistencia (para no ver datos desactualizados)
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
      });
    }
  }
*/
  /*
  @override
  void initState() {
    //initializeFlutterFire();    // Parece que no hace falta inicializarlo de nuevo, solo una vez en el inicio, REVISAR DOCUMENTACION
    super.initState();
  }
*/

  Stream<QuerySnapshot> documentStream;

  void _onFoodClick(int id, bool state) async {

    CollectionReference foodCollection =
        FirebaseFirestore.instance.collection("foods");

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

    FirebaseAuth.instance
        .authStateChanges()
        .listen((User user) {
        if (user == null) {
          print('User is currently signed out! (from HomePage)');
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LogOutPage()));
      }
    });

    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    if (_initialized) {
      documentStream = FirebaseFirestore.instance
          .collection('foods')
          .where('name')
          .orderBy('position')
          .snapshots();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Bienvenido, ${widget.user.displayName}!"),
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
        child: _initialized
            ? StreamBuilder<QuerySnapshot>(
                stream: documentStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: CircularProgressIndicator(
                      strokeWidth: 5,
                    ));
                  }

                  final documents = snapshot.data.docs;
                  final btnHeight = MediaQuery.of(context).size.height /
                      (documents.length + 1);
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: List<Widget>.generate(
                        documents.length,
                        (index) => FoodCalendarButton(
                              id: index,
                              active: documents[index].data()['state'],
                              text: documents[index].data()['name'],
                              time: documents[index].data()['time'].toDate(),
                              height: btnHeight,
                              onPressed: _onFoodClick,
                            )),
                  );
                })
            : _error ? Center(child: Text("Ha ocurrido un error al inicializar Firebase"))
            : Center(
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                ),
              ),
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
