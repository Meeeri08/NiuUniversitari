import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jobapp/read%20data/get_user_name.dart';

/* import 'package:settings_ui/settings_ui.dart';
 */
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
//document ID's
  final userId = FirebaseAuth.instance.currentUser!.uid;

  List<String> docIDs = [];
  String username = "";
  dynamic user = null;

  bool _darkMode = false;
  String? _language = 'English';

  tests() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .forEach((element) {
      setState(() {
        user = element;
      });
    });
  }

  //get docIDs
  @override
  Widget build(BuildContext context) {
    tests();
    return MaterialApp(
        theme: _darkMode ? ThemeData.dark() : ThemeData.light(),
        home: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            backgroundColor: Colors.deepPurple[200],
            elevation: 0,
            title: Text('Configuració'),
          ),
          body: ListView(
            children: <Widget>[
              SwitchListTile(
                title: Text('Dark mode'),
                value: _darkMode,
                onChanged: (value) {
                  setState(() {
                    _darkMode = value;
                  });
                },
              ),
              ListTile(
                title: Text('Language'),
                trailing: DropdownButton<String>(
                  value: _language,
                  items: <String>['English', 'Español', 'Français']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _language = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ));
  }
}
//         body: Center(
//             child:
//                 Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//           Text(user != null ? user["first name"] : ''),
//           Text(user != null ? user["last name"] : ''),
//           Text(user != null ? user["email"] : '')
//         ])));
//   }
// }

//settings_ui
/*  child: SettingsList(
            sections: [
              SettingsSection(title: Text('Compte'), t iles: <SettingsTile>[
                SettingsTile(
                  title: Text('a'),
                )
              ]),
              SettingsSection(
                title: Text('General'),
                tiles: <SettingsTile>[
                  SettingsTile.navigation(
                    leading: Icon(Icons.language),
                    title: Text('Idioma'),
                    value: Text('Català'),
                  ),
                  SettingsTile.switchTile(
                    onToggle: (value) {},
                    initialValue: false,
                    leading: Icon(Icons.dark_mode),
                    title: Text('Mode nit'),
                  ),
                ],
              ),
            ], 
          ),*/
