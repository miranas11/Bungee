import 'package:Bungee/models/user.dart';
import 'package:Bungee/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'home.dart';

class EditProfile extends StatefulWidget {
  static const String id = 'edit_profile';
  final String currentUserId;

  EditProfile({this.currentUserId});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  User user;
  bool isLoading = false;
  bool _bioValid = true;
  bool _displayNameValid = true;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await userRef.doc(widget.currentUserId).get();
    user = User.fromDocument(doc);
    displayNameController.text = user.displayName;
    bioController.text = user.bio;
    setState(() {
      isLoading = false;
    });
  }

  updateProfile() async {
    setState(() {
      displayNameController.text.trim().length < 3
          ? _displayNameValid = false
          : _displayNameValid = true;
      bioController.text.length > 40 ? _bioValid = false : _bioValid = true;
    });
    if (_bioValid && _displayNameValid) {
      await userRef.doc(widget.currentUserId).update({
        'bio': bioController.text,
        'display_name': displayNameController.text,
      });
    }
    SnackBar snackBar = SnackBar(content: Text('Profile Updated!'));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  Column buildEditField(
      {String text, TextEditingController controller, String errorText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            errorText: errorText,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Theme.of(context).accentColor,
        automaticallyImplyLeading: false,
        title: Center(
          child: Text('Edit Profile'),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.done,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: isLoading
          ? circularProgress()
          : ListView(
              children: <Widget>[
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: CircleAvatar(
                        radius: 80,
                        backgroundImage:
                            CachedNetworkImageProvider(user.photoUrl),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildEditField(
                            controller: displayNameController,
                            text: 'Display',
                            errorText: _displayNameValid
                                ? null
                                : 'Display Name too short',
                          ),
                          buildEditField(
                            controller: bioController,
                            text: 'Bio',
                            errorText: _bioValid ? null : 'bio too long',
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Center(
                            heightFactor: 1.5,
                            child: RaisedButton(
                              child: Text(
                                'Update Profile',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                              color: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              onPressed: updateProfile,
                            ),
                          ),
                          Center(
                            child: FlatButton.icon(
                              icon: Icon(
                                Icons.cancel,
                                color: Colors.redAccent,
                              ),
                              onPressed: () {
                                googleSignIn.signOut();
                                Navigator.pushNamed(context, Home.id);
                              },
                              label: Text(
                                'Logout',
                                style:
                                    TextStyle(color: Colors.red, fontSize: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
    );
  }
}
