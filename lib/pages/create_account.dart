import 'package:Bungee/widgets/header.dart';
import 'package:flutter/material.dart';

class CreateAccount extends StatefulWidget {
  static const String id = 'create_account';
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  String username;
  TextEditingController _controller = TextEditingController();

  usernameConfirmation() {
    if (username.length < 3 || username.length > 13) {
      return;
    } else {
      Navigator.pop(context, username);
    }
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      appBar: header(context, title: 'Create Account'),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Center(
              child: Text(
                'Enter a Username',
                style: TextStyle(fontSize: 25),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: TextFormField(
              autovalidate: true,
              validator: (value) {
                if (value.trim().length < 3 || value.isEmpty) {
                  return 'username too short';
                } else if (value.trim().length > 13) {
                  return 'username too long';
                } else {
                  return null;
                }
              },
              controller: _controller,
              onChanged: (value) {
                username = value;
              },
              decoration: InputDecoration(
                hintText: 'should be atleast 3 character long',
                labelText: 'username',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => usernameConfirmation(),
            child: Container(
              alignment: Alignment.center,
              width: 300,
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                'Submit',
                style: TextStyle(fontSize: 20),
              ),
            ),
          )
        ],
      ),
    );
  }
}
