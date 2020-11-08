import 'package:Bungee/pages/home.dart';
import 'package:Bungee/pages/post_screen.dart';
import 'package:Bungee/pages/profile.dart';
import 'package:Bungee/widgets/header.dart';
import 'package:Bungee/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timesago;

class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  getActivityFeed() async {
    QuerySnapshot snapshot = await activityfeedref
        .doc(currentUser.id)
        .collection('feeditems')
        .orderBy('timestamp', descending: true)
        .get();
    List<ActivityFeedItem> feedItems = [];
    snapshot.docs.forEach((doc) {
      feedItems.add(ActivityFeedItem.fromDocument(doc));
    });
    return feedItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, title: 'Activity Feed', removebackButton: true),
      body: Container(
        child: FutureBuilder(
          future: getActivityFeed(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return circularProgress();
            }
            return ListView(
              children: snapshot.data,
            );
          },
        ),
      ),
    );
  }
}

Widget mediaPreview;
String activityItemText;

class ActivityFeedItem extends StatelessWidget {
  final String type;
  final String medialUrl;
  final String postId;
  final Timestamp timestamp;
  final String comment;
  final String userId;
  final String userProfileImg;
  final String username;

  ActivityFeedItem(
      {this.medialUrl,
      this.type,
      this.postId,
      this.timestamp,
      this.comment,
      this.userId,
      this.userProfileImg,
      this.username});

  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc) {
    return ActivityFeedItem(
      type: doc['type'],
      medialUrl: doc['mediaUrl'],
      postId: doc['postId'],
      timestamp: doc['timestamp'],
      comment: doc['comment'],
      userId: doc['userId'],
      userProfileImg: doc['userProfileImg'],
      username: doc['username'],
    );
  }

  showProfile(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Profile(
          profileID: userId,
        ),
      ),
    );
  }

  showPost(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostScreen(
          postId: postId,
          userId: userId,
        ),
      ),
    );
  }

  configuremediaPreview(context) {
    if (type == 'comment' || type == 'like') {
      mediaPreview = GestureDetector(
        onTap: () => showPost(context),
        child: Container(
          height: 50,
          width: 50,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider(medialUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      mediaPreview = Text('');
    }

    if (type == 'like') {
      activityItemText = 'liked your Post';
    } else if (type == 'comment') {
      activityItemText = 'replied $comment';
    } else if (type == 'follow') {
      activityItemText = 'is following you';
    } else {
      activityItemText = 'Error type not found';
    }
  }

  @override
  Widget build(BuildContext context) {
    configuremediaPreview(context);
    return Container(
      color: Colors.white,
      child: ListTile(
        dense: true,
        title: GestureDetector(
          onTap: () => showProfile(context),
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 14, color: Colors.black),
              children: [
                TextSpan(
                  text: username,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: '  $activityItemText'),
              ],
            ),
          ),
        ),
        subtitle: Text(
          timesago.format(timestamp.toDate()),
          overflow: TextOverflow.ellipsis,
        ),
        leading: CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(userProfileImg),
        ),
        trailing: mediaPreview,
      ),
    );
  }
}
