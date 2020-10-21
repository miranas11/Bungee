import 'package:Bungee/models/user.dart';
import 'package:Bungee/pages/edit_profile.dart';
import 'package:Bungee/widgets/header.dart';
import 'package:Bungee/widgets/post.dart';
import 'package:Bungee/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'home.dart';

class Profile extends StatefulWidget {
  final String profileID;

  Profile({this.profileID});
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final String currentUserId = currentUser?.id;
  bool isLoading = false;
  List<Post> posts = [];
  int postCount = 0;

  @override
  void initState() {
    super.initState();
    getProfilePosts();
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });

    QuerySnapshot snapshot = await postref
        .doc(widget.profileID)
        .collection('userposts')
        .orderBy('timestamp', descending: true)
        .get();

    setState(() {
      isLoading = false;
      posts = snapshot.docs.map((e) => Post.fromDocument(e)).toList();
      postCount = snapshot.docs.length;
    });
  }

  buildCountColumn(String label, int count) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        )
      ],
    );
  }

  Container buildButton(String text, Function function) {
    return Container(
      height: 30,
      width: 240,
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.blue),
      ),
      child: FlatButton(
        onPressed: function,
        child: Text(
          text,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  buildProfileButton() {
    bool isProfileOwner = currentUserId == widget.profileID;
    if (isProfileOwner) {
      return buildButton(
        'Edit Profile',
        () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditProfile(
              currentUserId: widget.profileID,
            ),
          ),
        ),
      );
    }
  }

  buildProfileHeader() {
    return FutureBuilder(
      future: userRef.doc(widget.profileID).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User profileuser = User.fromDocument(snapshot.data);
        return Padding(
          padding: EdgeInsets.all(19),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundImage:
                        CachedNetworkImageProvider(profileuser.photoUrl),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            buildCountColumn('posts', 0),
                            buildCountColumn('following', 0),
                            buildCountColumn('followers', 0),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [buildProfileButton()],
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                child: Text(
                  profileuser.username,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 5),
                child: Text(
                  profileuser.displayName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 2),
                child: Text(
                  profileuser.bio,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  buildProfilePosts() {
    if (isLoading) {
      return circularProgress();
    }
    return Column(
      children: posts,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, title: 'Profile'),
      body: ListView(
        children: <Widget>[
          buildProfileHeader(),
          Divider(
            height: 0,
          ),
          buildProfilePosts(),
        ],
      ),
    );
  }
}
