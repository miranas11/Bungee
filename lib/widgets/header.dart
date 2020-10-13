import 'package:flutter/material.dart';

AppBar header(context,
    {bool isTitle = false, String title, bool removebackButton = false}) {
  return AppBar(
    automaticallyImplyLeading: removebackButton,
    backgroundColor: Theme.of(context).accentColor,
    title: Text(
      isTitle ? 'Bungee' : title,
      style: TextStyle(
        fontFamily: isTitle ? 'Signatra' : '',
        fontSize: isTitle ? 35.0 : 20,
      ),
    ),
    centerTitle: true,
  );
}
