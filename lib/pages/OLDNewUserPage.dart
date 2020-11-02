import 'package:flutter/material.dart';

class NewUserPage extends StatefulWidget {
  @override
  _NewUserPageState createState() => _NewUserPageState();
}

class _NewUserPageState extends State<NewUserPage> {

  void _closeDialog() {
    Navigator.of(context).pop();
  }

  void _joinFamilyDialog() {

    final AlertDialog _joinDialog = AlertDialog(
      title: Text("Unirse a una familia existente"),
      content: SingleChildScrollView(
        child: Row(
          children: [
            Text("Ingrese el ID de la familia:"),
            SizedBox(width: 10,),
            Expanded(
              child: TextField(
                decoration: InputDecoration(hintText: "ID de familia"),
              ),
            )
          ],
        ),
      ),
      actions: [
        TextButton(child: Text("Cancelar", textAlign: TextAlign.end), onPressed: _closeDialog,),
        TextButton(child: Text("Aceptar", textAlign: TextAlign.end,), onPressed: _closeDialog,),
      ],
    );

    showDialog(context: context, builder: (context) => _joinDialog);

  }

  void _newFamilyDialog() {

    final AlertDialog _createDialog = AlertDialog(
      title: Text("Crear nueva familia"),
      content: SingleChildScrollView(
        child:  TextField(
          decoration: InputDecoration(hintText: "Nombre de familia"),
        ),
      ),
      actions: [
        TextButton(child: Text("Cancelar", textAlign: TextAlign.end), onPressed: _closeDialog,),
        TextButton(child: Text("Crear", textAlign: TextAlign.end,), onPressed: _closeDialog,),
      ],
    );

    showDialog(context: context, builder: (context) => _createDialog);
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Únete a una familia!"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RaisedButton(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Crear una familia"),
                  SizedBox(width: 5,),
                  Icon(Icons.add)],
              ),
              onPressed: _newFamilyDialog,
            ),
            RaisedButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Unirse a una familia"),
                    SizedBox(width: 5,),
                    Icon(Icons.family_restroom)
                  ],),
                onPressed: _joinFamilyDialog,
                ),
          ],
        ),
      ),
    );
  }
}