// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterPage({Key? key, required this.showLoginPage}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //text controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmpasswordController = TextEditingController();
  //final _firstNameController = TextEditingController();
  //final _secondNameController = TextEditingController();
  //final _ageController = TextEditingController();
  //final _carreraController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmpasswordFocusNode = FocusNode();

  bool _passwordsMatch() {
    final password = _passwordController.text;
    final confirmPassword = _confirmpasswordController.text;

    if (password.isEmpty || confirmPassword.isEmpty) {
      return false;
    }

    return password == confirmPassword;
  }

  bool _obscureText = true;
  bool _obscureText1 = true;
  bool? _acceptTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmpasswordFocusNode.dispose();
    _passwordController.dispose();
    _confirmpasswordController.dispose();
    // _firstNameController.dispose();
    //_secondNameController.dispose();
    //_ageController.dispose();
    //_carreraController.dispose();

    super.dispose();
  }

  final int _currentStep = 0;

  Future signUp() async {
    if (passwordConfirmed()) {
      //create user
      final data = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim());
      //add user details
      addUserDetails(
        data.user?.uid as String,
        // _firstNameController.text.trim(),
        // _secondNameController.text.trim(),
        _emailController.text.trim(),
        //_carreraController.text.trim(),
        //  int.parse(
        //  _ageController.text.trim(),
        // )
      );
    }
  }

  Future addUserDetails(
    String id,
    // String firstName,
    // String lastName,
    String email,
    // String carrera,
    //int age,
  ) async {
    await FirebaseFirestore.instance.collection("users").doc(id).set({
      'id': id, // Add the ID field to the document
      //'first name': firstName,
      // 'last name': lastName,
      'email': email,
      //   'carrera': carrera,
      // 'age': age,
    });
  }

  bool passwordConfirmed() {
    if (_passwordController.text.trim() ==
        _confirmpasswordController.text.trim()) {
      return true;
    } else {
      return false;
    }
    ;
  }

  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Registrar',
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 48),
                ],
              ),
              SizedBox(height: 30),

              Padding(
                padding: EdgeInsets.only(left: 40.0),
                child: Text(
                  "Primers Passos",
                  style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.bold, fontSize: 36),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: EdgeInsets.only(left: 40.0),
                child: Text(
                  "És la teva primera vegada aqui? Crea un Compte",
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.normal,
                    fontSize: 25,
                    color: Color.fromARGB(255, 166, 164, 164),
                  ),
                ),
              ),

              SizedBox(height: 15),

              SizedBox(
                height: 30,
              ),

              // E-mail
              Padding(
                padding: EdgeInsets.only(left: 40.0),
                child: Container(
                  width: 305,
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: FormBuilder(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: FormBuilderTextField(
                      name: 'email',
                      controller: _emailController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        labelText: 'Correu Electrònic',
                        labelStyle: TextStyle(
                          color: Colors.grey,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      focusNode: _emailFocusNode,
                    ),
                  ),
                ),
              ),

              SizedBox(
                height: 30,
              ),
// Password
              Padding(
                padding: EdgeInsets.only(left: 40.0),
                child: Container(
                  width: 305,
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: FormBuilder(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: FormBuilderTextField(
                      name: 'contrasenya',
                      controller: _passwordController,
                      obscureText: _obscureText1,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        labelText: 'Contrasenya',
                        labelStyle: TextStyle(
                          color: Colors.grey,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText1
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.grey[400],
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText1 = !_obscureText1;
                            });
                          },
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      focusNode: _passwordFocusNode,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 30),

// Confirm Password
              Padding(
                padding: EdgeInsets.only(left: 40.0),
                child: Container(
                  width: 305,
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: FormBuilder(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: FormBuilderTextField(
                      name: 'repetir contrasenya',
                      controller: _confirmpasswordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        labelText: 'Repetir Contrasenya',
                        labelStyle: TextStyle(
                          color: Colors.grey,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        suffixIcon: _passwordsMatch()
                            ? Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Icon(
                                  Icons.check,
                                  color: Colors.green,
                                  size: 18,
                                ),
                              )
                            : IconButton(
                                icon: Icon(
                                  _obscureText
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.grey[400],
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                              ),
                        suffixIconConstraints: BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      focusNode: _confirmpasswordFocusNode,
                    ),
                  ),
                ),
              ),

              SizedBox(
                height: 10,
              ),
              // Terms and Conditions
              Padding(
                padding: EdgeInsets.only(left: 40.0),
                child: Row(
                  children: [
                    Transform.scale(
                      scale: 0.8,
                      child: Checkbox(
                        value: _acceptTerms,
                        onChanged: (value) {
                          setState(() {
                            _acceptTerms = value;
                          });
                        },
                        activeColor: Color(0xFF1FA29E),
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'En crear un compte, accepteu els nostres\n',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          TextSpan(
                            text: 'Termes i Condicions.',
                            style: GoogleFonts.dmSans(
                                fontSize: 12, color: Color(0xFF1FA29E)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: 30,
              ),
              //sign up button
              Padding(
                padding: EdgeInsets.only(left: 40.0),
                child: GestureDetector(
                  onTap: signUp,
                  child: Container(
                    padding: EdgeInsets.all(20),
                    width: 305,
                    decoration: BoxDecoration(
                      color: Color(0xFF1FA29E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text("Registra" "'t",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                    ),
                  ),
                ),
              ),

              SizedBox(
                height: 25,
              ),
              //registrar
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Ja estas registrat? ",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Colors.grey[500]),
                  ),
                  GestureDetector(
                    onTap: widget.showLoginPage,
                    child: Text(
                      "Inicia la Sessió",
                      style: TextStyle(
                          color: Color(0xFF1FA29E),
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                  )
                ],
              ),
            ],
          ),
        ));
  }
}
