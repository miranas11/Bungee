import 'package:Bungee/widgets/header.dart';
import 'package:Bungee/widgets/post.dart';
import 'package:Bungee/widgets/progress.dart';
import 'package:flutter/material.dart';
import 'home.dart';

class PostScreen extends StatelessWidget {
  final String postId;
  final String userId;

  PostScreen({this.postId, this.userId});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: postref.doc(userId).collection('userposts').doc(postId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        Post post = Post.fromDocument(snapshot.data);
        return Scaffold(
          appBar: header(context, title: post.description),
          body: ListView(
            children: <Widget>[
              Container(
                child: post,
              ),
            ],
          ),
        );
      },
    );
  }
}
