import 'package:book_club/screens/Admin/AdminHome.dart';

import 'package:book_club/screens/root/root.dart';
import 'package:book_club/screens/signup/signup.dart';
import 'package:book_club/states/currentUser.dart';
import 'package:book_club/widgets/ourcontainer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum LoginType { email, google }

class OurLoginForm extends StatefulWidget {
  const OurLoginForm({super.key});

  @override
  State<OurLoginForm> createState() => _OurLoginFormState();
}

class _OurLoginFormState extends State<OurLoginForm> {
  void _loginUser(LoginType type,
      {String? email, String? password, required BuildContext context}) async {
    CurrentUser currentUser = Provider.of<CurrentUser>(context, listen: false);

    try {
      String retString = "";

      switch (type) {
        case LoginType.email:
          retString = await currentUser.loginUserWithEmail(email!, password!);
          break;
        case LoginType.google:
          retString = await currentUser.loginUserWithGoogle();
          break;
        default:
      }

      if (retString == "admin") {
        // Redirect admin to the Admin Dashboard with pushReplacement
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AdminHomePage()),
        );
      } else if (retString == "success") {
        // Redirect normal user to the User Dashboard with pushReplacement
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => OurRoot()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              retString,
              textAlign: TextAlign.center,
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  Widget _googleButton() {
    return OutlinedButton(
      onPressed: () {
        _loginUser(LoginType.google, context: context);
      },
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        side: const BorderSide(color: Colors.grey),
      ),
      child: const Padding(
        padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(image: AssetImage("assets/google_logo.png"), height: 25.0),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                'Sign in with Google',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OurContainer(
      child: Column(
        children: <Widget>[
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 8.0),
            child: Text(
              "Login",
              style: TextStyle(
                color: Theme.of(context).secondaryHeaderColor,
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.alternate_email),
              hintText: "Email",
            ),
          ),
          const SizedBox(
            height: 20.0,
          ),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.lock_outline),
              hintText: "Password",
            ),
            obscureText: true,
          ),
          const SizedBox(
            height: 20.0,
          ),
          ElevatedButton(
            onPressed: () {
              _loginUser(LoginType.email,
                  email: _emailController.text,
                  password: _passwordController.text,
                  context: context);
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 100),
              child: Text(
                "Login",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OurSignUp(),
                ),
              );
            },
            child: const Text("Dont have an account? SignUp Here"),
          ),
          _googleButton()
        ],
      ),
    );
  }
}
