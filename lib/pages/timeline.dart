import 'package:Bungee/widgets/header.dart';
import 'package:Bungee/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context, isTitle: true),
      body: FutureBuilder(
        future: _firestore.collection('users').get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          final usernames = snapshot.data.docs;
          List<Text> userlist = [];
          for (var a in usernames) {
            final user = a.get('username');
            print(user);
            userlist.add(Text(user));
          }
          return ListView(
            children: userlist,
          );
        },
      ),
    );
  }
}
