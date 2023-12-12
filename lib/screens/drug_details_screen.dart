import 'package:cached_network_image/cached_network_image.dart';
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
              // Image.network(info["medPicURL"]),
              CachedNetworkImage(
                imageUrl: info["medPicURL"] ?? "https:firebasestorage.googleapis.com/v0/b/khoatrancodingminds.appspot.com/o/WechatIMG83.jpg?alt=media&token=90fc2853-7f45-441f-b0de-e83529a86ae0",
                placeholder: (context, url) => const Center(child:  CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
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