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
  bool showConfiguration = true;
  bool showFavorites = false;

  late Stream<DocumentSnapshot> userStream;
  DocumentSnapshot? userSnapshot;

  @override
  void initState() {
    super.initState();
    userStream = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();

    userStream.listen((snapshot) {
      setState(() {
        userSnapshot = snapshot;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (userSnapshot == null) {
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
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final user = userSnapshot!.data() as Map<String, dynamic>;
    final imageUrl = user['imageUrl'];
    final name = user['name'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
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
      body: Padding(
        padding: const EdgeInsets.only(left: 30, right: 30, top: 30),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 52,
                  backgroundImage: NetworkImage(imageUrl),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.dmSans(fontSize: 36),
                      ),
                      Text(
                        user['surname'],
                        style: GoogleFonts.dmSans(fontSize: 36),
                      ),
                    ],
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
                      setState(() {
                        showConfiguration = true;
                        showFavorites = false;
                      });
                    },
                    child: Text(
                      'Configuració',
                      style: GoogleFonts.dmSans(
                        color: showConfiguration ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: showConfiguration
                          ? const Color(0xFF1FA29E)
                          : Colors.white,
                      foregroundColor:
                          showConfiguration ? Colors.white : Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 1,
                      shadowColor: Colors.black,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showConfiguration = false;
                        showFavorites = true;
                      });
                    },
                    child: Text(
                      'Preferits',
                      style: GoogleFonts.dmSans(
                        color: showFavorites ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: showFavorites
                          ? const Color(0xFF1FA29E)
                          : Colors.white,
                      foregroundColor:
                          showFavorites ? Colors.white : Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 1,
                      shadowColor: Colors.black,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: showConfiguration
                  ? buildConfigurationContent()
                  : buildFavoritesContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildConfigurationContent() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
              ),
              child: Icon(
                Icons.account_circle_outlined,
                color: Color(0xff25262b),
                size: 30,
              ),
            ),
            title: Text('Perfil', style: GoogleFonts.dmSans(fontSize: 18)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Profile()),
              );
            },
          ),
        ),
        Divider(
          color: Colors.grey.shade700,
          thickness: 0.1,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
              ),
              child: Icon(
                Icons.notifications_none_outlined,
                color: Color(0xff25262b),
                size: 30,
              ),
            ),
            title:
                Text('Notificacions', style: GoogleFonts.dmSans(fontSize: 18)),
            onTap: () {},
          ),
        ),
        Divider(
          color: Colors.grey.shade700,
          thickness: 0.1,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
              ),
              child: Icon(
                Icons.info_outline,
                color: Color(0xff25262b),
                size: 30,
              ),
            ),
            title: Text('Sobre Nosaltres',
                style: GoogleFonts.dmSans(fontSize: 18)),
            onTap: () {},
          ),
        ),
        Divider(
          color: Colors.grey.shade700,
          thickness: 0.1,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
              ),
              child: Icon(
                Icons.privacy_tip_outlined,
                color: Color(0xff25262b),
                size: 30,
              ),
            ),
            title: Text('Privacitat', style: GoogleFonts.dmSans(fontSize: 18)),
            onTap: () {},
          ),
        ),
        Divider(
          color: Colors.grey.shade700,
          thickness: 0.1,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
              ),
              child: Icon(
                Icons.logout_outlined,
                color: Color(0xff25262b),
                size: 30,
              ),
            ),
            title: Text('Tancar la Sessió',
                style: GoogleFonts.dmSans(fontSize: 18)),
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget buildFavoritesContent() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
              ),
              child: Icon(
                Icons.favorite_border_outlined,
                color: Color(0xff25262b),
                size: 30,
              ),
            ),
            title: Text('Pis', style: GoogleFonts.dmSans(fontSize: 18)),
            onTap: () {},
          ),
        ),
        Divider(
          color: Colors.grey.shade700,
          thickness: 0.1,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
              ),
              child: Icon(
                Icons.favorite_border_outlined,
                color: Color(0xff25262b),
                size: 30,
              ),
            ),
            title: Text('Pis', style: GoogleFonts.dmSans(fontSize: 18)),
            onTap: () {},
          ),
        ),
        Divider(
          color: Colors.grey.shade700,
          thickness: 0.1,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
              ),
              child: Icon(
                Icons.favorite_border_outlined,
                color: Color(0xff25262b),
                size: 30,
              ),
            ),
            title: Text('Pis', style: GoogleFonts.dmSans(fontSize: 18)),
            onTap: () {},
          ),
        ),
        Divider(
          color: Colors.grey.shade700,
          thickness: 0.1,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
              ),
              child: Icon(
                Icons.favorite_border_outlined,
                color: Color(0xff25262b),
                size: 30,
              ),
            ),
            title: Text('Pis', style: GoogleFonts.dmSans(fontSize: 18)),
            onTap: () {},
          ),
        ),
        Divider(
          color: Colors.grey.shade700,
          thickness: 0.1,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
              ),
              child: Icon(
                Icons.favorite_border_outlined,
                color: Color(0xff25262b),
                size: 30,
              ),
            ),
            title: Text('Pis', style: GoogleFonts.dmSans(fontSize: 18)),
            onTap: () {},
          ),
        ),
      ],
    );
  }
}
