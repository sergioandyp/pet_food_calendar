import 'package:flutter/material.dart';

class LogOutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Log out"),),
      body: Center(
          child: Text("Se ha cerrado la sesión"),
      ),
    );
  }
}