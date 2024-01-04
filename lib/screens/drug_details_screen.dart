import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:medical_app_belinda_full/auth/auth.dart';
import 'package:medical_app_belinda_full/main.dart';
import 'package:url_launcher/url_launcher.dart';

class DrugDetailScreen extends StatefulWidget {

  const DrugDetailScreen({
    super.key,
    required this.info, required this.medListKey, required this.morning, required this.afternoon, required this.evening,
  });

  final Map info;
  final dynamic medListKey;
  final dynamic morning;
  final dynamic afternoon;
  final dynamic evening;

  @override
  State<DrugDetailScreen> createState() => _DrugDetailScreenState();
}

class _DrugDetailScreenState extends State<DrugDetailScreen> {
  String dropdownvalueMorning = "true";
  String dropdownvalueNoon = 'true';
  String dropdownvalueEvening = 'true';


  var items = [
    'true',
    'false',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.info["title"]),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image.network(info["medPicURL"]),
              CachedNetworkImage(
                imageUrl: widget.info["medPicURL"] ?? "https:firebasestorage.googleapis.com/v0/b/khoatrancodingminds.appspot.com/o/WechatIMG83.jpg?alt=media&token=90fc2853-7f45-441f-b0de-e83529a86ae0",
                placeholder: (context, url) => const Center(child:  CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
              Text(widget.info["description"],
                  style: TextStyle(fontSize: 26),),
              TextButton(
                  onPressed: () async {
                    launchUrl(Uri.parse(widget.info["medURL"]));
                  },
                  child: const Text("Check your meds on Drugs.com"),
              ),
              const Divider(),
              const Text("Morning Drug?"),
              DropdownButton(
                // Initial Value
                value: dropdownvalueMorning,

                // Down Arrow Icon
                icon: const Icon(Icons.keyboard_arrow_down),

                // Array list of items
                items: items.map((String items) {
                  return DropdownMenuItem(
                    value: items,
                    child: Text(items),
                  );
                }).toList(),
                // After selecting the desired option,it will
                // change button value to selected value
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownvalueMorning = newValue!;
                  });
                },
              ),
              const Text("Afternoon Drug?"),
              DropdownButton(
                // Initial Value
                value: dropdownvalueNoon,

                // Down Arrow Icon
                icon: const Icon(Icons.keyboard_arrow_down),

                // Array list of items
                items: items.map((String items) {
                  return DropdownMenuItem(
                    value: items,
                    child: Text(items),
                  );
                }).toList(),
                // After selecting the desired option,it will
                // change button value to selected value
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownvalueNoon = newValue!;
                  });
                },
              ),
              const Text("Evening Drug?"),
              DropdownButton(
                // Initial Value
                value: dropdownvalueEvening,

                // Down Arrow Icon
                icon: const Icon(Icons.keyboard_arrow_down),

                // Array list of items
                items: items.map((String items) {
                  return DropdownMenuItem(
                    value: items,
                    child: Text(items),
                  );
                }).toList(),
                // After selecting the desired option,it will
                // change button value to selected value
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownvalueEvening = newValue!;
                  });
                },
              ),
              ElevatedButton(
                  onPressed: () async {
                    await FirebaseDatabase.instance.ref()
                        .child("/users/${auth.currentUser!.uid}/medLogs/${widget.medListKey}")
                        .update(
                        {
                          "morning": dropdownvalueMorning,
                          "afternoon": dropdownvalueNoon,
                          "evening": dropdownvalueEvening,
                        }
                    );
                    const snackBar = SnackBar(
                      content: Text('Your Drug has been updated'),
                    );

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      Navigator.popUntil(context, (route) => route.isFirst);
                    }

                  },
                  child: const Text("Update Drug info"))
            ],
          ),
        ),
      ),
    );
  }
}