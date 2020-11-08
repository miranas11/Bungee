import 'package:Bungee/widgets/header.dart';
import 'package:Bungee/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'home.dart';
import 'package:timeago/timeago.dart' as timeago;

class Comments extends StatefulWidget {
  final String postOwnerId;
  final String postId;
  final String mediaUrl;

  Comments({
    this.postId,
    this.mediaUrl,
    this.postOwnerId,
  });
  @override
  CommentsState createState() => CommentsState(
      postId: this.postId,
      mediaUrl: this.mediaUrl,
      postOwnerId: this.postOwnerId);
}

class CommentsState extends State<Comments> {
  final TextEditingController commentsController = TextEditingController();
  final String postId;
  final String mediaUrl;
  final String postOwnerId;

  CommentsState({
    this.postId,
    this.postOwnerId,
    this.mediaUrl,
  });

  buildComments() {
    return StreamBuilder(
      stream: commentsref
          .doc(postId)
          .collection('comments')
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }

        List<Comment> allcomments = [];
        snapshot.data.docs.forEach((doc) {
          allcomments.add(Comment.fromDocument(doc));
        });

        return ListView(
          children: allcomments,
        );
      },
    );
  }

  addcommenttoactivityfeed() {
    // if (currentUser.id == postOwnerId) {
    //   return;
    // }
    activityfeedref.doc(postOwnerId).collection('feeditems').add({
      'mediaUrl': mediaUrl,
      'comment': commentsController.text,
      'postId': postId,
      'timestamp': timestamp,
      'type': 'comment',
      'userId': currentUser.id,
      'userProfileImg': currentUser.photoUrl,
      'username': currentUser.username,
    });
  }

  addComments() {
    commentsref.doc(postId).collection('comments').add({
      'username': currentUser.username,
      'comment': commentsController.text,
      'timestamp': timestamp,
      'avatarUrl': currentUser.photoUrl,
      'userId': currentUser.id,
    });
    addcommenttoactivityfeed();
    commentsController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, title: 'Comments'),
      body: Column(
        children: <Widget>[
          Expanded(
            child: buildComments(),
          ),
          Divider(
            height: 1,
          ),
          ListTile(
            title: TextFormField(
              controller: commentsController,
              decoration: InputDecoration(labelText: 'Enter a comment'),
            ),
            trailing: OutlineButton(
              borderSide: BorderSide.none,
              onPressed: () => addComments(),
              child: Text('Post'),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 3),
          )
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String avatarUrl;
  final String comment;
  final Timestamp timestamp;

  Comment({
    this.username,
    this.userId,
    this.avatarUrl,
    this.comment,
    this.timestamp,
  });

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      userId: doc['userId'],
      username: doc['username'],
      avatarUrl: doc['avatarUrl'],
      comment: doc['comment'],
      timestamp: doc['timestamp'],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          visualDensity: VisualDensity(vertical: -2),
          dense: true,
          title: Row(
            children: [
              Text(
                username,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                comment,
                style: TextStyle(fontSize: 14),
                maxLines: 3,
                overflow: TextOverflow.clip,
              )
            ],
          ),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(avatarUrl),
          ),
          subtitle: Text(
            timeago.format(timestamp.toDate()),
            style: TextStyle(fontSize: 10),
          ),
        ),
      ],
    );
  }
}
