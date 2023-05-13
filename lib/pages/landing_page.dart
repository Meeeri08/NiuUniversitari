import 'package:flutter/material.dart';
import 'package:jobapp/components/slider.dart';

import '../auth/main_page.dart';

class Landing extends StatefulWidget {
  @override
  _LandingState createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  int _currentPage = 0;
  PageController _controller = PageController();

  List<Widget> _pages = [
    SliderPage(
        title: "Descobreix",
        description:
            "Busca entre una àmplia selecció de pisos disponibles. Troba el teu pis ideal i lloga amb facilitat.",
        image: "lib/images/1.svg"),
    SliderPage(
        title: "Connecta",
        description:
            "Connecta amb altres estudiants que també estan buscant un pis compartit.",
        image: "lib/images/2.svg"),
    SliderPage(
        title: "Lloga",
        description:
            "Troba el pis que compleixi amb les teves necessitats i desitjos, i comença a gaudir de la comoditat del teu nou llar.",
        image: "lib/images/3.svg"),
  ];

  _onchanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          PageView.builder(
            scrollDirection: Axis.horizontal,
            onPageChanged: _onchanged,
            controller: _controller,
            itemCount: _pages.length,
            itemBuilder: (context, int index) {
              return _pages[index];
            },
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(_pages.length, (int index) {
                    return AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        height: 10,
                        width: (index == _currentPage) ? 30 : 10,
                        margin:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 30),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: (index == _currentPage)
                                ? Color(0xFF1FA29E)
                                : Color(0xFF1FA29E).withOpacity(0.5)));
                  })),
              InkWell(
                onTap: () {
                  if (_currentPage == (_pages.length - 1)) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => MainPage()));
                  } else {
                    _controller.nextPage(
                        duration: Duration(milliseconds: 800),
                        curve: Curves.easeInOutQuint);
                  }
                },
                child: AnimatedContainer(
                  alignment: Alignment.center,
                  duration: Duration(milliseconds: 300),
                  height: 70,
                  width: (_currentPage == (_pages.length - 1)) ? 200 : 75,
                  decoration: BoxDecoration(
                      color: Color(0xFF1FA29E),
                      borderRadius: BorderRadius.circular(35)),
                  child: (_currentPage == (_pages.length - 1))
                      ? Text(
                          "Comença",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        )
                      : Icon(
                          Icons.navigate_next,
                          size: 50,
                          color: Colors.white,
                        ),
                ),
              ),
              SizedBox(
                height: 50,
              )
            ],
          ),
        ],
      ),
    );
  }
}
