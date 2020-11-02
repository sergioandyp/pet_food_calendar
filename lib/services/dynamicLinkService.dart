import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/widgets.dart';

Future<String> createFamilyLink({@required String familyID}) async {

  final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: "https://petfoodcalendar.page.link",
      link: Uri.parse("https://pet-food-calendar.web.app/family?id=$familyID"),
      androidParameters: AndroidParameters(
        packageName: "com.sap.pet_food_calendar",
      ),
  );

  final ShortDynamicLink dynamicUrl = await parameters.buildShortLink();
  // print(dynamicUrl.warnings);
  return dynamicUrl.shortUrl.toString();
  
}