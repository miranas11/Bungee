import 'package:Bungee/models/user.dart';
import 'package:Bungee/pages/home.dart';
import 'package:Bungee/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> searchResultsFuture;

  searchUsers(String query) {
    Future<QuerySnapshot> searchusers = userRef
        .where(
          'display_name',
          isGreaterThanOrEqualTo: query,
        )
        .get();
    setState(() {
      searchResultsFuture = searchusers;
    });
  }

  AppBar searchbar() {
    return AppBar(
      elevation: 1,
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: searchController,
        onFieldSubmitted: searchUsers,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: 'Search...',
          prefixIcon: Icon(
            Icons.account_box,
            size: 28,
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () => searchController.clear(),
          ),
        ),
      ),
    );
  }

  buildSearchResults() {
    return FutureBuilder(
      future: searchResultsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<UserResult> searchResults = [];
        for (var users in snapshot.data.docs) {
          User user = User.fromDocument(users);
          UserResult searchUser = UserResult(user);
          searchResults.add(searchUser);
        }
        return ListView(
          children: searchResults,
        );
      },
    );
  }

  Container noContentScreen() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/search.svg',
              height: orientation == Orientation.portrait ? 300 : 200,
            ),
            Text(
              'Find Users',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 30,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: searchbar(),
      body: searchResultsFuture == null
          ? noContentScreen()
          : buildSearchResults(),
    );
  }
}

class UserResult extends StatelessWidget {
  final User user;
  UserResult(this.user);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => print(user.email),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            backgroundImage: CachedNetworkImageProvider(user.photoUrl),
          ),
          title: Text(
            user.displayName,
            style: TextStyle(),
          ),
          subtitle: Text(user.username),
        ),
      ),
    );
  }
}
