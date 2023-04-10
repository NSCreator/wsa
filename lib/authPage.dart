import 'dart:async';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wsa/profilePage.dart';

import 'homePage.dart';
import 'main.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordController_X = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            color:Colors.grey[400],
            image: const DecorationImage(image: NetworkImage("https://firebasestorage.googleapis.com/v0/b/e-srkr.appspot.com/o/auth_page%2F315537679.jpg?alt=media&token=e2e3c4f9-a19f-4593-b193-533196b48b0b"),
                fit: BoxFit.fill)
        ),
        child: Container(
          color: Colors.black.withOpacity(0.8),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: const [
                            Padding(
                              padding: EdgeInsets.only(top: 25,bottom: 5),
                              child: SizedBox(
                                  height: 200,
                                  width: 200,
                            ),),
                            Text(
                              "WSA",
                              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,color: Colors.deepOrange),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Welcome Back!",
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white54,
                              border: Border.all(color: Colors.white.withOpacity(0.8)),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: TextField(
                                controller: emailController,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Email',
                                ),
                              ),
                            ),
                          ),
                        ),
                        //password
                        const SizedBox(
                          height: 5,
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white54,
                              border: Border.all(color: Colors.white.withOpacity(0.8)),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: TextField(
                                obscureText: true,
                                controller: passwordController,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Password',
                                ),
                              ),
                            ),
                          ),
                        ),
                        //sign in button
                        const SizedBox(
                          height: 10,
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 100),
                          child: InkWell(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                  child: Text(
                                    "Sign In",
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                                  )),
                            ),
                            onTap: () async {
                              showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => const Center(
                                    child: CircularProgressIndicator(),
                                  ));
                              try {
                                await FirebaseAuth.instance.signInWithEmailAndPassword( email: emailController.text.trim().toLowerCase(), password: passwordController.text.trim());
                                Navigator.pop(context);
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MyApp()));
                              } on FirebaseException catch (e) {
                                print(e);
                                Utils.showSnackBar(e.message);
                              }


                            },
                          ),
                        ),

                        const SizedBox(
                          height: 20,
                        ),
                        InkWell(
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  backgroundColor: Colors.black.withOpacity(0.3),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  elevation: 16,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.tealAccent),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: ListView(
                                      shrinkWrap: true,
                                      children: <Widget>[
                                        const Padding(
                                          padding: EdgeInsets.all(10.0),
                                          child: Text(
                                            'Reset Password',
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 20),
                                          ),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text("Ends with @gmail.com can Reset Password", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15),),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 5,right: 5),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              border: Border.all(color: Colors.white),
                                              borderRadius: BorderRadius.circular(14),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 20),
                                              child: TextFormField(
                                                controller: emailController,
                                                textInputAction: TextInputAction.next,
                                                decoration: const InputDecoration(
                                                  border: InputBorder.none,
                                                  hintText: 'Email',
                                                ),
                                                validator: (email) => email != null && !EmailValidator.validate(email) ? "Enter a valid Email" : null,
                                              ),
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            resetPassword();
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.only(right: 15),
                                            child: Text('Reset'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );

                          },
                        ),
                        const SizedBox(height: 10,),

                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Not a Member?",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400,color: Colors.white),
                            ),
                            InkWell(
                              child: const Text(
                                " Register",
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.cyan),
                              ),
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        scrollable: true,
                                        backgroundColor: Colors.grey[100],
                                        title: const Text(
                                          'Create Account',
                                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 18),
                                        ),
                                        content: Padding(
                                          padding: const EdgeInsets.all(1.0),
                                          child: Form(
                                            key: formKey,
                                            child: Column(
                                              children: <Widget>[
                                                const Text("Register with college email Id"),
                                                const SizedBox(
                                                  height: 15,
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[200],
                                                    border: Border.all(color: Colors.white),
                                                    borderRadius: BorderRadius.circular(14),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left: 20),
                                                    child: TextFormField(
                                                      controller: emailController,
                                                      textInputAction: TextInputAction.next,
                                                      decoration: const InputDecoration(
                                                        border: InputBorder.none,
                                                        hintText: 'Email',
                                                      ),
                                                      validator: (email) => email != null && !EmailValidator.validate(email) ? "Enter a valid Email" : null,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[200],
                                                    border: Border.all(color: Colors.white),
                                                    borderRadius: BorderRadius.circular(14),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left: 20),
                                                    child: TextFormField(
                                                      obscureText: true,
                                                      controller: passwordController,
                                                      textInputAction: TextInputAction.next,
                                                      decoration: const InputDecoration(
                                                        border: InputBorder.none,
                                                        hintText: 'Password',
                                                      ),
                                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                                      validator: (value) => value != null && value.length < 6 ? "Enter min. 6 characters" : null,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[200],
                                                    border: Border.all(color: Colors.white),
                                                    borderRadius: BorderRadius.circular(14),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left: 20),
                                                    child: TextFormField(
                                                      obscureText: true,
                                                      controller: passwordController_X,
                                                      textInputAction: TextInputAction.next,
                                                      decoration: const InputDecoration(
                                                        border: InputBorder.none,
                                                        hintText: 'Conform Password',
                                                      ),
                                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                                      validator: (value) => value != null && value.length < 6 ? "Enter min. 6 characters" : null,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.only(right: 15),
                                              child: Text('cancel '),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: (){
                                              if(passwordController.text.trim()==passwordController_X.text.trim()){
                                                signUp();
                                              }else{
                                                Utils.showSnackBar("Enter same password");
                                              }
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.only(right: 15),
                                              child: Text('Sign up '),
                                            ),
                                          ),
                                        ],
                                      );
                                    });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10,),
                        InkWell(
                          child: const Text(
                            "Report",
                            style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w400, fontSize: 13),
                          ),
                          onTap:(){
                            _sendingMails(
                                "sujithnimmala03@gmail.com");
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future signUp() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ));
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailController.text.trim().toLowerCase(), password: passwordController.text.trim());
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MyApp()));
    } on FirebaseException catch (e) {
      print(e);
      Utils.showSnackBar(e.message);
    }

    Navigator.pop(context);


  }

  Future resetPassword() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ));
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text.trim());
      Utils.showSnackBar("Password Reset Email Sent");
    } on FirebaseAuthException catch (e) {
      print(e);
      Utils.showSnackBar(e.message);
    }
    Navigator.pop(context);
    return Navigator.pop(context);
  }
}

final messengerKey = GlobalKey<ScaffoldMessengerState>();

class Utils {
  static showSnackBar(String? text) {
    if (text == null) return;
    final snackBar = SnackBar(content: Text(text), backgroundColor: Colors.orange);
    messengerKey.currentState!
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}

_sendingMails(String urlIn) async {
  var url = Uri.parse("mailto:$urlIn");
  if (!await launchUrl(url)) throw 'Could not launch $url';
}

showToast(String message) async {
  await Fluttertoast.cancel();
  Fluttertoast.showToast(msg: message, fontSize: 18);
}