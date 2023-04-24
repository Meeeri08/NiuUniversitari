import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _codeSent = false;
  late String _verificationId;
  FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _verificationCodeController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Número de teléfono',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor, introduce tu número de teléfono';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                if (!_codeSent)
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await _verifyPhone();
                      }
                    },
                    child: Text('Verificar número'),
                  ),
                if (_codeSent)
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Código de verificación',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Por favor, introduce el código de verificación';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _verificationId = value;
                      });
                    },
                  ),
                SizedBox(height: 16.0),
                if (_codeSent)
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await _signInWithPhoneNumber();
                      }
                    },
                    child: Text('Iniciar sesión'),
                  ),
                if (_codeSent)
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre de usuario',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Por favor, introduce un nombre de usuario';
                      }
                      return null;
                    },
                  ),
                if (_codeSent)
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Por favor, introduce una contraseña';
                      }
                      return null;
                    },
                  ),
                if (_codeSent)
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await _register();
                      }
                    },
                    child: Text('Registrarse'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Función para verificar el número de teléfono
  Future<void> _verifyPhone() async {
    String phoneNumber = _phoneController.text;
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        print(e.message);
      },
      codeSent: (String verificationId, [int? resendToken]) {
        setState(() {
          _codeSent = true;
          _verificationId = verificationId;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
        });
      },
      timeout: Duration(seconds: 60),
    );
  }

  // Función para iniciar sesión con el número de teléfono verificado
  Future<void> _signInWithPhoneNumber() async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _verificationCodeController.text,
      );
      await _auth.signInWithCredential(credential);
    } catch (e) {
      print(e.toString());
    }
  }

  // Función para registrar al usuario en Firebase
  Future<void> _register() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _usernameController.text,
        password: _passwordController.text,
      );
      await FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(userCredential.user!.uid)
          .set({
        'phone': _phoneController.text,
        'username': _usernameController.text,
      });
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('La contraseña es demasiado débil');
      } else if (e.code == 'email-already-in-use') {
        print('Ya existe una cuenta con este correo electrónico');
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
