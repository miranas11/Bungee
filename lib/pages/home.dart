import 'package:Bungee/models/user.dart';
import 'package:Bungee/pages/activity_feed.dart';
import 'package:Bungee/pages/create_account.dart';
import 'package:Bungee/pages/profile.dart';
import 'package:Bungee/pages/search.dart';
import 'package:Bungee/pages/timeline.dart';
import 'package:Bungee/pages/upload.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final userRef = FirebaseFirestore.instance.collection('users');
final postref = FirebaseFirestore.instance.collection('posts');
final StorageReference storageref = FirebaseStorage.instance.ref();
final DateTime timestamp = DateTime.now();
User currentUser;

class Home extends StatefulWidget {
  static const id = 'home';
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;
  PageController pageController;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    //sign in for first time
    googleSignIn.onCurrentUserChanged.listen(
      (account) {
        handleSignIn(account);
      },
      onError: (error) {
        print(error);
      },
    );
    //reauthenticate sign in when app restart
    googleSignIn.signInSilently(suppressErrors: false).then(
      (account) {
        handleSignIn(account);
      },
      onError: (error) {
        print(error);
      },
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  handleSignIn(GoogleSignInAccount account) {
    if (account != null) {
      createUserinFireStore();
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  createUserinFireStore() async {
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot userdoc = await userRef.doc(user.id).get();

    if (!userdoc.exists) {
      final username = await Navigator.pushNamed(context, CreateAccount.id);

      if (username != null) {
        userRef.doc(user.id).set(
          {
            'id': user.id,
            'email': user.email,
            'photo_url': user.photoUrl,
            'username': username,
            'display_name': user.displayName,
            'bio': '',
            'time_stamp': timestamp,
          },
        );

        userdoc = await userRef.doc(user.id).get();
      }
    }
    currentUser = User.fromDocument(userdoc);
  }

  login() {
    googleSignIn.signIn();
  }

  logout() {
    googleSignIn.signOut();
  }

  onPageChanged(int newIndex) {
    setState(() {
      this.pageIndex = newIndex;
    });
  }

  onNavTap(int pageindex) {
    pageController.animateToPage(
      pageindex,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Scaffold buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).accentColor,
              Theme.of(context).primaryColor,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Bungee',
              style: TextStyle(
                  fontFamily: 'Signatra', fontSize: 80, color: Colors.white),
            ),
            SizedBox(
              height: 30,
            ),
            GestureDetector(
              onTap: login,
              child: Container(
                height: 50,
                width: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('assets/images/google_signin_button.png'),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Scaffold buildAuthScreen() {
    return Scaffold(
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        children: [
          Timeline(),
          ActivityFeed(),
          Upload(currentUser: currentUser),
          Search(),
          Profile(
            profileID: currentUser?.id,
          ),
        ],
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onNavTap,
        activeColor: Theme.of(context).primaryColor,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.whatshot)),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_active)),
          BottomNavigationBarItem(icon: Icon(Icons.photo_camera, size: 35)),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
