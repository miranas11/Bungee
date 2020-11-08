import 'dart:async';

import 'package:Bungee/models/user.dart';
import 'package:Bungee/pages/comments.dart';
import 'package:Bungee/pages/home.dart';
import 'package:Bungee/pages/profile.dart';
import 'package:Bungee/widgets/custom_image.dart';
import 'package:animator/animator.dart';
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
    if (likes == null) {
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
  final String currentUserId = currentUser?.id;
  final String description;
  final String mediaUrl;
  final String location;
  final String ownerId;
  final String postId;
  final String username;
  int likeCount;
  Map likes;

  bool isLiked;
  bool showHeart = false;

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

  showProfile(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Profile(
          profileID: ownerId,
        ),
      ),
    );
  }

  buildPostHeader() {
    return FutureBuilder(
      future: userRef.doc(ownerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }
        User user = User.fromDocument(snapshot.data);

        return ListTile(
          leading: CircleAvatar(
            radius: 20,
            backgroundImage: CachedNetworkImageProvider(user.photoUrl),
            backgroundColor: Colors.grey,
          ),
          title: GestureDetector(
            onTap: () => showProfile(context),
            child: Text(
              user.username,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          subtitle: Text(location),
          trailing: Icon(
            Icons.more_vert,
            size: 25,
          ),
        );
      },
    );
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: handleLikes,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          cachedNetworkImage(mediaUrl),
          showHeart == true
              ? Animator(
                  tween: Tween(begin: 0.8, end: 1.4),
                  duration: Duration(milliseconds: 300),
                  curve: Curves.elasticOut,
                  cycles: 0,
                  builder: (context, animatorState, child) => Center(
                    child: Transform.scale(
                      scale: animatorState.value,
                      child: Icon(
                        Icons.favorite,
                        size: 50,
                        color: Colors.red[300],
                      ),
                    ),
                  ),
                )
              : Text(''),
        ],
      ),
    );
  }

  addliketoactivityfeed() {
    // if (currentUserId == ownerId) {
    //   return;
    // }
    activityfeedref.doc(ownerId).collection('feeditems').doc(postId).set({
      'comment': '',
      'mediaUrl': mediaUrl,
      'postId': postId,
      'timestamp': timestamp,
      'type': 'like',
      'userId': currentUserId,
      'userProfileImg': currentUser.photoUrl,
      'username': currentUser.username,
    });
  }

  removelikefromactivityfeed() {
    if (currentUserId == ownerId) {
      return;
    }
    activityfeedref
        .doc(ownerId)
        .collection('feeditems')
        .doc(postId)
        .get()
        .then((value) {
      if (value.exists) {
        value.reference.delete();
      }
    });
  }

  handleLikes() {
    bool _isLiked = likes[currentUserId] == true;

    if (_isLiked) {
      postref.doc(ownerId).collection('userposts').doc(postId).update({
        'likes.$currentUserId': false,
      });
      removelikefromactivityfeed();
      setState(() {
        likeCount -= 1;
        isLiked = false;
        likes[currentUserId] = false;
      });
    } else if (!_isLiked) {
      postref.doc(ownerId).collection('userposts').doc(postId).update({
        'likes.$currentUserId': true,
      });

      addliketoactivityfeed();
      setState(() {
        likeCount += 1;
        isLiked = true;
        likes[currentUserId] = true;
        showHeart = true;
      });

      Timer(Duration(milliseconds: 500), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  buildPostTile() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Row(
          children: [
            Padding(padding: EdgeInsets.only(top: 40, left: 20, bottom: 0)),
            GestureDetector(
              onTap: handleLikes,
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                size: 28,
                color: Colors.pink,
              ),
            ),
            Padding(padding: EdgeInsets.only(right: 20)),
            GestureDetector(
              onTap: () => showComments(context,
                  postId: postId, postOwnerId: ownerId, mediaUrl: mediaUrl),
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
            Padding(
              padding: EdgeInsets.only(right: 5),
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
    isLiked = likes[currentUserId] == true;
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

showComments(BuildContext context,
    {String postOwnerId, String postId, String mediaUrl}) {
  return Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        return Comments(
          postId: postId,
          mediaUrl: mediaUrl,
          postOwnerId: postOwnerId,
        );
      },
    ),
  );
}
