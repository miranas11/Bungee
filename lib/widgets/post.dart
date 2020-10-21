import 'package:Bungee/models/user.dart';
import 'package:Bungee/pages/home.dart';
import 'package:Bungee/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Post extends StatefulWidget {
  final String description;
  final String mediaUrl;
  final String location;
  final String ownerId;
  final String postId;
  final String username;
  final dynamic likes;

  Post({
    this.description,
    this.mediaUrl,
    this.location,
    this.ownerId,
    this.postId,
    this.username,
    this.likes,
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      description: doc['description'],
      mediaUrl: doc['mediaUrl'],
      location: doc['location'],
      ownerId: doc['ownerId'],
      postId: doc['postId'],
      username: doc['username'],
      likes: doc['likes'],
    );
  }

  int getLikesCount(likes) {
    if (likes = null) {
      return 0;
    }
    int count = 0;
    likes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });

    return count;
  }

  @override
  _PostState createState() => _PostState(
        description: this.description,
        mediaUrl: this.mediaUrl,
        location: this.location,
        ownerId: this.ownerId,
        postId: this.postId,
        username: this.username,
        likes: this.likes,
        likeCount: this.getLikesCount(this.likes),
      );
}

class _PostState extends State<Post> {
  final String description;
  final String mediaUrl;
  final String location;
  final String ownerId;
  final String postId;
  final String username;
  int likeCount;
  Map likes;

  _PostState({
    this.description,
    this.mediaUrl,
    this.location,
    this.ownerId,
    this.postId,
    this.username,
    this.likes,
    this.likeCount,
  });

  buildPostHeader() {
    return FutureBuilder(
      future: userRef.doc(ownerId).get(),
      builder: (context, snapshot) {
        // if (!snapshot.hasData) {
        //   return circularProgress();
        // }
        User user = User.fromDocument(snapshot.data);

        return ListTile(
          leading: CircleAvatar(
            radius: 20,
            backgroundImage: CachedNetworkImageProvider(user.photoUrl),
            backgroundColor: Colors.grey,
          ),
          title: GestureDetector(
            onTap: () => print('open Profile'),
            child: Text(
              user.username,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          subtitle: Text(location),
          trailing: Icon(
            Icons.more_vert,
            size: 10,
          ),
        );
      },
    );
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: () => print('like the image'),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Image.network(
            mediaUrl,
            height: 300,
          )
        ],
      ),
    );
  }

  buildPostTile() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Row(
          children: [
            Padding(padding: EdgeInsets.only(top: 40, left: 20)),
            GestureDetector(
              onTap: () => print('liked'),
              child: Icon(
                Icons.favorite_border,
                size: 28,
                color: Colors.pink,
              ),
            ),
            Padding(padding: EdgeInsets.only(right: 20)),
            GestureDetector(
              onTap: () => print('showing comments'),
              child: Icon(
                Icons.chat,
                size: 28,
                color: Colors.blue[900],
              ),
            ),
          ],
        ),
        Row(children: [
          Container(
            height: 20,
            margin: EdgeInsets.only(left: 20),
            child: Text(
              '$likeCount likes',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ]),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 20,
              margin: EdgeInsets.only(left: 20),
              child: Text(
                '$username',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Text(
                description,
              ),
            )
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostHeader(),
        buildPostImage(),
        buildPostTile(),
      ],
    );
  }
}
