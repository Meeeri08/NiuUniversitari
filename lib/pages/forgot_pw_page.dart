import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              content: Text('Enllaç enviat. Fes un cop dull a la teva bústia'),
            );
          });
    } on FirebaseAuthException catch (e) {
      print(e);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.message.toString()),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 70,
        centerTitle: true,
        title: Text(
          'Recuperar Contrasenya',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Color(0xff25262b),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: Colors.black,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
      backgroundColor: Color(0xFFF5F5F5),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 45.0, vertical: 50),
            child: Text(
              'Introdueix el teu correu i mira la teva bústia',
              style: TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          //E-mail

          Container(
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

          const SizedBox(
            height: 40,
          ),
          GestureDetector(
            onTap: passwordReset,
            child: Container(
              padding: EdgeInsets.all(20),
              width: 305,
              decoration: BoxDecoration(
                color: Color(0xFF1FA29E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text('Recuperar Contrasenya',
                    style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
