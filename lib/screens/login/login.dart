// import 'package:book_club/screens/login/localwidgets/loginform.dart';
// import 'package:flutter/material.dart';

// class OurLogin extends StatelessWidget {
//   const OurLogin({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Expanded(
//             child: ListView(
//               padding: const EdgeInsets.all(20.0),
//               children: <Widget>[
//                 Padding(
//                   padding: const EdgeInsets.all(40.0),
//                   child: Image.asset("assets/logo.png"),
//                 ),
//                 const SizedBox(
//                   height: 20.0,
//                 ),
//                 const OurLoginForm(),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:book_club/screens/login/forgetPassword.dart';
import 'package:book_club/screens/login/localwidgets/loginform.dart';
import 'package:flutter/material.dart';

class OurLogin extends StatelessWidget {
  const OurLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20.0),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Image.asset("assets/logo.png"),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                const OurLoginForm(),
                const SizedBox(
                  height: 10.0,
                ),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: const Text("Forgot Password?"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
