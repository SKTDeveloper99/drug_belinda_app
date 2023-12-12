// import 'package:flutter/material.dart';
// import 'package:medical_app_belinda_full/home_page.dart';
//
// class DisclaimerScreen extends StatelessWidget {
//   const DisclaimerScreen({
//     super.key,
//   });
//
//   void showAlert(BuildContext context) {
//     showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text('Disclaimer'),
//           content: const Text('Consult to Healthcare Professionals for medical recommendations'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () => Navigator.pop(context, 'Cancel'),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pushAndRemoveUntil(
//                     MaterialPageRoute(
//                         builder: (context) => const BottomNavigationBarPage()), (Route<dynamic> route) => false
//                 );
//               },
//               child: const Text('OK'),
//             ),
//           ],
//         ));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Future.delayed(const Duration(milliseconds: 500), () => showAlert(context));
//     return const Scaffold(
//
//     );
//   }
// }
//

import 'package:flutter/material.dart';
import 'package:medical_app_belinda_full/home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    //init();
  }

  Future<void> init() async {
    await Future.delayed(const Duration(seconds: 2)).then((value) {
      Navigator.pop(context);
      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) => const BottomNavigationBarPage()));
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
          title: Text('Disclaimer'),
          content: Text('Consult to Healthcare Professionals for medical recommendations'),
          actions: <Widget>[
            // TextButton(
            //   onPressed: () => Navigator.pop(context, 'Cancel'),
            //   child: const Text('Cancel'),
            // ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const BottomNavigationBarPage()), (Route<dynamic> route) => false
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
  }
}