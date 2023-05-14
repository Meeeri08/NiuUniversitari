// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jobapp/pages/forgot_pw_page.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback showRegisterPage;
  const LoginPage({Key? key, required this.showRegisterPage}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //text controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool rememberMe = false;

  bool _obscureText = true;

  Future signIn() async {
    //loading circle
    showDialog(
        context: context,
        builder: (context) {
          return Center(child: CircularProgressIndicator());
        });

    await FirebaseAuth.instance
        .signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        )
        .then((value) => {loginSuccess(value.user)})
        .catchError((err) => {print("Error de auth")});
  }

  void loginSuccess(dynamic user) {
    // final localStorage = new LocalStorage();
    // localStorage.saveData('user', user);
    // final x = localStorage.getData('user');
    // print(x);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    rememberMe = false;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                  'Iniciar Sessió',
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
            "Iniciem la sessió",
            style:
                GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 36),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Padding(
          padding: EdgeInsets.only(left: 40.0),
          child: Text(
            'Benvingut, t' "'" 'hem trobat \n a faltar!',
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

        SizedBox(height: 10),
        //E-mail

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

        SizedBox(
          height: 10,
        ),
        //Password
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
                  labelText: 'Contrasenya',
                  labelStyle: TextStyle(
                    color: Colors.grey,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  suffixIcon: IconButton(
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

        Padding(
          padding: EdgeInsets.only(left: 40.0, right: 40.0),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Transform.scale(
                      scale: 0.8,
                      child: Checkbox(
                        value: rememberMe,
                        onChanged: (newValue) {
                          setState(() {
                            rememberMe = newValue ?? false;
                          });
                        },
                        activeColor: Color(0xFF1FA29E),
                      ),
                    ),
                    Text(
                      'Remember Me',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 40.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return ForgotPasswordPage();
                    }));
                  },
                  child: Text(
                    'Contrasenya oblidada?',
                    style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: Color(0xFF1FA29E),
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(
          height: 10,
        ),
        //sign in button
        Padding(
          padding: EdgeInsets.only(left: 40.0),
          child: GestureDetector(
            onTap: signIn,
            child: Container(
              padding: EdgeInsets.all(20),
              width: 305,
              decoration: BoxDecoration(
                color: Color(0xFF1FA29E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text('Inicia la Sessió',
                    style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 15,
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'O',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 166, 164, 164),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 15,
        ),

        //sign in button
        Padding(
          padding: EdgeInsets.only(left: 40.0),
          child: GestureDetector(
            onTap: signIn,
            child: Container(
              padding: EdgeInsets.all(20),
              width: 305,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 232, 238, 237),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text('Continua amb Google',
                    style: GoogleFonts.dmSans(
                        color: Colors.black87,
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
              "No tens un compte? ",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.grey[500]),
            ),
            GestureDetector(
              onTap: widget.showRegisterPage,
              child: Text(
                "Registra" "'t",
                style: TextStyle(
                    color: Color(0xFF1FA29E),
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
            )
          ],
        ),
      ])),
    );
  }
}
