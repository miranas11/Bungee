import 'package:Bungee/models/user.dart';
import 'package:Bungee/pages/edit_profile.dart';
import 'package:Bungee/widgets/header.dart';
import 'package:Bungee/widgets/post.dart';
import 'package:Bungee/widgets/post_tile.dart';
import 'package:Bungee/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'home.dart';

class Profile extends StatefulWidget {
  final String profileID;

  Profile({this.profileID});
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isFollowing = false;
  final String currentUserId = currentUser?.id;
  bool isLoading = false;
  List<Post> posts = [];
  List<GridTile> posttiles = [];
  int postCount = 0;
  String postOrientation = 'grid';

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
    posts.forEach((post) {
      GridTile tile = GridTile(
        child: PostTile(post: post),
      );
      posttiles.add(tile);
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
        color: isFollowing ? Colors.black54 : Colors.blueAccent,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: isFollowing ? Colors.grey : Colors.blue),
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

  unfollowUser() {
    setState(() {
      isFollowing = false;
    });

    //remove that user on your folowing collection
    followingref
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(widget.profileID)
        .get()
        .then((value) => value.reference.delete());

    //remove you on other users followers collection
    followersref
        .doc(widget.profileID)
        .collection('userFollowers')
        .doc(currentUserId)
        .get()
        .then((value) => value.reference.delete());

    //remove to activity feed of the user who is followed

    activityfeedref
        .doc(widget.profileID)
        .collection('feeditems')
        .doc(currentUserId)
        .get()
        .then((value) => value.reference.delete());
  }

  followUser() {
    setState(() {
      isFollowing = true;
    });

    //put that user on your folowing collection
    followingref
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(widget.profileID)
        .set({});

    //put you on other users followers collection
    followersref
        .doc(widget.profileID)
        .collection('userFollowers')
        .doc(currentUserId)
        .set({});

    //add to activity feed of the user who is followed

    activityfeedref
        .doc(widget.profileID)
        .collection('feeditems')
        .doc(currentUserId)
        .set({
      'mediaUrl': '',
      'comment': '',
      'postId': '',
      'timestamp': timestamp,
      'type': 'follow',
      'userId': currentUser.id,
      'userProfileImg': currentUser.photoUrl,
      'username': currentUser.username,
    });
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
    } else if (isFollowing) {
      return buildButton('Unfollow', unfollowUser);
    } else if (!isFollowing) {
      return buildButton('Follow', followUser);
    }
  }

  buildProfileHeader() {
    return FutureBuilder(
      future: userRef.doc(widget.profileID).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
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
                            buildCountColumn('posts', postCount),
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

  Row buildTogglePostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          iconSize: 25,
          icon: Icon(Icons.grid_on),
          color: postOrientation == 'grid'
              ? Theme.of(context).primaryColor
              : Colors.grey,
          onPressed: () {
            setState(() {
              postOrientation = 'grid';
            });
          },
        ),
        IconButton(
          iconSize: 25,
          icon: Icon(Icons.list),
          color: postOrientation == 'list'
              ? Theme.of(context).primaryColor
              : Colors.grey,
          onPressed: () {
            setState(() {
              postOrientation = 'list';
            });
          },
        ),
      ],
    );
  }

  buildProfilePosts() {
    if (isLoading) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/no_content.svg',
              height: MediaQuery.of(context).size.height * 0.2,
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              'No Content',
              style: TextStyle(
                color: Colors.black,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else if (postOrientation == 'grid') {
      return GridView.count(
        childAspectRatio: 1.0,
        crossAxisCount: 3,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        children: posttiles,
      );
    } else if (postOrientation == 'list') {
      return Column(
        children: posts,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, title: 'Profile'),
      body: isLoading
          ? circularProgress()
          : ListView(
              children: <Widget>[
                buildProfileHeader(),
                Divider(
                  height: 0,
                ),
                buildTogglePostOrientation(),
                Divider(
                  height: 0,
                ),
                buildProfilePosts(),
              ],
            ),
    );
  }
}
