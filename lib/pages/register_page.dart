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
  final _firstNameController = TextEditingController();
  final _secondNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _carreraController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmpasswordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmpasswordFocusNode.dispose();
    _passwordController.dispose();
    _confirmpasswordController.dispose();
    _firstNameController.dispose();
    _secondNameController.dispose();
    _ageController.dispose();
    _carreraController.dispose();

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
          _firstNameController.text.trim(),
          _secondNameController.text.trim(),
          _emailController.text.trim(),
          _carreraController.text.trim(),
          int.parse(
            _ageController.text.trim(),
          ));
    }
  }

  Future addUserDetails(
    String id,
    String firstName,
    String lastName,
    String email,
    String carrera,
    int age,
  ) async {
    await FirebaseFirestore.instance.collection("users").doc(id).set({
      'first name': firstName,
      'last name': lastName,
      'email': email,
      'carrera': carrera,
      'age': age,
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
                padding: EdgeInsets.only(left: 50.0),
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
                padding: EdgeInsets.only(left: 50.0),
                child: Text(
                  "És la teva primera vegada aqui? Crea un Compte",
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 24,
                    color: Colors.grey[400],
                  ),
                ),
              ),

              SizedBox(height: 15),

              SizedBox(
                height: 10,
              ),

              SizedBox(
                height: 10,
              ),

              SizedBox(
                height: 10,
              ),
              //E-mail
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
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
                        labelText: 'Correo Electrónico',
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
              //Password
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: FormBuilder(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: FormBuilderTextField(
                      name: 'contrasenya',
                      controller: _passwordController,
                      obscureText: true,
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
              SizedBox(
                height: 30,
              ),
              //Password
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12)),
                  child: FormBuilder(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: FormBuilderTextField(
                      name: 'repetir contrasenya',
                      controller: _confirmpasswordController,
                      obscureText: true,
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
                height: 30,
              ), //Nom d'usuari

              SizedBox(
                height: 10,
              ),
              //sign up button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: GestureDetector(
                  onTap: signUp,
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(0xFF1FA29E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text("Registra" "'t",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
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
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: widget.showLoginPage,
                    child: Text(
                      "Inicia la Sessió",
                      style: TextStyle(
                          color: Color(0xFF1FA29E),
                          fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ],
          ),
        ));
  }
}
