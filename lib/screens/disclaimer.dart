import 'package:flutter/material.dart';
import 'package:medical_app_belinda_full/home_page.dart';

class DisclaimerScreen extends StatelessWidget {
  const DisclaimerScreen({
    super.key,
  });

  void showAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Disclaimer'),
          content: const Text('Consult to Healthcare Professionals for medical recommendations'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text('Cancel'),
            ),
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
        ));
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 500), () => showAlert(context));
    return const Scaffold(

    );
  }
}