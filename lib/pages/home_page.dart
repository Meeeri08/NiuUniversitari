import 'package:flutter/material.dart';
import 'package:jobapp/pages/account_page.dart';
import 'package:jobapp/pages/dashboard.dart';
import 'package:jobapp/pages/tinder.dart';
import 'messages_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentTab = 0;
  final List<Widget> screens = [
    Dashboard(),
    const Tinder(),
    const Messages(),
    const Account(),
  ];
  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen = Dashboard();

  //List<DocumentSnapshot>? filteredHouses;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(
        child: currentScreen,
        bucket: bucket,
      ),
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: FloatingActionButton(
          child: const Icon(
            Icons.add,
            size: 32,
          ),
          backgroundColor: const Color(0xFF1FA29E),
          shape: RoundedRectangleBorder(
            side: const BorderSide(
                color: Colors.white,
                width: 3,
                strokeAlign: BorderSide.strokeAlignCenter),
            borderRadius: BorderRadius.circular(50),
          ),
          elevation: 1,
          onPressed: () {},
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        shadowColor: Colors.white,
        child: Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              MaterialButton(
                minWidth: 40,
                onPressed: () {
                  setState(() {
                    currentScreen = Dashboard();
                    currentTab = 0;
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.home,
                      color: currentTab == 0
                          ? const Color(0xFF1FA29E)
                          : Colors.grey.shade300,
                    ),
                  ],
                ),
              ),
              MaterialButton(
                minWidth: 40,
                onPressed: () {
                  setState(() {
                    currentScreen = const Tinder();
                    currentTab = 1;
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite,
                      color: currentTab == 1
                          ? const Color(0xFF1FA29E)
                          : Colors.grey.shade300,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 40),
              MaterialButton(
                minWidth: 40,
                onPressed: () {
                  setState(() {
                    currentScreen = const Messages();
                    currentTab = 2;
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.message_outlined,
                      color: currentTab == 2
                          ? const Color(0xFF1FA29E)
                          : Colors.grey.shade300,
                    ),
                  ],
                ),
              ),
              MaterialButton(
                minWidth: 40,
                onPressed: () {
                  setState(() {
                    currentScreen = const Account();
                    currentTab = 3;
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person,
                      color: currentTab == 3
                          ? const Color(0xFF1FA29E)
                          : Colors.grey.shade300,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   elevation: 0.0,
      //   automaticallyImplyLeading: false,
      //   leadingWidth: 90,
      //   leading: _currentIndex == 0
      //       ? SizedBox(
      //           child: Column(
      //             children: [
      //               Container(
      //                 decoration: BoxDecoration(
      //                   borderRadius: BorderRadius.circular(16),
      //                 ),
      //                 child: GestureDetector(
      //                   onTap: () async {
      //                     List<DocumentSnapshot>? result = await Navigator.push(
      //                       context,
      //                       MaterialPageRoute(builder: (context) {
      //                         return FilterScreen(
      //                           onFilterApplied: (houses) {
      //                             setState(() {
      //                               filteredHouses = houses;
      //                             });
      //                           },
      //                         );
      //                       }),
      //                     );
      //                     if (result != null) {
      //                       setState(() {
      //                         filteredHouses = result;
      //                       });
      //                     }
      //                   },
      //                   child: Icon(
      //                     Icons.filter_list_sharp,
      //                     color: Colors.grey[600],
      //                     size: 30,
      //                   ),
      //                 ),
      //               ),
      //             ],
      //           ),
      //         )
      //       : null,
      //   actions: _currentIndex == 0
      //       ? <Widget>[
      //           Container(
      //             padding: const EdgeInsets.only(right: 20),
      //             child: Column(
      //               children: [
      //                 Container(
      //                   decoration: const BoxDecoration(),
      //                   child: GestureDetector(
      //                     onTap: () {
      //                       Navigator.push(
      //                         context,
      //                         MaterialPageRoute(builder: (context) {
      //                           return const MapPage();
      //                         }),
      //                       );
      //                     },
      //                     child: Icon(
      //                       Icons.search,
      //                       color: Colors.grey[600],
      //                       size: 30,
      //                     ),
      //                   ),
      //                 ),
      //               ],
      //             ),
      //           ),
      //         ]
      //       : null,
      // ),
//       body: Stack(
//         children: [
//           IndexedStack(
//             index: _currentIndex,
//             children: [
//               Center(
//                 child: StreamBuilder<QuerySnapshot>(
//                   stream: (filteredHouses?.isNotEmpty == true)
//                       ? FirebaseFirestore.instance
//                           .collection('houses')
//                           .where(FieldPath.documentId,
//                               whereIn:
//                                   filteredHouses!.map((e) => e.id).toList())
//                           .snapshots()
//                       : FirebaseFirestore.instance
//                           .collection('houses')
//                           .snapshots(),
//                   builder: (BuildContext context,
//                       AsyncSnapshot<QuerySnapshot> snapshot) {
//                     if (snapshot.hasError) {
//                       return Center(
//                         child: Text('Error: ${snapshot.error}'),
//                       );
//                     }
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const Center(
//                         child: CircularProgressIndicator(),
//                       );
//                     }
//                     final houses = snapshot.data!.docs;

//                     if (filteredHouses?.isEmpty == true) {
//                       return Padding(
//                         padding: const EdgeInsets.only(bottom: 300.0),
//                         child: AlertDialog(
//                           title: const Text('Error'),
//                           content: const Text(
//                               'No hi ha cap resultat per a la teva cerca.'),
//                           actions: <Widget>[
//                             TextButton(
//                               child: const Text('OK'),
//                               onPressed: () {
//                                 setState(() {
//                                   filteredHouses = null;
//                                 });
//                               },
//                             ),
//                           ],
//                         ),
//                       );
//                     }

//                     return SizedBox(
//                       width: 400, // Adjust the width of the ListView here
//                       child: ListView.builder(
//                         padding: EdgeInsets.only(bottom: 200),
//                         itemCount: houses.length,
//                         itemBuilder: (BuildContext context, int index) {
//                           final house = houses[index];
//                           final imageUrl = house.get('image_url');
//                           final nRooms = house.get('n_rooms');
//                           final nBathroom = house.get('n_bathroom');
//                           final price = house.get('price');
//                           final title = house.get('title');
//                           final latLng = house.get('latlng');
//                           final barri = house.get('barri');

//                           return Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 8.0),
//                             child: GestureDetector(
//                               child: Card(
//                                 elevation: 0,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(10.0),
//                                 ),
//                                 child: InkWell(
//                                   onTap: () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => HouseDetailScreen(
//                                           houseId: house.id,
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(16.0),
//                                     child: Row(
//                                       children: [
//                                         Container(
//                                           width: 130,
//                                           height: 130,
//                                           decoration: BoxDecoration(
//                                             borderRadius:
//                                                 BorderRadius.circular(12.0),
//                                             image: DecorationImage(
//                                               image: NetworkImage(imageUrl),
//                                               fit: BoxFit.cover,
//                                             ),
//                                           ),
//                                         ),
//                                         SizedBox(width: 16),
//                                         Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               title,
//                                               style: GoogleFonts.dmSans(
//                                                 fontWeight: FontWeight.bold,
//                                                 fontSize: 16,
//                                                 color: Color(0xff25262b),
//                                               ),
//                                             ),
//                                             SizedBox(height: 15),
//                                             Row(
//                                               children: [
//                                                 Icon(
//                                                   Icons.location_on_outlined,
//                                                   color: Colors.grey.shade500,
//                                                   size: 14,
//                                                 ),
//                                                 Text(
//                                                   '  $barri',
//                                                   style: GoogleFonts.dmSans(
//                                                     fontSize: 12,
//                                                     color: Colors.grey.shade500,
//                                                     fontWeight: FontWeight.w700,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                             SizedBox(height: 10),
//                                             Row(
//                                               children: [
//                                                 Icon(
//                                                   Icons.bed_rounded,
//                                                   color: Colors.grey.shade500,
//                                                   size: 14,
//                                                 ),
//                                                 Text(
//                                                   '  $nRooms rooms',
//                                                   style: GoogleFonts.dmSans(
//                                                     fontSize: 12,
//                                                     color: Colors.grey.shade500,
//                                                     fontWeight: FontWeight.w700,
//                                                   ),
//                                                 ),
//                                                 SizedBox(width: 25),
//                                                 Icon(
//                                                   Icons.bathtub_outlined,
//                                                   color: Colors.grey.shade500,
//                                                   size: 14,
//                                                 ),
//                                                 Text(
//                                                   '  $nBathroom Lavabo',
//                                                   style: GoogleFonts.dmSans(
//                                                     fontSize: 12,
//                                                     color: Colors.grey.shade500,
//                                                     fontWeight: FontWeight.w700,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                             SizedBox(height: 30),
//                                             Text(
//                                               ' $price€ /mes',
//                                               style: GoogleFonts.dmSans(
//                                                 fontSize: 16,
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               const Tinder(),
//               const Messages(),
//               const Account(),
//             ],
//           ),
//           Positioned(
//             left: 0,
//             right: 0,
//             bottom: 0,
//             child: CurvedNavigationBar(
//               height: 75,
//               backgroundColor: Colors.transparent,
//               animationDuration: const Duration(milliseconds: 600),
//               index: _currentIndex,
//               onTap: (index) {
//                 setState(() {
//                   _currentIndex = index;
//                 });
//               },
//               items: [
//                 Icon(
//                   Icons.home,
//                   color: _currentIndex == 0
//                       ? Color(0xFF1FA29E)
//                       : Colors.grey.shade300,
//                 ),
//                 Icon(
//                   Icons.favorite,
//                   color: _currentIndex == 1
//                       ? Color(0xFF1FA29E)
//                       : Colors.grey.shade300,
//                 ),
//                 Icon(
//                   Icons.message_outlined,
//                   color: _currentIndex == 2
//                       ? Color(0xFF1FA29E)
//                       : Colors.grey.shade300,
//                 ),
//                 Icon(
//                   Icons.person,
//                   color: _currentIndex == 3
//                       ? Color(0xFF1FA29E)
//                       : Colors.grey.shade300,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
