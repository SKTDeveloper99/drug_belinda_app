import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DrugDetailScreen extends StatelessWidget {
  const DrugDetailScreen({
    super.key,
    required this.info,
  });

  final Map info;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(info["title"]),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.network(info["medPicURL"]),
              Text(info["description"],
                  style: TextStyle(fontSize: 26),),
              TextButton(
                  onPressed: () async {
                    launchUrl(Uri.parse(info["medURL"]));
                  },
                  child: const Text("Check your meds on Drugs.com"),
              )
            ],
          ),
        ),
      ),
    );
  }
}