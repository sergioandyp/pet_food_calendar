import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        buttonColor: Colors.lightBlue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Set default `_initialized` and `_error` state to false
  bool _initialized = false;
  bool _error = false;

  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      FirebaseFirestore.instance.settings = Settings(persistenceEnabled: false);    // Desactiva persistencia
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

  @override
  void initState() {
    initializeFlutterFire();
    super.initState();
  }

  Stream<QuerySnapshot> documentStream;

  void _onFoodClick(int id, bool state) async {
    CollectionReference foodCollection = FirebaseFirestore.instance.collection("foods");

    // final QuerySnapshot snapshot = await foodCollection.where('name').orderBy('position').get();
    // final documents = snapshot.docs;

    ///////////////////////////////// PROBAR: \\\\\\\\\\\\\\\\\\\\\\\\\\\
    WriteBatch batch = FirebaseFirestore.instance.batch();

    if (state) {
      await foodCollection.where('position', isLessThanOrEqualTo: id).get().then((snapshot) {
        snapshot.docs.forEach((document) {
          batch.update(document.reference, {'state': true});
        });
        return batch.commit();
      });
    }
    else {
      await foodCollection.where('position', isGreaterThanOrEqualTo: id).get().then((snapshot) {
        snapshot.docs.forEach((document) {
          batch.update(document.reference, {'state': false});
        });
        return batch.commit();
      });
    }


    // await batch.commit();

    //////////////////////////////////  \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    //
    // if (state) {
    //   // Si se activa
    //   for (int i = 0; i <= id; i++) {
    //     await documents[i].reference.update({'state': true});
    //   }
    // } else {
    //   for (int i = id; i < documents.length; i++) {
    //     await documents[i].reference.update({'state': false});
    //   }
    // }

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
        title: Text("Pet food calendar"),
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
                    return Center(child: CircularProgressIndicator(strokeWidth: 5,));
                  }

                  final documents = snapshot.data.docs;
                  final btnHeight = MediaQuery.of(context).size.height / (documents.length + 1);
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
                              height: btnHeight,
                              onPressed: _onFoodClick,
                            )),
                  );
                })
            : Center(
                child: Center(child: CircularProgressIndicator()),
              ),
      ),
    );
  }
}

class FoodCalendarButton extends StatelessWidget {
  final int id;
  final bool active;
  final String text;
  final double height;
  final Function(int, bool) onPressed;

  const FoodCalendarButton(
      {Key key,
      this.onPressed,
      this.text,
      this.height,
      @required this.id,
      @required this.active})
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
          child: Text(
            text,
            style: TextStyle(
              fontSize: 24,
            ),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          color: active ? enabledColor : disabledColor,
          onPressed: () => onPressed(id, !active),
        ),
      ),
    );
  }
}