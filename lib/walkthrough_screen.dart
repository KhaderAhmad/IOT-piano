import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';

class WalkthroughScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<PageViewModel> pages = [
      PageViewModel(
        title: "Welcome to Piano Learning!",
        body: "Get ready to embark on your journey to mastering the piano.",
        decoration: PageDecoration(
          titleTextStyle: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
          bodyTextStyle: TextStyle(
            fontSize: 20.0,
            color: Colors.grey[700],
          ),
          bodyAlignment: Alignment.center,
          contentMargin: EdgeInsets.symmetric(horizontal: 16.0),
          pageColor: Colors.white,
        ),
      ),
      PageViewModel(
        title: "Track Your Progress",
        body: "Monitor your learning with our interactive dashboard.\n\nSee your improvements over time.",
        decoration: PageDecoration(
          titleTextStyle: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
          bodyTextStyle: TextStyle(
            fontSize: 20.0,
            color: Colors.grey[700],
          ),
          bodyAlignment: Alignment.center,
          contentMargin: EdgeInsets.symmetric(horizontal: 16.0),
          pageColor: Colors.white,
        ),
      ),
      PageViewModel(
        title: "Using Your Piano",
        bodyWidget: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "To start a mode, press the 'Start' button:",
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.green,
              child: Icon(Icons.play_arrow, color: Colors.white, size: 30),
            ),
            SizedBox(height: 24),
            Text(
              "Press 'Exit' when you're done:",
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.red,
              child: Icon(Icons.stop, color: Colors.white, size: 30),
            ),
          ],
        ),
        decoration: PageDecoration(
          titleTextStyle: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
          bodyAlignment: Alignment.center,
          contentMargin: EdgeInsets.symmetric(horizontal: 16.0),
          pageColor: Colors.white,
        ),
      ),
      // New Page for LED Explanation
      PageViewModel(
        title: "LED Indicator",
        bodyWidget: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "When all LEDs are yellow, please wait and stay calm:",
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            // Drawing the LEDs in the specified configuration
            GridView.builder(
              shrinkWrap: true,
              itemCount: 10, // 4 LEDs on the top, 6 LEDs on the bottom
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // Number of LEDs in a row
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                if (index < 4) {
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.yellow, // All LEDs are yellow
                    ),
                    width: 30, // Smaller width
                    height: 30, // Smaller height
                  );
                } else {
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.yellow, // All LEDs are yellow
                    ),
                    width: 30, // Smaller width
                    height: 30, // Smaller height
                  );
                }
              },
            ),
            SizedBox(height: 24),
            Text(
              "This means the system is processing. Please do not press any buttons.",
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        decoration: PageDecoration(
          titleTextStyle: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
          bodyAlignment: Alignment.center,
          contentMargin: EdgeInsets.symmetric(horizontal: 16.0),
          pageColor: Colors.white,
        ),
      ),
      PageViewModel(
        title: "Get Started!",
        body: "You're all set to start learning.\n\nPress 'Done' to begin your journey.",
        decoration: PageDecoration(
          titleTextStyle: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
          bodyTextStyle: TextStyle(
            fontSize: 20.0,
            color: Colors.grey[700],
          ),
          bodyAlignment: Alignment.center,
          contentMargin: EdgeInsets.symmetric(horizontal: 16.0),
          pageColor: Colors.white,
        ),
      ),
    ];

    return IntroductionScreen(
      pages: pages,
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context),
      showSkipButton: true,
      skip: const Text("Skip", style: TextStyle(fontSize: 18)),
      next: const Icon(Icons.arrow_forward, color: Colors.deepPurple),
      done: const Text("Done", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.deepPurple)),
      dotsDecorator: DotsDecorator(
        activeColor: Colors.deepPurple,
        size: Size(10.0, 10.0),
        color: Colors.grey,
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
    );
  }

  Future<void> _onIntroEnd(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenWalkthrough', true);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomeScreen(vec1: '', name1: '', tasks1: {})), // Navigate to HomeScreen
    );
  }
}
