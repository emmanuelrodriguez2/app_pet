import 'package:app_pet/presentation/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_swipe/liquid_swipe.dart';

class PageOnboarding extends StatefulWidget {
  const PageOnboarding({super.key});

  @override
  _PageOnboardingState createState() => _PageOnboardingState();
}

class _PageOnboardingState extends State<PageOnboarding> {
  int page = 0;
  bool enableSlideIcon = true;
  bool isDarkGlobal = false;

  @override
  Widget build(BuildContext context) {
    final pages = [
      viewcomponent(
        context: context,
        colorFondo: Color.fromRGBO(63, 123, 159, 1),
        assetImage: AssetImage("assets/images/img1.png"),
        titulo2: "Calcula con precisión",
        titulo1: "La dieta ideal",
        subtitulo:
            "Personaliza la alimentación de tu perro según su tamaño, edad y actividad",
        isDark: false,
      ),
      viewcomponent(
        context: context,
        colorFondo: Color.fromRGBO(21, 88, 105, 1.0),
        assetImage: AssetImage("assets/images/img2.png"),
        titulo2: "Kcal y raciones",
        titulo1: "Calculadora inteligente",
        subtitulo:
            "Obtén las porciones diarias recomendadas para una alimentación saludable",
        isDark: false,
      ),
      viewcomponent(
        context: context,
        colorFondo: Color.fromRGBO(0, 20, 38, 1.0),
        assetImage: AssetImage("assets/images/img3.png"),
        titulo2: "Monitorea la salud",
        titulo1: "Perritos felices",
        subtitulo:
            "Revisa checklist y mantén sus hábitos nutricionales en orden",
        isDark: false,
      ),
      viewcomponent(
        context: context,
        colorFondo: Color.fromRGBO(77, 85, 84, 1),
        assetImage: AssetImage("assets/images/img4.png"),
        titulo2: "¿Puedo comer eso?",
        titulo1: "Guía de alimentos",
        subtitulo:
            "Consulta qué frutas, verduras y snacks son seguros para tu mascota",
        isDark: false,
        height: 0.5,
      ),
      LoginPage(),
    ];
    SystemChrome.setSystemUIOverlayStyle(
      isDarkGlobal ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
    );

    return Scaffold(
      body: Builder(
        builder:
            (context) => LiquidSwipe(
              initialPage: 0,
              fullTransitionValue: 500,
              enableLoop: false,
              positionSlideIcon: 0.45,
              slideIconWidget: Icon(
                Icons.arrow_back_ios,
                color: isDarkGlobal ? Colors.black : Colors.white,
              ),
              pages: pages,
              onPageChangeCallback: onPageChangeCallback,
              waveType: WaveType.liquidReveal,
            ),
      ),
    );
  }

  onPageChangeCallback(int lpage) {
    setState(() {
      page = lpage;
      if (4 == page) {
        enableSlideIcon = false;
        isDarkGlobal = true;
      } else {
        enableSlideIcon = true;

        isDarkGlobal = false;
      }
    });
  }

  Container viewcomponent({
    required BuildContext context,
    required AssetImage assetImage,
    String titulo1 = "",
    String titulo2 = "",
    String subtitulo = "",
    Color colorFondo = Colors.white,
    bool isDark = false,
    double height = 0.4,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    return Container(
      color: colorFondo,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: screenHeight * 0.05, width: screenWidth),
          Stack(
            children: <Widget>[
              Image(
                image: assetImage,
                width: screenWidth,
                height: screenHeight * height,
                fit: BoxFit.fitHeight,
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 20.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(child: Container()),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      child: Text(
                        "Omitir",
                        style: TextStyle(
                          fontSize: 20.0,
                          color: isDark ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.all(20.0),
            height: screenHeight * 0.4,
            margin: EdgeInsets.only(right: 50.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  titulo2,
                  style: TextStyle(
                    fontSize: 25.0,
                    color: isDark ? Colors.grey : Colors.white,
                    fontFamily: "Product Sans",
                  ),
                ),
                Text(
                  titulo1,
                  style: TextStyle(
                    fontSize: 30.0,
                    color: isDark ? Colors.black : Colors.white,
                    fontFamily: "Product Sans",
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20.0),
                Text(
                  subtitulo,
                  style: TextStyle(
                    color: isDark ? Colors.grey : Colors.white,
                    fontSize: 20.0,
                    fontFamily: "Product Sans",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
