// import 'package:animated_splash_screen/animated_splash_screen.dart';
// import 'package:drug_belinda_app/home_page.dart';
// import 'package:flutter/material.dart';
// import 'package:page_transition/page_transition.dart';
//
// class DisclaimerScreen extends StatelessWidget {
//   const DisclaimerScreen({
//     super.key,
//     this.color = const Color(0xFF2DBD3A),
//     this.child,
//   });
//
//   final Color color;
//   final Widget? child;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: AnimatedSplashScreen(
//       duration: 3000,
//       splash: Image.network(
//           "https://firebasestorage.googleapis.com/v0/b/important-reminders.appspot.com/o/DIsclaimer_page_of_medicine_app.png?alt=media&token=eff5f6fa-be44-4284-8031-6b5c20e09bce",
//       ),
//       splashIconSize: 250,
//       nextScreen: const BottomNavigationBarPage(),
//       splashTransition: SplashTransition.fadeTransition,
//       backgroundColor: Colors.white),
//     );
//   }
// }