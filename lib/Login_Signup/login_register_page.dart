import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'Forget_Pass.dart';
import 'home_page.dart';
import 'personal_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool isLogin = true;

  bool passwordVisible = false;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _controllerEmail.text, password: _controllerPassword.text);
      navigateToHomePage();
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No user found for that email.';
            break;
          case 'wrong-password':
            errorMessage = 'Wrong password provided.';
            break;
          default:
            errorMessage = 'An error occurred. Please try again.';
        }
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _controllerEmail.text, password: _controllerPassword.text);
      //navigateToPersonalData(); // Navigate to PersonalData after registration
      signInWithEmailAndPassword();
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'The email address is already in use.';
            break;
          case 'weak-password':
            errorMessage = 'The password is too weak.';
            break;
          default:
            errorMessage = 'An error occurred. Please try again.';
        }
      });
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await GoogleSignIn().signOut(); // Ensure previous session is signed out

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() {
          errorMessage = 'Google sign-in was canceled.';
        });
        return;
      }

      final GoogleSignInAuthentication? googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Extract user information
      User? user = userCredential.user;
      if (user != null) {
        // Update Firestore with user data
        await FirebaseFirestore.instance
            .collection('Personals')
            .doc(user.uid)
            .set(
                {
              'uid': user.uid,
              'name': user.displayName ?? '',
              'email': user.email ?? '',
              /*'photoURL': user.photoURL ?? '',
              'lastSignInTime':
                  user.metadata.lastSignInTime?.toIso8601String() ?? '',*/
            },
                SetOptions(
                    merge:
                        true)); // Use merge to avoid overwriting existing data
      }

      //navigateToDataViewing();
      navigateToHomePage();
    } catch (e) {
      setState(() {
        errorMessage =
            'An error occurred during Google sign-in. Please try again.';
      });
    }
  }

  void navigateToHomePage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  void navigateToPersonalData() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => PersonalData()),
    );
  }

  void navigateToDataViewing() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => PersonalData()),
    );
  }

  Widget _entryField(String title, TextEditingController controller,
      TextInputType type, bool isPassword) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? !passwordVisible : false,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: title,
        labelStyle: TextStyle(color: Colors.black),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 2.0),
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 2.0),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      onEditingComplete: () => FocusScope.of(context).nextFocus(),
    );
  }

  Widget _errorMessage() {
    return Text(
      errorMessage == '' ? '' : errorMessage!,
      style: TextStyle(color: Colors.black),
    );
  }

  Widget _submitButton() {
    return IconButton(
      onPressed:
          isLogin ? signInWithEmailAndPassword : createUserWithEmailAndPassword,
      icon: Image.asset(
        isLogin
            ? 'assets/images/login_icon.png'
            : 'assets/images/register_icon.png',
        width: 50,
        height: 50,
      ),
      /*child: Text(
        isLogin ? 'Login' : 'Register',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),*/
    );
  }

  Widget _googleSignInButton() {
    return IconButton(
      icon: Image.asset(
        'assets/images/Google_logo.png',
        width: 50,
        height: 50,
      ),
      iconSize: 5,
      onPressed: () {
        signInWithGoogle();
      },
    );
  }

  //'assets/images/Google_logo.png'
  Widget _loginOrRegisterButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          isLogin = !isLogin;
          errorMessage = ''; // Clear the error message when switching modes
        });
      },
      child: Text(
        isLogin
            ? 'Don\'t have an Account? Register..'
            : 'Having an Account? Login..',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFB9DC78),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 200,
                  width: double.infinity,
                  child: Image.asset(
                    "assets/gif/food-health.gif",
                    height: 200.0,
                    width: 200.0,
                    fit: BoxFit.contain,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _entryField('Email', _controllerEmail,
                          TextInputType.emailAddress, false),
                      SizedBox(height: 15),
                      _entryField('Password', _controllerPassword,
                          TextInputType.visiblePassword, true),
                      _errorMessage(),
                      SizedBox(height: 15),
                      _submitButton(),
                      _loginOrRegisterButton(),
                      _googleSignInButton(),
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ForgetPass()),
                            );
                          },
                          child: Text(
                            'Forgot Password',
                            style: TextStyle(color: Colors.indigo),
                          ))
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
