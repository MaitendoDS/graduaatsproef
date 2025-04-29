import 'package:flutter/material.dart';
import 'package:unda_application/common/color_extension.dart';

class OnBoardingView extends StatefulWidget {
  const OnBoardingView({super.key});

  @override
  State<OnBoardingView> createState() => _OnBoardingViewState();
}

class _OnBoardingViewState extends State<OnBoardingView> {

PageController controller = PageController();

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [

          PageView.builder(
            controller: controller,
            itemBuilder: (context, index) {

            return SizedBox(
              width: media.width,
              height: media.height,
              
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset("assetsimgonboarding1.png", 
                  width: media.width,
                  fit: BoxFit.fitWidth, 
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15 ),
                    child: Text(
                      "Track your cycle", 
                      style: TextStyle(
                        color: TColor.black,
                        fontSize:  24,
                        fontWeight: FontWeight.w700),
                      ),                  
                  ),
               
                ],
              )

            );

          }),
        ],

      ),
    );
  }
}