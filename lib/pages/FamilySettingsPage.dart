import 'package:flutter/material.dart';
import 'package:pet_food_calendar/services/dynamicLinkService.dart';
import 'package:share/share.dart';

class FamilySettingsPage extends StatelessWidget {

  void _shareFamilyLink(BuildContext context) async {
    // Navigator.of(context).push(MaterialPageRoute(builder: (_) => NewUserPage()));   // Solo par probar la pagina, NO VA ESTO
    final String _linkToShare = await createFamilyLink(familyID: "example");
    Share.share(_linkToShare, subject: "Únete a mi familia en Pet Food Calendar!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Configuración de familia"),),
      body: ListView(
        children: [
          ListTile(title: Text("Añadir a integrante de la familia"), onTap: () => _shareFamilyLink(context),),
        ],
      ),
    );
  }
}
