import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jobapp/pages/profile_page.dart';

class Account extends StatefulWidget {
  const Account({Key? key}) : super(key: key);

  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Compte',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Color(0xff25262b),
          ),
        ),
      ),
      body: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                // backgroundImage: NetworkImage(
                //   'https://example.com/avatar-image.jpg', // Reemplaza con la URL de la imagen del avatar
                // ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Nombre del usuario', // Reemplaza con el nombre del usuario
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Lógica para ir a la pantalla de configuración
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => SettingsScreen()),
                    // );
                  },
                  child: Text('Settings'),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Lógica para ir a la pantalla de preferidos
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => FavoritesScreen()),
                    // );
                  },
                  child: Text('Preferidos'),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          ListTile(
            title: Text('Componente 1'),
            onTap: () {
              // Lógica para ir a la pantalla del Componente 1
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Profile()),
              );
            },
          ),
          ListTile(
            title: Text('Componente 2'),
            onTap: () {
              // Lógica para ir a la pantalla del Componente 2
              // Navigator.push(
              // context,
              // MaterialPageRoute(builder: (context) => Component2Screen()),
              //  );
            },
          ),
          ListTile(
            title: Text('Componente 3'),
            onTap: () {
              // Lógica para ir a la pantalla del Componente 3
              //Navigator.push(
              // context,
              //MaterialPageRoute(builder: (context) => Component3Screen()),
              // );
            },
          ),
          ListTile(
            title: Text('Componente 4'),
            onTap: () {
              // Lógica para ir a la pantalla del Componente 4
              //  Navigator.push(
              //  context,
              //  MaterialPageRoute(builder: (context) => Component4Screen()),
              // );
            },
          ),
          ListTile(
            title: Text('Componente 5'),
            onTap: () {
              // Lógica para ir a la pantalla del Componente 5
              // Navigator.push(
              // context,
              // MaterialPageRoute(builder: (context) => Component5Screen()),
              // );
            },
          ),
        ],
      ),
    );
  }
}
